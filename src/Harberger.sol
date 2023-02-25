// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Context } from './Context.sol';

contract Harberger is Context {
    address public landlord;
    uint256 public taxNumerator;
    uint256 public taxDenominator;

    struct Parcel {
        address owner;
        uint256 price;
        uint256 equity;
        uint256 lastPaid;
    }

    modifier onlyLandlord() {
        require(_msgSender() == landlord, "Harberger: caller is not the landlord");
        _;
    }

    modifier onlyParcelOwner(Parcel memory parcel) {
        require(_msgSender() == parcel.owner, "Harberger: caller is not the parcel owner");
        _;
    }

    constructor() {}

    //for buying a parcel with no owner
    function buyParcel() public payable {}

    //for setting the price for an owned parcel
    function setParcelPrice(Parcel memory parcel) public onlyParcelOwner(parcel) {}

    //for determining the amount of taxes owed for a particular parcel
    function taxesDue() public view {}

    //for depositing funds to pay taxes
    function depositEquity(Parcel memory parcel) public payable onlyParcelOwner(parcel) {}

    //for withdrawing funds from a parcel
    function withdrawEquity(Parcel memory parcel) public onlyParcelOwner(parcel) {}

    //for transfering ownership of a parcel
    function transferParcel() public {}

    //for collecting taxes by withdrawing equity from parcel
    function collectTaxes() public onlyLandlord {}

    //for closing out a parcel if it has no equity
    function foreCloseIfPossible() public onlyLandlord {}

    //for getting a particular parcel
    function getParcel() public view {}

}