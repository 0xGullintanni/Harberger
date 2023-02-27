// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Harberger.sol";

contract HarbergerTest is Test {
    Harberger public harberger;
    address internal bob = address(0x1);

    function setUp() public {
        harberger = new Harberger(bob, 1, 2, 1);
        assertEq(harberger.maxParcels(), 1);
        assertEq(harberger.landlord(), bob);
    }
}
