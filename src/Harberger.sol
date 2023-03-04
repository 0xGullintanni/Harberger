// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721 } from './ERC721.sol';

contract Harberger is ERC721 {
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

    modifier onlyValidIndex(uint8 parcelIndex) {
        require(parcelIndex < maxParcels, "Harberger: parcelIndex is out of bounds");
        _;
    }

    modifier onlyLandlord() {
        require(_msgSender() == landlord, "Harberger: caller is not the landlord");
        _;
    }

    modifier onlyParcelOwner(uint8 parcelIndex) {
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
    function buyParcel(uint8 parcelIndex, uint price) public payable onlyValidIndex(parcelIndex) {
        Parcel storage parcel = parcels[parcelIndex];
        
        require(parcel.owner == address(0), "Harberger: parcel is already owned");
        require(msg.value >= parcel.price, "Harberger: msg.value does not match parcel price");

        parcel.owner = _msgSender();
        parcel.lastPaid = block.timestamp;
        parcel.equity = msg.value;
        parcel.price = price;
    }

    //for determining the amount of taxes owed for a particular parcel
    function taxesDue(uint8 parcelIndex) public view onlyValidIndex(parcelIndex) returns (uint256){
        require(parcelIndex < maxParcels, "Harberger: parcelIndex is out of bounds");
        Parcel storage parcel = parcels[parcelIndex];

        uint256 timePassed = (block.timestamp - parcel.lastPaid) / 1 days;
        uint256 taxDue = (parcel.price * timePassed * taxNumerator) / taxDenominator;

        return taxDue;
    }

    //for depositing funds to pay taxes
    function depositEquity(uint8 parcelIndex) public payable onlyValidIndex(parcelIndex) {
        Parcel storage parcel = parcels[parcelIndex];
        parcel.equity += msg.value;

        uint taxDue = taxesDue(parcelIndex);
        if(msg.value >= taxDue) {
            parcel.lastPaid = block.timestamp;
        }
    }

    //for withdrawing funds from a parcel
    function withdrawEquity(uint8 parcelIndex) public onlyParcelOwner(parcelIndex) {
        Parcel storage parcel = parcels[parcelIndex];

        uint taxDue = taxesDue(parcelIndex);
        require(parcel.equity >= taxDue, "Harberger: equity is less than tax due");

        uint equity = parcel.equity;
        uint equityAfterTaxPayment = equity - taxDue;
        parcel.equity = 0;

        payable(address(this)).transfer(taxDue);
        if(equity > 0) {
            payable(_msgSender()).transfer(equityAfterTaxPayment);
        } 
    }

    //for transfering ownership of a parcel
    function transferParcel(uint8 parcelIndex, uint price) public payable onlyValidIndex(parcelIndex) {
        Parcel storage parcel = parcels[parcelIndex];
        require(msg.value >= parcel.price, "Harberger: msg.value does not match parcel price");

        uint256 equity = parcel.equity;
        parcel.equity = 0;
        parcel.owner = _msgSender();
        parcel.lastPaid = block.timestamp;
        parcel.equity = msg.value;
        parcel.price = price;

        payable(parcel.owner).transfer(equity);
    }

    //for collecting taxes by withdrawing equity from parcel
    function collectTaxes() public onlyLandlord {
        for(uint8 i = 0; i < maxParcels; i++) {
            Parcel storage parcel = parcels[i];
            uint256 taxDue = taxesDue(i);
            if(parcel.equity >= taxDue) {
                parcel.equity -= taxDue;
                parcel.lastPaid = block.timestamp;
                payable(address(this)).transfer(taxDue);
            } else {
                foreCloseIfPossible(i);
            }
        }
    }

    //for closing out a parcel if it has no equity
    function foreCloseIfPossible(uint8 parcelIndex) public onlyValidIndex(parcelIndex) {
        Parcel storage parcel = parcels[parcelIndex];
        uint equity = parcel.equity;

        parcel.owner = address(0);
        parcel.price = 0;
        parcel.lastPaid = 0;
        parcel.equity = 0;

        payable(address(this)).transfer(equity);
    }

    //for getting a particular parcel
    function getParcel(uint8 parcelIndex) public view onlyValidIndex(parcelIndex) returns (Parcel memory) {
        Parcel storage parcel = parcels[parcelIndex];
        
        return parcel;
    }

    function withdraw() public onlyLandlord {
        payable(landlord).transfer(address(this).balance);
    }
}