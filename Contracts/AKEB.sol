// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract AKEB {
    address seller;
    string public assetDescription;
    string public assetName;

    address[] public bidders;

    mapping(address => string) public encodedBids;

    struct winner {
        address winnerAddress;
        uint256 bid;
        string nonce;
    }

    winner[] public winners;

    struct DisputedBidders {
        uint256 bid;
        address disputeAddress;
        string nonce;
    }

    DisputedBidders[] public disputedBidders;

    modifier assertOnlyAuctioneer() {
        require(msg.sender == seller, "Only auctioneer can call this function.");_;
    }

    modifier assertOnlyBidders() {
        require(msg.sender != seller, "Auctioneer is not allowed to register as a bidder");_;
    }

    function registerAuctionInfo(string memory assetNameInput, 
    string memory assetDescriptionInput) public
    {
        assetName = assetNameInput;
        assetDescription = assetDescriptionInput;
    }

    function getAuctionInfo() public view returns(string memory, string memory) {
        return (assetName, assetDescription);
    }

    function registerBidder() public {
        bidders.push(msg.sender);
    }

    function getBidderAddress(uint index) public view returns(address) {
        return bidders[index];
    }

    function getAllBidders() public view returns(address[] memory) {
        return bidders;
    }

    function getAllDisputers() public view returns(DisputedBidders[] memory){
        return disputedBidders;
    }

    function submitEncodedBid(string memory inputEncodedBid)
    public {
        encodedBids[msg.sender] = inputEncodedBid;
    }

    function getEncodedBid(address inputAddress) public view returns(string memory){
        return encodedBids[inputAddress];
    }

    function submitWinner(uint256 inputWinnerBid, 
    string memory inputwinnerNonce) public{
        winner memory temp = winner(msg.sender, inputWinnerBid, inputwinnerNonce);

        winners.push(temp);
    }

    function getAllWinners() public view returns(winner[] memory) {
        return winners;
    }

    function dispute(uint256 inputDisputedBid, 
    string memory inputDisputedNonce) public {
        DisputedBidders memory disputedBidder = DisputedBidders(
            inputDisputedBid,
            msg.sender,
            inputDisputedNonce
        );

        disputedBidders.push(disputedBidder);
    }

    function reset() public {
        delete winners;

        assetDescription = "";
        assetName = "";

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