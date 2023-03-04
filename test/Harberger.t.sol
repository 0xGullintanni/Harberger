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

   function testBuyParcel() public {
        vm.prank(alice);
        harberger.buyParcel{value: 1 ether }(0, 5 ether);

        Harberger.Parcel memory parcel = harberger.getParcel(0);
        assertEq(parcel.owner, alice);
        assertEq(parcel.price, 5 ether);
        assertEq(parcel.equity, 1 ether);
        assertEq(parcel.lastPaid, block.timestamp);
   }

   function testTaxesDue() public {
        vm.prank(alice);
        harberger.buyParcel{value: 1 ether }(0, 5 ether);

        Harberger.Parcel memory parcel = harberger.getParcel(0);
        assertEq(parcel.owner, alice);
        assertEq(parcel.price, 5 ether);
        assertEq(parcel.equity, 1 ether);
        assertEq(parcel.lastPaid, block.timestamp);

        //Forward block.timestamp by 7 days and take taxes due fo the week
        vm.warp(8 days);
        uint256 taxesDue = harberger.taxesDue(0);
        console2.log("taxesDue: %s", taxesDue);

        //If price is 5 ether and tax rate is 1% per day, then after 7 days have passed, taxesDue should be .35 ether
        assertEq(taxesDue, .35 ether); 
   }

   function testDepositEquityGreaterThanTaxDue() public {
        vm.prank(alice);
        harberger.buyParcel{value: 1 ether }(0, 5 ether);

        Harberger.Parcel memory parcel = harberger.getParcel(0);
        assertEq(parcel.owner, alice);
        assertEq(parcel.price, 5 ether);
        assertEq(parcel.equity, 1 ether);
        assertEq(parcel.lastPaid, block.timestamp);

        vm.warp(3 days);

        vm.prank(alice);
        harberger.depositEquity{value: 1 ether }(0);

        Harberger.Parcel memory parcelAfterDeposit = harberger.getParcel(0);
        assertEq(parcelAfterDeposit.owner, alice);
        assertEq(parcelAfterDeposit.price, 5 ether);
        assertEq(parcelAfterDeposit.equity, 2 ether);
        assertEq(parcelAfterDeposit.lastPaid, block.timestamp);
   }

   function testDepositEquityLessThanTaxDue() public {
        vm.prank(alice);
        harberger.buyParcel{value: 1 ether }(0, 5 ether);

        Harberger.Parcel memory parcelBeforeDeposit = harberger.getParcel(0);
        assertEq(parcelBeforeDeposit.owner, alice);
        assertEq(parcelBeforeDeposit.price, 5 ether);
        assertEq(parcelBeforeDeposit.equity, 1 ether);
        assertEq(parcelBeforeDeposit.lastPaid, block.timestamp);

        vm.warp(3 days);

        vm.prank(alice);
        harberger.depositEquity{value: .01 ether }(0);

        Harberger.Parcel memory parcelAfterDeposit = harberger.getParcel(0);
        assertEq(parcelAfterDeposit.owner, alice);
        assertEq(parcelAfterDeposit.price, 5 ether);
        assertEq(parcelAfterDeposit.equity, 1.01 ether);
        assertEq(parcelAfterDeposit.lastPaid, parcelBeforeDeposit.lastPaid);
   }

   function testWithdrawEtherBeforeTaxesDue() public {
         vm.prank(alice);
        harberger.buyParcel{value: 1 ether }(0, 5 ether);

        
   }

}
