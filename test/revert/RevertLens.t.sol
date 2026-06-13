// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { RevertLens } from "../../contracts/revert/RevertLens.sol";
import { IRevertLens } from "../../contracts/revert/IRevertLens.sol";

contract RevertLensTest is Test, RevertLens {
    event RevertContext(
        bytes4 indexed errorCode,
        address indexed caller,
        bytes context
    );

    error TestError(uint256 value);

    function test_RevertIf_False_NoRevert() public {
        // Should not revert or emit
        revertIf(false, TestError.selector);
    }

    function test_RevertIf_True_WithContext() public {
        bytes memory context = abi.encode(123);

        vm.expectEmit(true, true, false, true);
        emit RevertContext(TestError.selector, address(this), context);

        vm.expectRevert(abi.encodeWithSelector(TestError.selector, 123));
        revertIf(true, TestError.selector, context);
    }

    function test_RevertIf_True_NoContext() public {
        vm.expectEmit(true, true, false, true);
        emit RevertContext(TestError.selector, address(this), "");

        vm.expectRevert(TestError.selector);
        revertIf(true, TestError.selector);
    }
}
