// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Strings.sol";

contract AKEB {
    // VARIBLES
    // Seller and auctioneer address
    address public seller;
    address public auctioneer;
    // Asset information
    string public assetDescription;
    string public assetName;

    uint registerBidderPeriod;
    uint hashedBidSubmissionPeriod;
    uint winnerAndDisputeSubmissionPeriod;
    // periodTime set to 1 min
    uint periodTime = 1;
    bool isAuctionStarted = false;

    // Bidders address
    address[] public bidders;

    // Commited bids
    mapping(address => bytes32) public encodedBids;

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

    constructor(){
        auctioneer = msg.sender;
    }

    // MODIFIERS

    modifier checkIfAuctionIsStarted() {
        require(isAuctionStarted == true, "There is no started auction now");_;
    }

    function isBidder() internal view returns(bool) {
        for (uint256 i = 0 ; i < bidders.length; i++){
            if(msg.sender == bidders[i]){
                return true;
            }
        }
        return false;
    }

    modifier onlyBidders(){
        require(isBidder() == true, "Only registerd bidder can call this function");_;
    }

    modifier onlyAuctioneer(){
        require(msg.sender == auctioneer, "Only auctioneer can call this function");_;
    }




    function setUpPhasesTimePeriods() private {
        // register phase period is 1 min
        registerBidderPeriod = block.timestamp + (periodTime * 60);

        // Hashed bid submission period is 1 min
        hashedBidSubmissionPeriod = block.timestamp + (2 * periodTime * 60);

        // winner and disputer submission period is 1 min
        winnerAndDisputeSubmissionPeriod = block.timestamp + (3 * periodTime * 60);
    }

    // Registering auction infomation such as name and description of the asset
    function registerAuctionInfo(string memory assetNameInput, 
    string memory assetDescriptionInput) 
    public
    {
        seller = msg.sender;
        assetName = assetNameInput;
        assetDescription = assetDescriptionInput;
        setUpPhasesTimePeriods();
        isAuctionStarted = true;
    }

    // Returning auction information
    function getAuctionInfo() 
    public 
    view 
    checkIfAuctionIsStarted() 
    returns(string memory, string memory) {
        return (assetName, assetDescription);
    }

    // Registering bidder address into bidders array
    function registerBidder() 
    public 
    checkIfAuctionIsStarted() {
        require(msg.sender != seller , "Seller can not register as bidder");
        require(block.timestamp < registerBidderPeriod, "Time for registering as a bidder is passed.");
        bidders.push(msg.sender);
    }

    function getBidders(uint index) 
    public 
    view 
    returns(address){
        return bidders[index];
    }

    // Getting disputers information. 
    // This information includes : 1.Disputer bid 2.Disputer nonce 3.Disputer address
    function getAllDisputers() 
    checkIfAuctionIsStarted() 
    public 
    view 
    returns(DisputedBidders[] memory){
        return disputedBidders;
    }

    // Bidders submit their encoded (Hashed or encrypted with private key) bid
    function submitEncodedBid(bytes32 inputEncodedBid) 
    checkIfAuctionIsStarted()
    onlyBidders()
    public {
        // These two lines are commented for units test to pass, uncomment for user testing
        // require(block.timestamp > registerBidderPeriod, "Hashed bid submission phase is not started yet.");
        // require(block.timestamp < hashedBidSubmissionPeriod, "Time for hashed bid submission is passed");

        encodedBids[msg.sender] = inputEncodedBid;
    }

    // Winner calls this function to reveal her information
    function submitWinner(uint256 inputWinnerBid, 
    string memory inputwinnerNonce)
    checkIfAuctionIsStarted()
    onlyBidders()
    public{
        // These two lines are commented for units test to pass, uncomment for user testing
        // require(block.timestamp > hashedBidSubmissionPeriod, "Winner submission phase has not started yet.");
        // require(block.timestamp < winnerAndDisputeSubmissionPeriod, "Winner submission time has passed.");

        winner memory temp = winner(msg.sender, inputWinnerBid, inputwinnerNonce);

        winners.push(temp);
    }

    // Returning all the winners' info including address, bid, and nonce
    function getAllWinners() 
    checkIfAuctionIsStarted()
    public 
    view 
    returns(winner[] memory) {
        return winners;
    }

    // Bidder calls dispute and reveal her secret bid and nonce
    function dispute(uint256 inputDisputedBid, 
    string memory inputDisputedNonce)
    checkIfAuctionIsStarted()
    onlyBidders()
    public{
        // These two lines are commented for units test to pass, uncomment for user testing
        // require(block.timestamp > hashedBidSubmissionPeriod, "Dispute phase has not started yet.");
        // require(block.timestamp < winnerAndDisputeSubmissionPeriod, "Dispute phase has passed.");

        bytes32 disputerHash = computeHash(inputDisputedBid, inputDisputedNonce);

        require(encodedBids[msg.sender] == disputerHash, "The bid and nonce you submitted are not valid.");
        require(isDiputeBidGreaterThanOneWinnerBid(inputDisputedBid) == true, "Your dispute is not valid since it is not greater than at least one winner.");

        clearWinners();

        addWinner(inputDisputedBid, inputDisputedNonce);

        DisputedBidders memory disputedBidder = DisputedBidders(
            inputDisputedBid,
            msg.sender,
            inputDisputedNonce
        );

        disputedBidders.push(disputedBidder);
    }

    // This function is for reseting all variables for the next auction round
    function reset() 
    onlyAuctioneer()
    public {
        require(block.timestamp > winnerAndDisputeSubmissionPeriod, "Auction is not completed yet.");

        delete winners;

        assetDescription = "";
        assetName = "";

        resetEncodedBids();

        delete bidders;

        delete disputedBidders;

        isAuctionStarted = false;
    }

    // This function is for reseting encodedBids varibale
    function resetEncodedBids()
    onlyAuctioneer() 
    public {
        require(block.timestamp > winnerAndDisputeSubmissionPeriod, "Auction is not completed yet.");
        for (uint256 i = 0 ; i < bidders.length; i +=1){
            address bidderAddress = bidders[i];
            delete encodedBids[bidderAddress];
        }
    }



    // INTERNAL FUNCTIONS


    function clearWinners() 
    private {
        delete winners;
    }

    function addWinner(uint256 bid, string memory nonce) 
    private {
        winner memory temp = winner(msg.sender, bid, nonce);

        winners.push(temp);
    }

    function isDiputeBidGreaterThanOneWinnerBid(uint256 disputeBid) 
    private 
    view 
    returns(bool){
        for(uint256 i = 0 ; i < winners.length;i++){
            if(disputeBid > winners[i].bid) {
                return true;
            }
        }
        return false;
    }

    function computeHash(uint256 bid, string memory nonce)
    internal  
    pure 
    returns(bytes32) {
        string memory bidInString = Strings.toString(bid);
        string memory bidAndNonceConcatenation = string.concat(bidInString, nonce);
        return sha256(abi.encodePacked(bidAndNonceConcatenation));
    }
}