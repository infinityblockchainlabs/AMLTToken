pragma solidity ^0.4.11;

import './lib/SafeMath.sol';
import './AMLTCrowdsaleInterface.sol';
import './AMLTAdminInterface.sol';
import './AMLTInterface.sol';

contract AMLTCrowdsale is AMLTCrowdsaleInterface {

    using SafeMath for uint;

    AMLTInterface public amltContract;
    AMLTAdminInterface public adminContract;

    modifier onlyOperator() {
        require(adminContract.operatorList(msg.sender));
        _;
    }

    modifier onlyMultiSigWallet() {
        require(msg.sender == amltMultiSig);
        _;
    }

    /**
     * @dev Constructor
     * @param _amltMultiSig The address of MultiSig Wallet contract
     * @param _adminContract The address of AMLTAdmin contract
	 * @param _fundingStartBlock Crowdsale start block
     * @param _fundingEndBlock Crowdsale end block
     * @param _tokenCrowdsalePool Pool contain tokens is sold in crowdsale
     */
    function AMLTCrowdsale(address _amltMultiSig, address _amltContract, address _adminContract, uint _fundingStartBlock, uint _fundingEndBlock, uint _tokenCrowdsalePool)
    {
        assert(_fundingStartBlock > block.number);
        assert(_fundingStartBlock < _fundingEndBlock);

        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;

        tokenCrowdsalePool = _tokenCrowdsalePool;

        amltMultiSig = _amltMultiSig;
        amltContract = AMLTInterface(_amltContract);
        adminContract = AMLTAdminInterface(_adminContract);
    }

    /**
     * @dev Sell tokens through the fallback function
     */
    function()
        payable
    {
        assert(getState() == State.Funding);

        address sender = msg.sender;
        uint value = msg.value;

        // Check money which buyer sent
        assert(value >= tokenPrice);

        uint numTokens = value / tokenPrice;

        if (numTokens > tokenCrowdsalePool) {
            numTokens = tokenCrowdsalePool;
        }

        if (buyers[totalBuyers] == 0) {
            buyers[totalBuyers++] = sender;
        }

        amount[sender] = amount[sender].add(numTokens);
        tokenCrowdsalePool -= numTokens;
        LogBuyToken(sender, value, numTokens, tokenPrice);

        refundRemainingETH(sender, value - tokenPrice * numTokens);
    }

    /**
     * @dev Refund remaining ETH for buyer
     */
    function refundRemainingETH(address _receiver, uint _amount)
        internal
    {
        if (_amount == 0) {
            return;
        }

        assert(_receiver.send(_amount));
    }

    /**
     * @dev Change price of token
     * @param _price The new price of token
     */
    function changeTokenPrice(uint _price)
        onlyOperator
        public
        returns (bool success)
    {
        if (getState() != State.PreFunding) {
            return false;
        }

        tokenPrice = _price;
        LogChangeTokenPrice(_price);
        return true;
    }

    /**
     * @dev Get crowdsale state
     */
    function getState()
        public
        constant
        returns (State)
    {
        if (block.number < fundingStartBlock) {
            return State.PreFunding;

        } else if (block.number <= fundingEndBlock && tokenCrowdsalePool > 0) {
            return State.Funding;

        } else {
            return State.Closed;
        }
    }

    /**
     * @dev Change MultiSig Wallet contract
     * @param _amltMultiSig The new address of MultiSig Wallet contract
     */
    function changeMultiSigWallet(address _amltMultiSig)
        onlyMultiSigWallet
        public
    {
        amltMultiSig = _amltMultiSig;
        LogChangeMultiSigWallet(_amltMultiSig);
    }

    /**
     * @dev Change AMLT contract
     * @param _amltContract The new address of AMLTAdmin contract
     */
    function changeAMLTContract(address _amltContract)
        onlyMultiSigWallet
        public
    {
        amltContract = AMLTInterface(_amltContract);
        LogChangeAMLTContract(_amltContract);
    }

    /**
     * @dev Change AMLTAdmin contract
     * @param _adminContract The new address of AMLTAdmin contract
     */
    function changeAMLTAdminContract(address _adminContract)
        onlyMultiSigWallet
        public
    {
        adminContract = AMLTAdminInterface(_adminContract);
        LogChangeAMLTAdminContract(_adminContract);
    }

    /**
     * @dev Move fund get out AMLTCrowdsale contract
     */
    function moveFund()
        onlyMultiSigWallet
        public
    {
        LogMoveFund(amltMultiSig, this.balance);
        assert(amltMultiSig.send(this.balance));
    }

    function refund(address _buyer)
        onlyOperator
        public
        returns (bool success)
    {
        uint numTokens = amount[_buyer];

        if (numTokens == 0) {
            return false;
        }

        amount[_buyer] = 0;
        tokenCrowdsalePool = tokenCrowdsalePool.add(numTokens);
        assert(_buyer.send(numTokens * tokenPrice));
        return true;
    }

    function payoutToken()
        public
    {
        // uint current = currentPayoutIndex;
        // uint len = totalBuyers;
        // uint count = 0;

        // address tmpAddr;
        // uint tmpAmount;

        // for (uint i = current; count < 20 && i < len; i++) {
        //     tmpAddr = qsdb1.affiliates(i);
        //     tmpAmount = qsdb1.amount(tmpAddr);

        //     if (!amlt.transfer(buyers[], tmpAmount)) {
        //         throw;
        //     }

        //     count++;
        // }

        // if (count != 0) {
        //     currentDistributedIndex = current + count;
        // }
    }

}