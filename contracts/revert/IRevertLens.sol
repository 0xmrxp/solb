// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IRevertLens
/// @notice Interface for structured revert framework
interface IRevertLens {
    /// @notice Emitted just before a revert, carrying full context
    /// @param errorCode The 4-byte error selector
    /// @param caller Address that triggered the revert
    /// @param context ABI-encoded contextual data about the failure
    event RevertContext(
        bytes4 indexed errorCode,
        address indexed caller,
        bytes context
    );
}
