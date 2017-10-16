pragma solidity ^0.4.11;

import './lib/SafeMath.sol';
import './AMLTCrowdsaleInterface.sol';
import './AMLTAdminInterface.sol';
import './AMLTInterface.sol';

contract AMLTCrowdsale is AMLTCrowdsaleInterface {

    using SafeMath for uint;

    AMLTAdminInterface public adminContract;
    AMLTInterface public amltContract;

    modifier onlyOperator() {
        require(adminContract.operatorList(msg.sender));
        _;
    }

    modifier onlyMultiSigWallet() {
        require(msg.sender == adminContract.amltMultiSig());
        _;
    }

    /**
     * @dev Constructor
     * @param _adminContract The address of AMLTAdmin contract
     * @param _amltContract The address of AMLT contract
	 * @param _fundingStartBlock Crowdsale start block
     * @param _fundingEndBlock Crowdsale end block
     * @param _tokenCrowdsalePool Pool contain tokens is sold in crowdsale
     */
    function AMLTCrowdsale(address _adminContract, address _amltContract, uint _fundingStartBlock, uint _fundingEndBlock, uint _tokenCrowdsalePool)
    {
        assert(_fundingStartBlock > block.number);
        assert(_fundingStartBlock < _fundingEndBlock);

        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;

        tokenCrowdsalePool = _tokenCrowdsalePool;

        adminContract = AMLTAdminInterface(_adminContract);
        amltContract = AMLTInterface(_amltContract);
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

        if (amltAmount[sender] == 0) {
            buyers[totalBuyers++] = sender;
        }

        amltAmount[sender] = amltAmount[sender].add(numTokens);
        tokenCrowdsalePool -= numTokens;
        LogBuyToken(sender, value, numTokens);

        uint remaining = value - tokenPrice * numTokens;

        if (remaining > 0) {
            assert(sender.send(remaining));
        }
    }

    /**
     * @dev Change price of token
     * @param _price The new price of token
     */
    function changeTokenPrice(uint _price)
        public
        onlyOperator
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
     * @dev Move fund get out AMLTCrowdsale contract
     */
    function moveFund()
        public
        onlyMultiSigWallet
        returns (bool success)
    {
        if (this.balance == 0) {
            return false;
        }

        LogMoveFund(msg.sender, this.balance);
        assert(msg.sender.send(this.balance));
        return true;
    }

    /**
     * @dev Change AMLTAdmin contract
     * @param _adminContract The new address of AMLTAdmin contract
     */
    function changeAMLTAdminContract(address _adminContract)
        public
        onlyMultiSigWallet
    {
        adminContract = AMLTAdminInterface(_adminContract);
        LogChangeAMLTAdminContract(_adminContract);
    }

    /**
     * @dev Change AMLT contract
     * @param _amltContract The new address of AMLT contract
     */
    function changeAMLTContract(address _amltContract)
        public
        onlyMultiSigWallet
    {
        amltContract = AMLTInterface(_amltContract);
        LogChangeAMLTContract(_amltContract);
    }

    /**
     * @dev Refund ETH for buyer who don't pass KYC
     * @param _buyer The address of buyer
     */
    function refund(address _buyer)
        public
        onlyOperator
        returns (bool success)
    {
        uint numTokens = amltAmount[_buyer];

        if (getState() != State.Closed || this.balance == 0 || numTokens == 0) {
            return false;
        }

        amltAmount[_buyer] = 0;
        tokenCrowdsalePool = tokenCrowdsalePool.add(numTokens);
        assert(_buyer.send(numTokens * tokenPrice));
        LogRefund(_buyer, numTokens * tokenPrice);
        return true;
    }

    /**
     * @dev Payout token for buyer
     */
    function payoutToken()
        public
        onlyOperator
    {
        uint current = currentPayoutIndex;
        uint len = totalBuyers;
        uint count = 0;

        address tmpAddr;
        uint tmpAmount;

        for (uint i = current; count < 20 && i < len; i++) {
            tmpAddr = buyers[i];
            tmpAmount = amltAmount[tmpAddr];

            if (tmpAmount == 0) {
                assert(amltContract.transfer(tmpAddr, tmpAmount));
                LogPayoutToken(tmpAddr, tmpAmount);
            }

            count++;
        }

        if (count != 0) {
            currentPayoutIndex = current + count;
        }
    }

}