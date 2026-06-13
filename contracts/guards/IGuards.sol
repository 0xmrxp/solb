// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IGuards
/// @notice Interface for Guards library custom errors
interface IGuards {
    /// @notice Thrown when a value expected to be non-zero is zero
    error Guards__ZeroValue();

    /// @notice Thrown when an address expected to be non-zero is zero address
    error Guards__ZeroAddress();

    /// @notice Thrown when a deadline has passed
    /// @param deadline The deadline that was passed
    /// @param currentTime The current block timestamp
    error Guards__DeadlineExpired(uint256 deadline, uint256 currentTime);

    /// @notice Thrown when a value is outside allowed bounds
    /// @param value The value that was out of bounds
    /// @param min Minimum allowed value
    /// @param max Maximum allowed value
    error Guards__OutOfBounds(uint256 value, uint256 min, uint256 max);

    /// @notice Thrown when an address is a contract but EOA was expected
    /// @param addr The contract address
    error Guards__ContractAddress(address addr);

    /// @notice Thrown when two values expected to be equal are not
    /// @param a First value
    /// @param b Second value
    error Guards__NotEqual(uint256 a, uint256 b);

    /// @notice Thrown when array length does not match expected length
    /// @param actual Actual length
    /// @param expected Expected length
    error Guards__LengthMismatch(uint256 actual, uint256 expected);
}