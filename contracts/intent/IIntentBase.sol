// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IntentTypes } from "./IntentTypes.sol";

interface IIntentBase {
    event IntentCreated(
        bytes32 indexed intentId,
        address indexed creator,
        uint256 deadline
    );
    event IntentFilled(
        bytes32 indexed intentId,
        address indexed filler,
        uint256 filledAt
    );
    event IntentCancelled(
        bytes32 indexed intentId,
        address indexed cancelledBy
    );
    event IntentExpired(bytes32 indexed intentId);

    error IntentBase__NotFound(bytes32 intentId);
    error IntentBase__NotOpen(bytes32 intentId, IntentTypes.IntentStatus status);
    error IntentBase__Expired(bytes32 intentId, uint256 deadline);
    error IntentBase__Unauthorized(address caller);
    error IntentBase__NonceUsed(address creator, uint256 nonce);
    error IntentBase__InvalidDeadline(uint256 deadline);
}