// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IRevertLens } from "./IRevertLens.sol";

/// @title RevertLens
/// @notice Structured revert framework with on-chain context emission
/// @dev Inherit this contract to gain revertIf() helper
abstract contract RevertLens is IRevertLens {

    /// @notice Conditionally reverts with structured error data
    /// @dev Emits RevertContext before reverting for off-chain indexing.
    ///      Revert data = errorCode (4 bytes) ++ context (ABI-encoded args),
    ///      matching the format produced by `abi.encodeWithSelector`.
    /// @param condition If true, execution reverts
    /// @param errorCode 4-byte custom error selector (use MyError.selector)
    /// @param context ABI-encoded contextual data (use abi.encode(...))
    function revertIf(
        bool condition,
        bytes4 errorCode,
        bytes memory context
    ) internal {
        if (condition) {
            emit RevertContext(errorCode, msg.sender, context);

            bytes memory revertData = abi.encodePacked(errorCode, context);
            assembly {
                revert(add(revertData, 0x20), mload(revertData))
            }
        }
    }

    /// @notice Simplified revertIf without context data
    /// @param condition If true, execution reverts
    /// @param errorCode 4-byte custom error selector (use MyError.selector)
    function revertIf(bool condition, bytes4 errorCode) internal {
        if (condition) {
            emit RevertContext(errorCode, msg.sender, "");

            bytes memory revertData = abi.encodePacked(errorCode);
            assembly {
                revert(add(revertData, 0x20), mload(revertData))
            }
        }
    }
}
