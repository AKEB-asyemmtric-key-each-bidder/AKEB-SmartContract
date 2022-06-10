// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract AKEB {
    address auctioneer;
    address[] public bidders;
    string public assetDescription;
    uint256 public minBidPrice;
    uint256 public minNumberOfBidders;
    mapping(address => string) public publicKeys;

    constructor()
    {
        auctioneer = msg.sender;
    }

    modifier checkAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can call this function.");_;
    }

    modifier noAuctioneerInBidderRegistering() {
        require(msg.sender != auctioneer, "Auctioneer is not allowed to register as a bidder");_;
    }

    function registerAuctionInfo(string memory assetDescriptionInput, 
    uint256 minBidPriceInput, uint256 minNumberOfBiddersInput) 
    public checkAuctioneer()
    {
        assetDescription = assetDescriptionInput;
        minBidPrice = minBidPriceInput;
        minNumberOfBidders = minNumberOfBiddersInput;
    }

    function registerBidder() public noAuctioneerInBidderRegistering() {
        bidders.push(msg.sender);
    }

    function submitPublicKeys(address inputAddress, string memory inputPublicKey) public{
        publicKeys[inputAddress] = inputPublicKey;
    }
}