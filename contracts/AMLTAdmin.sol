pragma solidity ^0.4.11;

import './AMLTAdminInterface.sol';

contract AMLTAdmin is AMLTAdminInterface {

    modifier onlyOperator() {
        require(operatorList[msg.sender]);
        _;
    }

    modifier notNull(address _addr) {
        require(_addr != 0);
        _;
    }

    /**
     * @dev Constructor
     * @param _operator The address of operator
     */
    function AMLTAdmin(address _operator)
    {
        operatorList[_operator] = true;
    }

    /**
     * @dev Add new operator to list
     * @param _operator The address of new operator
     */
    function addOperator(address _operator)
        public
        onlyOperator
        notNull(_operator)
        returns (bool success)
    {
        if (operatorList[_operator]) {
            return false;
        }

        operatorList[_operator] = true;
        LogAddOperator(_operator);
        return true;
    }

    /**
     * @dev Remove operator get out operator list
     * @param _operator The operator address which want to remove
     */
    function removeOperator(address _operator)
        public
        onlyOperator
        returns (bool success)
    {
        if (!operatorList[_operator]) {
            return false;
        }

        operatorList[_operator] = false;
        LogRemoveOperator(_operator);
        return true;
    }

    /**
     * @dev Replace old operator to new operator
     * @param _oldOperator The old operator address
     * @param _newOperator The new operator address
     */
    function replaceOperator(address _oldOperator, address _newOperator)
        public
        onlyOperator
        notNull(_newOperator)
        returns (bool success)
    {
         if (!operatorList[_oldOperator] || operatorList[_newOperator]) {
            return false;
        }

        operatorList[_oldOperator] = false;
        operatorList[_newOperator] = true;
        LogReplaceOperator(_oldOperator, _newOperator);
        return true;
    }

}