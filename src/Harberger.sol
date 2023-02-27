// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Context } from './Context.sol';

contract Harberger is Context {
    address public landlord;
    uint256 public taxNumerator;
    uint256 public taxDenominator;
    uint8 public maxParcels;
    
    Parcel[100] public parcels;

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

    modifier onlyParcelOwner(uint8 parcelIndexl) {
        Parcel storage parcel = parcels[parcelIndex];
        require(_msgSender() == parcel.owner, "Harberger: caller is not the parcel owner");
        _;
    }

    constructor(address _landlord, uint8 _maxParcels, uint _taxNumerator, uint _taxDenominator) {
        require(_landlord != address(0), "Harberger: landlord is the zero address");
        require(_maxParcels > 0 && _maxParcels <= 100, "Harberger: maxParcels must be greater than 0");
        require(_taxNumerator > 0 && _taxDenominator > 0, "Harberger: taxNumerator and taxDenominator must be greater than 0");

        landlord = _landlord;
        maxParcels = _maxParcels;
        taxNumerator = _taxNumerator;
        taxDenominator = _taxDenominator;
    }

    //for buying a parcel with no owner
    function buyParcel(uint8 parcelIndex) public payable {
        require(parcelIndex < maxParcels, "Harberger: parcelIndex is out of bounds");
        Parcel storage parcel = parcels[parcelIndex];
        
        require(parcel.owner == address(0), "Harberger: parcel is already owned");
        require(msg.value >= parcel.price, "Harberger: msg.value does not match parcel price");

        parcel.owner = _msgSender();
        parcel.lastPaid = block.timestamp;
        parcel.equity = msg.value;
    }

    //for setting the price for an owned parcel
    function setParcelPrice(uint8 parcelIndex) public onlyParcelOwner(parcelIndex) {}

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