// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { Guards } from "../../contracts/guards/Guards.sol";
import { IGuards } from "../../contracts/guards/IGuards.sol";

contract GuardsTest is Test {
    using Guards for uint256;
    using Guards for address;

    function test_notZero_uint256() public pure {
        uint256 val = 100.notZero();
        assertEq(val, 100);
    }

    function testRevert_notZero_uint256_zero() public {
        vm.expectRevert(IGuards.Guards__ZeroValue.selector);
        uint256(0).notZero();
    }

    function test_notZero_address() public pure {
        address addr = address(1).notZero();
        assertEq(addr, address(1));
    }

    function testRevert_notZero_address_zero() public {
        vm.expectRevert(IGuards.Guards__ZeroAddress.selector);
        address(0).notZero();
    }

    function test_notExpired() public {
        uint256 deadline = block.timestamp + 1 hours;
        uint256 result = deadline.notExpired();
        assertEq(result, deadline);
    }

    function testRevert_notExpired() public {
        uint256 deadline = block.timestamp - 1;
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__DeadlineExpired.selector, deadline, block.timestamp));
        deadline.notExpired();
    }

    function test_withinBounds() public pure {
        uint256 val = 50.withinBounds(0, 100);
        assertEq(val, 50);
    }

    function testRevert_withinBounds_belowMin() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__OutOfBounds.selector, 5, 10, 100));
        uint256(5).withinBounds(10, 100);
    }

    function testRevert_withinBounds_aboveMax() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__OutOfBounds.selector, 150, 10, 100));
        uint256(150).withinBounds(10, 100);
    }

    function test_equal() public pure {
        uint256 val = 42.equal(42);
        assertEq(val, 42);
    }

    function testRevert_equal() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__NotEqual.selector, 1, 2));
        uint256(1).equal(2);
    }

    function test_notContract() public view {
        // Test with EOA simulation if needed
    }

    function testRevert_notContract() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__ContractAddress.selector, address(this)));
        address(this).notContract();
    }

    function test_lengthMatch() public pure {
        Guards.lengthMatch(5, 5);
    }

    function testRevert_lengthMatch() public {
        vm.expectRevert(abi.encodeWithSelector(IGuards.Guards__LengthMismatch.selector, 3, 5));
        Guards.lengthMatch(3, 5);
    }

    function test_chaining() public pure {
        uint256 amount = 75;
        uint256 result = amount.notZero().withinBounds(1, 100).equal(75);
        assertEq(result, 75);
    }
}