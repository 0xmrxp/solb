// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IGuards } from "./IGuards.sol";

/// @title Guards
/// @notice Defensive programming primitives via library-on-type pattern
/// @dev Use with: using Guards for uint256; using Guards for address;
library Guards {

    // ─────────────────────────────────────────────
    // uint256 Guards
    // ─────────────────────────────────────────────

    /// @notice Reverts if value is zero
    /// @param value The value to check
    /// @return value The original value (for chaining)
    function notZero(uint256 value) internal pure returns (uint256) {
        if (value == 0) revert IGuards.Guards__ZeroValue();
        return value;
    }

    /// @notice Reverts if current timestamp has passed deadline
    /// @param deadline Unix timestamp deadline
    /// @return deadline The original deadline (for chaining)
    function notExpired(uint256 deadline) internal view returns (uint256) {
        if (block.timestamp > deadline)
            revert IGuards.Guards__DeadlineExpired(deadline, block.timestamp);
        return deadline;
    }

    /// @notice Reverts if value is outside [min, max] inclusive
    /// @param value The value to check
    /// @param min Minimum allowed value (inclusive)
    /// @param max Maximum allowed value (inclusive)
    /// @return value The original value (for chaining)
    function withinBounds(
        uint256 value,
        uint256 min,
        uint256 max
    ) internal pure returns (uint256) {
        if (value < min || value > max)
            revert IGuards.Guards__OutOfBounds(value, min, max);
        return value;
    }

    /// @notice Reverts if a != b
    /// @param a First value
    /// @param b Second value
    /// @return a The original value (for chaining)
    function equal(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a != b) revert IGuards.Guards__NotEqual(a, b);
        return a;
    }

    // ─────────────────────────────────────────────
    // address Guards
    // ─────────────────────────────────────────────

    /// @notice Reverts if address is zero address
    /// @param addr The address to check
    /// @return addr The original address (for chaining)
    function notZero(address addr) internal pure returns (address) {
        if (addr == address(0)) revert IGuards.Guards__ZeroAddress();
        return addr;
    }

    /// @notice Reverts if address has deployed bytecode (is a contract)
    /// @param addr The address to check
    /// @return addr The original address (for chaining)
    function notContract(address addr) internal view returns (address) {
        if (addr.code.length > 0)
            revert IGuards.Guards__ContractAddress(addr);
        return addr;
    }

    // ─────────────────────────────────────────────
    // Array Guards
    // ─────────────────────────────────────────────

    /// @notice Reverts if array length does not match expected
    /// @param actual Actual length
    /// @param expected Expected length
    function lengthMatch(
        uint256 actual,
        uint256 expected
    ) internal pure {
        if (actual != expected)
            revert IGuards.Guards__LengthMismatch(actual, expected);
    }
}