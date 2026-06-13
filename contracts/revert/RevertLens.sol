// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IRevertLens } from "./IRevertLens.sol";

/// @title RevertLens
/// @notice Structured revert framework with on-chain context emission
/// @dev Inherit this contract to gain revertIf() helper
abstract contract RevertLens is IRevertLens {

    /// @notice Conditionally reverts with structured error data
    /// @dev Emits RevertContext before reverting for off-chain indexing
    /// @param condition If true, execution reverts
    /// @param errorCode 4-byte custom error selector (use type(MyError).selector)
    /// @param context ABI-encoded contextual data (use abi.encode(...))
    function revertIf(
        bool condition,
        bytes4 errorCode,
        bytes memory context
    ) internal {
        if (condition) {
            emit RevertContext(errorCode, msg.sender, context);
            assembly {
                revert(add(context, 0x20), mload(context))
            }
        }
    }

    /// @notice Simplified revertIf without context data
    function revertIf(bool condition, bytes4 errorCode) internal {
        if (condition) {
            emit RevertContext(errorCode, msg.sender, "");
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, errorCode);
                revert(ptr, 4);
            }
        }
    }
}
