pragma solidity ^0.4.11;

contract AMLTCrowdsaleEvents {
    event LogChangeTokenPrice(uint _price);
    event LogChangeMultiSigWallet(address _amltMultiSig);
    event LogChangeAMLTContract(address _amltContract);
    event LogChangeAMLTAdminContract(address _adminContract);
    event LogMoveFund(address indexed _target, uint _value);
    event LogBuyToken(address indexed _sender, uint _value, uint _numTokens, uint _tokenPrice);
}

contract AMLTCrowdsaleInterface is AMLTCrowdsaleEvents {

    enum State { PreFunding, Funding, Closed }

    uint public fundingStartBlock;                  // Crowdsale start block
    uint public fundingEndBlock;                    // Crowdsale end block

    uint public tokenPrice;                         // Price of token
    uint public tokenCrowdsalePool;                 // Pool contain tokens is sold in crowdsale

    address public amltMultiSig;

    mapping(uint => address) public buyers;         // index => buyer address
    mapping(address => uint) public amount;         // buyer address => AMLT amount
    uint public totalBuyers;

    uint public currentPayoutIndex;

    function changeTokenPrice(uint _price) public returns (bool success);
    function getState() public constant returns (State);
    function changeMultiSigWallet(address _amltMultiSig) public;
    function changeAMLTAdminContract(address _adminContract) public;
    function moveFund() public;

}