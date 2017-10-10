pragma solidity ^0.4.11;

contract AMLTAdminEvents {
    event LogAddOperator(address _operator);
    event LogRemoveOperator(address _operator);
    event LogReplaceOperator(address _oldOperator, address _newOperator);
}

contract AMLTAdminInterface is AMLTAdminEvents {

    // List of operator manage AMLT contract
    mapping(address => bool) public operatorList;

    function addOperator(address _operator) public returns (bool success);
    function removeOperator(address _operator) public returns (bool success);
    function replaceOperator(address _oldOperator, address _newOperator) public returns (bool success);

}