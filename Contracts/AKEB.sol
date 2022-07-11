// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract AKEB {
    address auctioneer;
    address[] public bidders;
    string public assetDescription;
    uint256 public minBidPrice;
    uint256 public minNumberOfBidders;

    mapping(address => string) public encodedBids;

    address public winnerAddress;
    uint256 public winnerBid;
    string public winnerKey;

    struct DisputedBidders {
        uint256 bid;
        address disputeAddress;
        string key;
    }

    DisputedBidders[] public disputedBidders;

    modifier assertOnlyAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can call this function.");_;
    }

    modifier assertOnlyBidders() {
        require(msg.sender != auctioneer, "Auctioneer is not allowed to register as a bidder");_;
    }

    function getSampleString() public pure returns(string memory){
        return "sample string from AKEB";
    }

    function registerAuctionInfo(string memory assetDescriptionInput, 
    uint256 minBidPriceInput, uint256 minNumberOfBiddersInput) 
    public assertOnlyAuctioneer()
    {
        assetDescription = assetDescriptionInput;
        minBidPrice = minBidPriceInput;
        minNumberOfBidders = minNumberOfBiddersInput;
    }

    function registerBidder() public {
        bidders.push(msg.sender);
    }

    function getBidderAddress(uint index) public view returns(address) {
        return bidders[index];
    }

    function submitEncryptedBid(string memory inputEncodedBid)
    public {
        encodedBids[msg.sender] = inputEncodedBid;
    }

    function getEncodedBid(address inputAddress) public view returns(string memory){
        return encodedBids[inputAddress];
    }

    function submitWinner(uint256 inputWinnerBid, 
    string memory inputWinnerKey) public{
        winnerAddress = msg.sender;
        winnerBid = inputWinnerBid;
        winnerKey = inputWinnerKey;
    }

    function getWinnerAddress() public view returns(address) {
        return winnerAddress;
    }

    function getWinnerBid() public view returns(uint256) {
        return winnerBid;
    }

    function getWinnerKey() public view returns(string memory){
        return winnerKey;
    }

    function dispute(uint256 inputDisputedBid, 
    string memory inputDisputedKey) public {
        DisputedBidders memory disputedBidder = DisputedBidders(
            inputDisputedBid,
            msg.sender,
            inputDisputedKey
        );

        disputedBidders.push(disputedBidder);
    }

    function reset() public {
        winnerAddress =  0x0000000000000000000000000000000000000000;
        winnerBid = 0;
        winnerKey = "";

        assetDescription = "";
        minBidPrice = 0;
        minNumberOfBidders = 0;

        resetEncodedBids();
        
        delete bidders;

        delete disputedBidders;
    }

    function resetEncodedBids() public {
        for (uint256 i = 0 ; i < bidders.length; i +=1){
            address bidderAddress = bidders[i];
            delete encodedBids[bidderAddress];
        }
    }
}