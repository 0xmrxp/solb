// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { RevertLens } from "../../contracts/revert/RevertLens.sol";
import { IRevertLens } from "../../contracts/revert/IRevertLens.sol";

contract RevertLensTest is Test, RevertLens {
    error TestError(uint256 value);

    RevertLensCaller callerLens;

    function setUp() public {
        callerLens = new RevertLensCaller();
    }

    function test_RevertIf_False_NoRevert() public {
        // Should not revert or emit
        revertIf(false, TestError.selector);
    }

    function test_RevertIf_True_WithContext() public {
        bytes memory context = abi.encode(123);

        vm.expectEmit(true, true, false, true);
        emit RevertContext(TestError.selector, address(this), context);

        vm.expectRevert(abi.encodeWithSelector(TestError.selector, 123));
        callerLens.trigger(true, TestError.selector, context);
    }

    function test_RevertIf_True_NoContext() public {
        vm.expectEmit(true, true, false, true);
        emit RevertContext(TestError.selector, address(this), "");

        vm.expectRevert(TestError.selector);
        callerLens.triggerNoContext(true, TestError.selector);
    }
}

/// @notice External wrapper so reverts occur at a CALL frame depth
///         that `vm.expectRevert` can intercept correctly.
contract RevertLensCaller is RevertLens {
    error TestError(uint256 value);

    function trigger(bool condition, bytes4 errorCode, bytes memory context) external {
        revertIf(condition, errorCode, context);
    }

    function triggerNoContext(bool condition, bytes4 errorCode) external {
        revertIf(condition, errorCode);
    }
}
