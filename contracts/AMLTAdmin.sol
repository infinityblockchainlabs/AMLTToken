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

    modifier onlyMultiSigWallet() {
        require(msg.sender == amltMultiSig);
        _;
    }

    /**
     * @dev Constructor
     * @param _operator The address of operator
     * @param _amltMultiSig The address of MultiSig Wallet contract
     */
    function AMLTAdmin(address _operator, address _amltMultiSig)
    {
        operatorList[_operator] = true;
        amltMultiSig = _amltMultiSig;
    }

    /**
     * @dev Add new operator to list
     * @param _operator The address of new operator
     */
    function addOperator(address _operator)
        public
        onlyMultiSigWallet
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
        onlyMultiSigWallet
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
        onlyMultiSigWallet
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

    /**
     * @dev Add new account to whitelist
     * @param _account The address of new account
     */
    function addAccount(address _account)
        public
        onlyOperator
        notNull(_account)
        returns (bool success)
    {
        if (whiteList[_account]) {
            return false;
        }

        whiteList[_account] = true;
        LogAddAccount(_account);
        return true;
    }

    /**
     * @dev Remove account get out whitelist
     * @param _account The _account address which want to remove
     */
    function removeAccount(address _account)
        public
        onlyOperator
        returns (bool success)
    {
        if (!whiteList[_account]) {
            return false;
        }

        whiteList[_account] = false;
        LogRemoveAccount(_account);
        return true;
    }

    /**
     * @dev Verify account in whitelist
     * @param _account The account address which want to verify
     * @return True if _account is in whitelist
     */
    function verifyAccount(address _account)
        public
        constant
        returns (bool inWhitelist)
    {
        return whiteList[_account];    
    }

    /**
     * @dev Add new account to Network Member list
     * @param _account The address of new account
     */
    function addNetworkMember(address _account)
        public
        onlyOperator
        notNull(_account)
        returns (bool success)
    {
        if (networkMemberList[_account]) {
            return false;
        }

        networkMemberList[_account] = true;
        LogAddNetworkMember(_account);
        return true;
    }

    /**
     * @dev Remove account get out list of Network Member
     * @param _account The _account address which want to remove
     */
    function removeNetworkMember(address _account)
        public
        onlyOperator
        returns (bool success)
    {
        if (!networkMemberList[_account]) {
            return false;
        }

        networkMemberList[_account] = false;
        LogRemoveNetworkMember(_account);
        return true;
    }

    /**
     * @dev Verify account in Network Member list
     * @param _account The account address which want to verify
     * @return True if _account is in Network Member list
     */
    function verifyNetworkMember(address _account)
        public
        constant
        returns (bool inNetworkMemberList)
    {
        return networkMemberList[_account];
    }

    /**
     * @dev Change MultiSig Wallet contract
     * @param _amltMultiSig The new address of MultiSig Wallet contract
     */
    function changeMultiSigWallet(address _amltMultiSig)
        public
        onlyMultiSigWallet
    {
        amltMultiSig = _amltMultiSig;
        LogChangeMultiSigWallet(_amltMultiSig);
    }

}