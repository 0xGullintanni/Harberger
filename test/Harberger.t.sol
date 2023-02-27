// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Harberger.sol";

contract HarbergerTest is Test {
    Harberger public harberger;
    address internal bob = address(0x1);
    address internal alice = address(0x2);

    function setUp() public {
        vm.deal(bob, 100 ether);
        vm.deal(alice, 100 ether);

        //1% tax rate
        harberger = new Harberger(bob, 100, 1, 100);
    }

    function testHarbergerInit() public {
        assertEq(harberger.maxParcels(), 100);
        assertEq(harberger.landlord(), bob);
        assertEq(harberger.taxNumerator(), 1);
        assertEq(harberger.taxDenominator(), 100);
    }

   function testGetParcelWithoutOwner() public {
        Harberger.Parcel memory parcel = harberger.getParcel(0);
        assertEq(parcel.owner, address(0));
        assertEq(parcel.price, 0);
        assertEq(parcel.equity, 0);
        assertEq(parcel.lastPaid, 0);
   }

}
