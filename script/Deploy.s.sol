// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

/// @title Deploy
/// @notice Example deployment script for solb modules.
/// @dev solb modules are libraries/abstract contracts meant to be
///      imported and inherited, not deployed standalone. This script
///      is provided as a usage reference only.
contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // solb is a library — there is nothing to deploy directly.
        // Consumers inherit/import these contracts into their own
        // deployable contracts. This script is left as a placeholder
        // for future deployable example contracts.

        vm.stopBroadcast();
    }
}
