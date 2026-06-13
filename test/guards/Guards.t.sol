// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { Guards } from "../../contracts/guards/Guards.sol";
import { IGuards } from "../../contracts/guards/IGuards.sol";

contract GuardsTest is Test {
    using Guards for uint256;
    using Guards for address;

    GuardsCaller caller_;

    function setUp() public {
        caller_ = new GuardsCaller();
    }

    function test_notZero_uint256() public pure {
        uint256 val = uint256(100).notZero();
        assertEq(val, 100);
    }

    function testRevert_notZero_uint256_zero() public {
        vm.expectRevert(IGuards.Guards__ZeroValue.selector);
        caller_.notZeroUint(0);
    }

    function test_notZero_address() public pure {
        address addr = address(1).notZero();
        assertEq(addr, address(1));
    }

    function testRevert_notZero_address_zero() public {
        vm.expectRevert(IGuards.Guards__ZeroAddress.selector);
        caller_.notZeroAddress(address(0));
    }

    function test_notExpired() public {
        uint256 deadline = block.timestamp + 1 hours;
        uint256 result = deadline.notExpired();
        assertEq(result, deadline);
    }

    function testRevert_notExpired() public {
        uint256 deadline = block.timestamp - 1;
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__DeadlineExpired.selector, deadline, block.timestamp));
        caller_.notExpired(deadline);
    }

    function test_withinBounds() public pure {
        uint256 val = uint256(50).withinBounds(0, 100);
        assertEq(val, 50);
    }

    function testRevert_withinBounds_belowMin() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__OutOfBounds.selector, 5, 10, 100));
        caller_.withinBounds(5, 10, 100);
    }

    function testRevert_withinBounds_aboveMax() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__OutOfBounds.selector, 150, 10, 100));
        caller_.withinBounds(150, 10, 100);
    }

    function test_equal() public pure {
        uint256 val = uint256(42).equal(42);
        assertEq(val, 42);
    }

    function testRevert_equal() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__NotEqual.selector, 1, 2));
        caller_.equal(1, 2);
    }

    function test_notContract() public view {
        // address(1) has no deployed bytecode -> should pass through unchanged
        address addr = address(1).notContract();
        assertEq(addr, address(1));
    }

    function testRevert_notContract() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__ContractAddress.selector, address(this)));
        caller_.notContract(address(this));
    }

    function test_lengthMatch() public pure {
        Guards.lengthMatch(5, 5);
    }

    function testRevert_lengthMatch() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__LengthMismatch.selector, 3, 5));
        caller_.lengthMatch(3, 5);
    }

    function test_chaining() public pure {
        uint256 amount = 75;
        uint256 result = amount.notZero().withinBounds(1, 100).equal(75);
        assertEq(result, 75);
    }
}

/// @notice External wrapper so reverts occur at a CALL frame depth
///         that `vm.expectRevert` can intercept correctly.
contract GuardsCaller {
    using Guards for uint256;
    using Guards for address;

    function notZeroUint(uint256 v) external pure returns (uint256) {
        return v.notZero();
    }

    function notZeroAddress(address a) external pure returns (address) {
        return a.notZero();
    }

    function notExpired(uint256 deadline) external view returns (uint256) {
        return deadline.notExpired();
    }

    function withinBounds(uint256 v, uint256 min, uint256 max) external pure returns (uint256) {
        return v.withinBounds(min, max);
    }

    function equal(uint256 a, uint256 b) external pure returns (uint256) {
        return a.equal(b);
    }

    function notContract(address a) external view returns (address) {
        return a.notContract();
    }

    function lengthMatch(uint256 actual, uint256 expected) external pure {
        Guards.lengthMatch(actual, expected);
    }
}
