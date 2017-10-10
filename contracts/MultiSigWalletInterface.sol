pragma solidity ^0.4.11;

contract MultiSigWalletEvents {
	event LogConfirmation(address indexed _sender, uint _transactionId);
    event LogRevocation(address indexed _sender, uint _transactionId);
    event LogSubmission(uint indexed _transactionId, address _destination, uint _value, bytes _data);
    event LogExecution(uint _transactionId);
    event LogExecutionFailure(uint _transactionId);
    event LogDeposit(address indexed _sender, uint _value);
    event LogOwnerAddition(address _owner);
    event LogOwnerRemoval(address _owner);
    event LogRequirementChange(uint _required);
}

contract MultiSigWalletInterface is MultiSigWalletEvents {

	struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    uint constant internal MAX_OWNER_COUNT = 50;

    mapping(uint => Transaction) public transactions;                       // transaction id => transaction data
    mapping(uint => mapping(address => bool)) public confirmations;         // transaction id => owner address => true: confirmed, false: unconfirmed
    mapping(address => bool) public isOwner;                                // owner address => true: exist, false: not exist
    address[] internal owners;
    uint public required;                                                   // number of confirmations is required in a transaction
    uint public transactionCount;

    function addOwner(address _owner) public;
    function removeOwner(address _owner) public;
    function replaceOwner(address _owner, address _newOwner) public;
    function changeRequirement(uint _required) public;
    function submitTransaction(address _destination, uint _value, bytes _data) public returns (uint transactionId);
    function confirmTransaction(uint _transactionId) public;
    function revokeConfirmation(uint _transactionId) public;
    function executeTransaction(uint _transactionId) public;
    function isConfirmed(uint _transactionId) public constant returns (bool);
    function getOwners() public constant returns (address[]);

}