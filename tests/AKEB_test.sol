// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../Contracts/AKEB.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is AKEB {
    address bidder1;
    uint256 bid1;
    string nonce1;
    bytes32 hash1;

    address bidder2;
    uint256 bid2;
    string nonce2;
    bytes32 hash2;

    address bidder3;
    uint256 bid3;
    string nonce3;
    bytes32 hash3;

    
    function beforeAll() public {
        // auctioneer is address 0
        // seller is address 1
        bidder1 = TestsAccounts.getAccount(2); 
        bidder2 = TestsAccounts.getAccount(3);
        bidder3 = TestsAccounts.getAccount(4);

        bid1 = 11;
        nonce1 = "bid1";
        hash1 = 0x5647b2fc56179a52d9885e3188a4624e65f45772d1dc4ce067b8380d04a39977;

        bid2 = 22;
        nonce2 = "bid2";
        hash2 = 0x50c3208089b13dbbf91f80db31299cf2b996a7d2e671b5f49c6d513a89f63df1;

        bid3 = 33;
        nonce3 = "bid3";
        hash3 = 0xcec60b8bf0259b4ebd98f5b55fd70f78622e0623b1fff9f4e88c4cedcdbc0f5f;
    }

    /// #sender: account-1
    function startAuction() public {
        registerAuctionInfo("watch", "great watch");
        
        Assert.ok(
            sha256(abi.encodePacked(assetName)) == 
            sha256(abi.encodePacked("watch")) , 
            "the name of asset is not correctly stored");

        Assert.ok(
            sha256(abi.encodePacked(assetDescription)) == 
            sha256(abi.encodePacked("great watch")) , 
            "the description of asset is not correctly stored"
        );

        // Assert.equal(Received, Expected, ...)
        Assert.equal(TestsAccounts.getAccount(1), 
        seller, 
        "address of seller is incorrect.");

        Assert.equal(isAuctionStarted, true, "Auction should be started");
    }

    /// #sender: account-2
    function checkRegisterBidder1() public {
        registerBidder();

        Assert.equal(
            TestsAccounts.getAccount(2),
            bidders[0],
            "bidder 0 is not registered."
        );
    }

    /// #sender: account-3
    function checkRegisterBidder2() public {
        registerBidder();

        Assert.equal(
            TestsAccounts.getAccount(3),
            bidders[1],
            "bidder 1 is not registered."
        );
    }

    /// #sender: account-4
    function checkRegisterBidder3() public {
        registerBidder();

        Assert.equal(
            TestsAccounts.getAccount(4),
            bidders[2],
            "bidder 2 is not registered."
        );
    }

    /// #sender: account-2
    function checkBidder1HashedBidSubmission() public {
        Assert.equal(
            computeHash(bid1, nonce1),
            hash1,
            "hash1 is not correct"
        );

        submitEncodedBid(hash1);
        Assert.equal(
            hash1,
            encodedBids[msg.sender],
            "hash1 of bidder 1 is not submitted"
        );
    }

    /// #sender: account-3
    function checkBidder2HashedBidSubmission() public {
        Assert.equal(
            computeHash(bid2, nonce2),
            hash2,
            "hash2 is not correct"
        );

        submitEncodedBid(hash2);
        Assert.equal(
            hash2,
            encodedBids[msg.sender],
            "hash2 of bidder 2 is not submitted"
        );
    }

    /// #sender: account-4 
    function checkBidder3HashedBidSubmission() public {
        Assert.equal(
            computeHash(bid3, nonce3),
            hash3,
            "hash3 is not correct"
        );

        submitEncodedBid(hash3);
        Assert.equal(
            hash3,
            encodedBids[msg.sender],
            "hash3 of bidder 3 is not submitted"
        );
    }

}
    