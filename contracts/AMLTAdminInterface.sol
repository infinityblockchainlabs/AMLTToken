pragma solidity ^0.4.11;

contract AMLTAdminEvents {
    event LogAddOperator(address _operator);
    event LogRemoveOperator(address _operator);
    event LogReplaceOperator(address _oldOperator, address _newOperator);
    event LogAddAccount(address _account);
    event LogRemoveAccount(address _account);
    event LogAddNetworkMember(address _account);
    event LogRemoveNetworkMember(address _account);
    event LogChangeMultiSigWallet(address _amltMultiSig);
}

contract AMLTAdminInterface is AMLTAdminEvents {

    mapping(address => bool) public operatorList;
    mapping(address => bool) internal whiteList;            // List of account have registered KYC
    mapping(address => bool) internal networkMemberList;    // List of account have obtained the status of Network Member

    address public amltMultiSig;

    function addOperator(address _operator) public returns (bool success);
    function removeOperator(address _operator) public returns (bool success);
    function replaceOperator(address _oldOperator, address _newOperator) public returns (bool success);
    function addAccount(address _account) public returns (bool success);
    function removeAccount(address _account) public returns (bool success);
    function verifyAccount(address _account) public constant returns (bool inWhitelist);
    function addNetworkMember(address _account) public returns (bool success);
    function removeNetworkMember(address _account) public returns (bool success);
    function verifyNetworkMember(address _account) public constant returns (bool inNetworkMemberList);
    function changeMultiSigWallet(address _amltMultiSig) public;

}