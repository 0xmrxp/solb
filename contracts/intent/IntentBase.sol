// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IntentTypes } from "./IntentTypes.sol";
import { IIntentBase } from "./IIntentBase.sol";

/// @title IntentBase
/// @notice Abstract base contract for intent-based execution systems
/// @dev Inherit and implement _validateIntent(), _onFill(), _onCancel()
abstract contract IntentBase is IIntentBase {
    using IntentTypes for IntentTypes.Intent;

    mapping(bytes32 => IntentTypes.Intent) private _intents;
    mapping(address => mapping(uint256 => bool)) private _usedNonces;

    // ─────────────────────────────────────────────
    // External View
    // ─────────────────────────────────────────────

    /// @notice Get intent by ID
    function getIntent(bytes32 intentId)
        external
        view
        returns (IntentTypes.Intent memory)
    {
        return _intents[intentId];
    }

    /// @notice Check if nonce is used for a creator
    function isNonceUsed(address creator, uint256 nonce)
        external
        view
        returns (bool)
    {
        return _usedNonces[creator][nonce];
    }

    // ─────────────────────────────────────────────
    // Internal — Lifecycle Management
    // ─────────────────────────────────────────────

    /// @notice Register a new intent
    /// @param params Intent parameters
    /// @return intentId Unique identifier for the created intent
    function _registerIntent(IntentTypes.IntentParams memory params)
        internal
        returns (bytes32 intentId)
    {
        if (params.deadline <= block.timestamp)
            revert IIntentBase.IntentBase__InvalidDeadline(params.deadline);

        if (_usedNonces[params.creator][params.nonce])
            revert IIntentBase.IntentBase__NonceUsed(params.creator, params.nonce);

        intentId = _computeIntentId(params);

        _intents[intentId] = IntentTypes.Intent({
            params: params,
            status: IntentTypes.IntentStatus.OPEN,
            createdAt: block.timestamp,
            filledBy: address(0),
            filledAt: 0
        });

        _usedNonces[params.creator][params.nonce] = true;

        emit IntentCreated(intentId, params.creator, params.deadline);
    }

    /// @notice Mark an intent as filled
    /// @param intentId The intent to fill
    function _fillIntent(bytes32 intentId) internal {
        IntentTypes.Intent storage intent = _requireOpen(intentId);
        _requireNotExpired(intentId, intent);

        intent.status = IntentTypes.IntentStatus.FILLED;
        intent.filledBy = msg.sender;
        intent.filledAt = block.timestamp;

        emit IntentFilled(intentId, msg.sender, block.timestamp);
    }

    /// @notice Cancel an intent
    /// @param intentId The intent to cancel
    function _cancelIntent(bytes32 intentId) internal {
        IntentTypes.Intent storage intent = _requireOpen(intentId);

        // Allow cancellation by creator or if expired
        bool isCreator = msg.sender == intent.params.creator;
        bool isExpired = block.timestamp > intent.params.deadline;

        if (!isCreator && !isExpired)
            revert IIntentBase.IntentBase__Unauthorized(msg.sender);

        if (isExpired) {
            intent.status = IntentTypes.IntentStatus.EXPIRED;
            emit IntentExpired(intentId);
        } else {
            intent.status = IntentTypes.IntentStatus.CANCELLED;
            emit IntentCancelled(intentId, msg.sender);
        }
    }

    // ─────────────────────────────────────────────
    // Internal — Helpers
    // ─────────────────────────────────────────────

    function _computeIntentId(IntentTypes.IntentParams memory params)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(params));
    }

    function _requireOpen(bytes32 intentId)
        internal
        view
        returns (IntentTypes.Intent storage intent)
    {
        intent = _intents[intentId];
        if (intent.params.creator == address(0))
            revert IIntentBase.IntentBase__NotFound(intentId);
        if (intent.status != IntentTypes.IntentStatus.OPEN)
            revert IIntentBase.IntentBase__NotOpen(intentId, intent.status);
    }

    function _requireNotExpired(
        bytes32 intentId,
        IntentTypes.Intent storage intent
    ) internal view {
        if (block.timestamp > intent.params.deadline)
            revert IIntentBase.IntentBase__Expired(intentId, intent.params.deadline);
    }
}