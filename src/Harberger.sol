// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Harberger {
    struct Parcel {
        address owner;
    }

    modifier onlyLandlord() {
        _;
    }

    modifier onlyParcelOwner() {
        _;
    }

    constructor() {}

    //for buying a parcel with no owner
    function buyParcel() public payable {}

    //for setting the price for an owned parcel
    function setParcelPrice() public onlyParcelOwner {}

    //for determining the amount of taxes owed for a particular parcel
    function taxesDue() public view {}

    //for depositing funds to pay taxes
    function depositEquity() public payable onlyParcelOwner {}

    //for withdrawing funds from a parcel
    function withdrawEquity() public onlyParcelOwner {}

    //for transfering ownership of a parcel
    function transferParcel() public {}

    //for collecting taxes by withdrawing equity from parcel
    function collectTaxes() public onlyLandlord {}

    //for closing out a parcel if it has no equity
    function foreCloseIfPossible() public onlyLandlord {}

    //for getting a particular parcel
    function getParcel() public view {}

}