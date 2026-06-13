// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IntentTypes
/// @notice Shared structs and enums for intent-based systems
library IntentTypes {

    enum IntentStatus {
        OPEN,       // 0: Active, can be filled or cancelled
        FILLED,     // 1: Successfully executed
        CANCELLED,  // 2: Cancelled by creator or protocol
        EXPIRED     // 3: Deadline passed without fill
    }

    struct IntentParams {
        address creator;        // Who created this intent
        address filler;         // Allowed filler (address(0) = open to anyone)
        uint256 deadline;       // Unix timestamp expiry
        uint256 nonce;          // Unique per-creator nonce
        bytes data;             // Protocol-specific payload
    }

    struct Intent {
        IntentParams params;
        IntentStatus status;
        uint256 createdAt;
        address filledBy;       // Address that filled (if FILLED)
        uint256 filledAt;       // Timestamp of fill (if FILLED)
    }
}