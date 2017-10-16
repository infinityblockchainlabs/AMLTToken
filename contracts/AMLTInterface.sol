pragma solidity ^0.4.11;

contract AMLTEvents {
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract AMLTInterface is AMLTEvents {

    string public constant symbol = "AMLT";
    string public constant name = "AMLT Token";
    uint8 public constant decimals = 18;

    // The total token supply
    uint public totalSupply = 33594581373 * 10 ** uint(decimals);

    // Balances for each account
    mapping(address => uint) public balanceOf;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping(address => uint)) internal allowed;

    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

}