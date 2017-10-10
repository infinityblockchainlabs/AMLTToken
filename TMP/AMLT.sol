pragma solidity ^0.4.11;

import './lib/SafeMath.sol';
import './AMLTInterface.sol';

contract AMLT is AMLTInterface {

    using SafeMath for uint;

    /**
     * Constructor
     * @param _presale The address of presale pool
     * @param _crowdsale The address of crowdsale pool
     * @param _remaining The address of remaining pool
     */
    function AMLT(address _presale, address _crowdsale, address _remaining)
    {
        balanceOf[_presale] = 0;
        balanceOf[_crowdsale] = 0;
        balanceOf[_remaining] = 0;
    }

    /**
     * @dev Transfer tokens from one address to another
     */
    function move(address _from, address _to, uint _value)
        internal
        returns (bool success)
    {
        if (balanceOf[_from] >= _value && _value > 0) {
            balanceOf[_from] -= _value;
            balanceOf[_to] = balanceOf[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        }

        return false;
    }

    /**
     * @dev Transfer the balance from owner's account to another account
     * @param _to The address which you want to transfer to
     * @param _value The amount of tokens to be transferred
     */
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        return move(msg.sender, _to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from The address which you want to send tokens from
     * @param _to The address which you want to transfer to
     * @param _value The amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool success)
    {
        if (allowed[_from][msg.sender] < _value) {
            return false;
        }

        if (move(_from, _to, _value)) {
            allowed[_from][msg.sender] -= _value;
            return true;
        }

        return false;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * @param _spender The address which will spend the funds
     * @param _value The amount of tokens to be spent
     */
    function approve(address _spender, uint _value)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender
     * @param _owner The address which owns the funds
     * @param _spender The address which will spend the funds
     * @return A specifying the amount of tokens still available for the spender
     */
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint remaining)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Add new account to whitelist
     * @param _account The address of new account
     */
    function addAccount(address _account)
        public
        onlyOperator
        returns (bool success)
    {
        if (whiteList[_account]) {
            return false;
        }

        whiteList[_account] = true;
        AddAccount(_account);
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
        RemoveAccount(_account);
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
        returns (bool success)
    {
        if (networkMemberList[_account]) {
            return false;
        }

        networkMemberList[_account] = true;
        AddNetworkMember(_account);
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
        RemoveNetworkMember(_account);
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

}