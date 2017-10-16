pragma solidity ^0.4.11;

contract AMLTCrowdsaleEvents {
    event LogChangeTokenPrice(uint _price);
    event LogMoveFund(address indexed _target, uint _value);
    event LogBuyToken(address indexed _sender, uint _value, uint _numTokens);
    event LogRefund(address indexed _buyer, uint _value);
    event LogPayoutToken(address indexed _buyer, uint _amount);
    event LogChangeAMLTAdminContract(address _adminContract);
    event LogChangeAMLTContract(address _amltContract);
}

contract AMLTCrowdsaleInterface is AMLTCrowdsaleEvents {

    enum State { PreFunding, Funding, Closed }

    uint public fundingStartBlock;                  // Crowdsale start block
    uint public fundingEndBlock;                    // Crowdsale end block

    uint public tokenPrice;                         // Price of token
    uint public tokenCrowdsalePool;                 // Pool contain tokens is sold in crowdsale

    mapping(uint => address) public buyers;         // index => buyer address
    mapping(address => uint) public amltAmount;     // buyer address => AMLT amount
    uint public totalBuyers;
    uint public currentPayoutIndex;

    function getState() public constant returns (State);
    function changeTokenPrice(uint _price) public returns (bool success);
    function moveFund() public returns (bool success);
    function changeAMLTAdminContract(address _adminContract) public;
    function changeAMLTContract(address _amltContract) public;
    function refund(address _buyer) public returns (bool success);
    function payoutToken() public;

}