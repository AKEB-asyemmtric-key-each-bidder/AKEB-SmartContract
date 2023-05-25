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
contract testSuite {
    AKEB testContract;
    string assetName = "watch";
    string assetDescription = "Great watch";

    // Account 0 (bidder 1): 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // Account 1 (bidder 2): 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // Account 2 (bidder 3): 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    // Account 3 (seller): 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    // Account 4 (auctioneer): 0x617F2E2fD72FD9D5503197092aC168c91465E7f2

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    /// #sender: account-4
    function beforeAll() public {
        // <instantiate contract>
        Assert.equal(
            msg.sender, 
        TestsAccounts.getAccount(4), 
        "Only auctioneer can deploy the smart contact");
        testContract = new AKEB();
        
    }

    /// #sender: account-3
    function startAuctionTest() public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(3), "Only seller can call this function");
        
        testContract.registerAuctionInfo(assetName, assetDescription);
        Assert.ok(
            sha256(abi.encodePacked(testContract.assetName())) == 
            sha256(abi.encodePacked(assetName)) , 
            "the name of asset is not correctly stored");

        Assert.ok(
            sha256(abi.encodePacked(testContract.assetDescription())) == 
            sha256(abi.encodePacked(assetDescription)) , 
            "the description of asset is not correctly stored"
        );
    }
    
    /// #sender: account-0
    function registerBidder0Test() public {
        Assert.ok(
            msg.sender == TestsAccounts.getAccount(0)
            , "Only accounts 0 can call this function");
        testContract.registerBidder();
    }

    /// #sender: account-1
    function registerBidder1Test() public {
        Assert.ok(
            msg.sender == TestsAccounts.getAccount(1)
            , "Only accounts 1 can call this function");
        testContract.registerBidder();
    }

    /// #sender: account-2
    function registerBidder2Test() public {
        Assert.ok(
            msg.sender == TestsAccounts.getAccount(2)
            , "Only accounts 2 can call this function");
        testContract.registerBidder();
    }

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.ok(2 == 2, 'should be true');
        Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    function checkFailure() public {
        Assert.notEqual(uint(1), uint(2), "1 should not be equal to 1");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-2
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        
        Assert.equal(msg.sender, TestsAccounts.getAccount(2), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
    