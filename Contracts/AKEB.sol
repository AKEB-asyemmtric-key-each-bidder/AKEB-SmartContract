pragma solidity ^0.8.14;

contract AKEB {
    address auctioneer;
    address[] bidders;
    string public assetDescription;
    uint256 public minBidPrice;
    uint256 public minNumberOfBidders;

    constructor(string memory assetDescriptionInput, 
    uint256 minBidPriceInput, uint256 minNumberOfBiddersInput)
    {
        auctioneer = msg.sender;
        assetDescription = assetDescriptionInput;
        minBidPrice = minBidPriceInput;
        minNumberOfBidders = minNumberOfBiddersInput;
    }
}