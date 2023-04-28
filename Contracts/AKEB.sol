// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract AKEB {
    // Seller address
    address seller;
    // Asset information
    string public assetDescription;
    string public assetName;

    // Bidders address
    address[] public bidders;

    // Commited bids
    mapping(address => string) public encodedBids;

    // Winner struct consiting of address, bid, and nonce
    struct winner {
        address winnerAddress;
        uint256 bid;
        string nonce;
    }

    // Winner can be more than one
    winner[] public winners;

    // DisputedBidders struct 
    struct DisputedBidders {
        uint256 bid;
        address disputeAddress;
        string nonce;
    }

    DisputedBidders[] public disputedBidders;

    // // Modifier to assert only auctioneer perform certain actions
    // modifier assertOnlyAuctioneer() {
    //     require(msg.sender == seller, "Only auctioneer can call this function.");_;
    // }

    // // Modifier to assert only bidders perform certain actions
    // modifier assertOnlyBidders() {
    //     require(msg.sender != seller, "Auctioneer is not allowed to register as a bidder");_;
    // }

    // Registering auction infomation such as name and description of the asset
    function registerAuctionInfo(string memory assetNameInput, 
    string memory assetDescriptionInput) public
    {
        assetName = assetNameInput;
        assetDescription = assetDescriptionInput;
    }

    // Returning auction information
    function getAuctionInfo() public view returns(string memory, string memory) {
        return (assetName, assetDescription);
    }

    // Registering bidder address into bidders array
    function registerBidder() public {
        bidders.push(msg.sender);
    }

    // Getting disputers information. 
    // This information includes : 1.Disputer bid 2.Disputer nonce 3.Disputer address
    function getAllDisputers() public view returns(DisputedBidders[] memory){
        return disputedBidders;
    }

    // Bidders submit their encoded (Hashed or encrypted with private key) bid
    function submitEncodedBid(string memory inputEncodedBid)
    public {
        encodedBids[msg.sender] = inputEncodedBid;
    }

    // Winner calls this function to reveal her information
    function submitWinner(uint256 inputWinnerBid, 
    string memory inputwinnerNonce) public{
        winner memory temp = winner(msg.sender, inputWinnerBid, inputwinnerNonce);

        winners.push(temp);
    }

    // Returning all the winners' info including address, bid, and nonce
    function getAllWinners() public view returns(winner[] memory) {
        return winners;
    }

    // Bidder calls dispute and reveal her secret bid and nonce
    function dispute(uint256 inputDisputedBid, 
    string memory inputDisputedNonce) public {
        DisputedBidders memory disputedBidder = DisputedBidders(
            inputDisputedBid,
            msg.sender,
            inputDisputedNonce
        );

        disputedBidders.push(disputedBidder);
    }

    // This function is for reseting all variables for the next auction round
    function reset() public {
        delete winners;

        assetDescription = "";
        assetName = "";

        resetEncodedBids();

        delete bidders;

        delete disputedBidders;
    }

    // This function is for reseting encodedBids varibale
    function resetEncodedBids() public {
        for (uint256 i = 0 ; i < bidders.length; i +=1){
            address bidderAddress = bidders[i];
            delete encodedBids[bidderAddress];
        }
    }
}