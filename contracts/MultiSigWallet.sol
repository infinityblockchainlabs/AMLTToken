pragma solidity ^0.4.11;

import "./MultiSigWalletInterface.sol";

/**
 * @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
 * @author Stefan George - <stefan.george@consensys.net>
 */
contract MultiSigWallet is MultiSigWalletInterface {

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address _owner) {
        require(!isOwner[_owner]);
        _;
    }

    modifier ownerExists(address _owner) {
        require(isOwner[_owner]);
        _;
    }

    modifier transactionExists(uint _transactionId) {
        require(transactions[_transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint _transactionId, address _owner) {
        require(confirmations[_transactionId][_owner]);
        _;
    }

    modifier notConfirmed(uint _transactionId, address _owner) {
        require(!confirmations[_transactionId][_owner]);
        _;
    }

    modifier notExecuted(uint _transactionId) {
        require(!transactions[_transactionId].executed);
        _;
    }

    modifier notNull(address _addr) {
        require(_addr != 0);
        _;
    }

    modifier validRequirement(uint _ownerCount, uint _required) {
        require(_ownerCount != 0 && _required != 0 && _ownerCount <= MAX_OWNER_COUNT && _required <= _ownerCount);
        _;
    }

	/**
	 * @dev Fallback function allows to deposit ether
	 */
    function()
        payable
    {
        if (msg.value > 0) {
			LogDeposit(msg.sender, msg.value);
		}
    }

	/**
	 * @dev Contract constructor sets initial owners and required number of confirmations
	 * @param _owners List of initial owners
	 * @param _required Number of required confirmations
	 */
    function MultiSigWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            assert(_owners[i] != 0 && !isOwner[_owners[i]]);
            isOwner[_owners[i]] = true;
        }

        owners = _owners;
        required = _required;
    }

	/**
	 * @dev Allows to add a new owner. Transaction has to be sent by wallet
	 * @param _owner Address of new owner
	 */
    function addOwner(address _owner)
        public
        onlyWallet
        ownerDoesNotExist(_owner)
        notNull(_owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[_owner] = true;
        owners.push(_owner);
        LogOwnerAddition(_owner);
    }

	/**
	 * @dev Allows to remove an owner. Transaction has to be sent by wallet
	 * @param _owner Address of owner
	 */
    function removeOwner(address _owner)
        public
        onlyWallet
        ownerExists(_owner)
    {
        isOwner[_owner] = false;

        for (uint i = 0; i < owners.length - 1; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
		}

        owners.length -= 1;

        if (required > owners.length) {
            changeRequirement(owners.length);
		}

        LogOwnerRemoval(_owner);
    }

	/**
	 * @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet
	 * @param _owner Address of owner to be replaced
	 * @param _newOwner Address of new owner
	 */
    function replaceOwner(address _owner, address _newOwner)
        public
        onlyWallet
        ownerExists(_owner)
        ownerDoesNotExist(_newOwner)
    {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) {
                owners[i] = _newOwner;
                break;
            }
		}

        isOwner[_owner] = false;
        isOwner[_newOwner] = true;
        LogOwnerRemoval(_owner);
        LogOwnerAddition(_newOwner);
    }

	/**
	 * @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet
	 * @param _required Number of required confirmations
	 */
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        LogRequirementChange(_required);
    }

	/**
	 * @dev Allows an owner to submit and confirm a transaction
	 * @param _destination Transaction target address
	 * @param _value Transaction ether value
	 * @param _data Transaction data payload
	 * @return Returns transaction ID
	 */
    function submitTransaction(address _destination, uint _value, bytes _data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(_destination, _value, _data);
        confirmTransaction(transactionId);
    }

	/**
	 * @dev Allows an owner to confirm a transaction
	 * @param _transactionId Transaction ID
	 */
    function confirmTransaction(uint _transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(_transactionId)
        notConfirmed(_transactionId, msg.sender)
    {
        confirmations[_transactionId][msg.sender] = true;
        LogConfirmation(msg.sender, _transactionId);
        executeTransaction(_transactionId);
    }

	/**
	 * @dev Allows an owner to revoke a confirmation for a transaction
	 * @param _transactionId Transaction ID
	 */
    function revokeConfirmation(uint _transactionId)
        public
        ownerExists(msg.sender)
        confirmed(_transactionId, msg.sender)
        notExecuted(_transactionId)
    {
        confirmations[_transactionId][msg.sender] = false;
        LogRevocation(msg.sender, _transactionId);
    }

	/**
	 * @dev Allows anyone to execute a confirmed transaction
	 * @param _transactionId Transaction ID
	 */
    function executeTransaction(uint _transactionId)
        public
        notExecuted(_transactionId)
    {
        if (isConfirmed(_transactionId)) {
            Transaction storage trans = transactions[_transactionId];
            trans.executed = true;

            if (trans.destination.call.value(trans.value)(trans.data)) {
                LogExecution(_transactionId);

            } else {
                LogExecutionFailure(_transactionId);
                trans.executed = false;
            }
        }
    }

	/**
	 * @dev Returns the confirmation status of a transaction
	 * @param _transactionId Transaction ID
	 * @return Confirmation status
	 */
    function isConfirmed(uint _transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;

        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[_transactionId][owners[i]]) {
				count += 1;
			}

            if (count == required) {
                return true;
			}
        }

        return false;
    }

	/**
	 * @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet
	 * @param _destination Transaction target address
	 * @param _value Transaction ether value
	 * @param _data Transaction data payload
	 * @return Returns transaction ID
	 */
    function addTransaction(address _destination, uint _value, bytes _data)
        internal
        notNull(_destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;

        transactions[transactionId] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false
        });

        transactionCount += 1;
        LogSubmission(transactionId, _destination, _value, _data);
    }

	/**
	 * @dev Returns list of owners
	 * @return List of owner addresses
	 */
    function getOwners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

    /**
	 * @dev Returns number of confirmations of a transaction
	 * @param _transactionId Transaction ID
     * @return Number of confirmations
	 */
    function getConfirmationCount(uint _transactionId)
        public
        constant
        returns (uint count)
    {
        uint len = owners.length;

        for (uint i = 0; i < len; i++) {
            if (confirmations[_transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    /**
	 * @dev Returns total number of transactions after filters are applied
	 * @param _pending Include pending transactionss
     * @param _executed Include executed transactions
     * @return Total number of transactions after filters are applied
	 */
    function getTransactionCount(bool _pending, bool _executed)
        public
        constant
        returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++) {
            if (_pending && !transactions[i].executed || _executed && transactions[i].executed) {
                count += 1;
            }
        }
    }

    /**
	 * @dev Returns array with owner addresses, which confirmed transaction
	 * @param _transactionId Transaction ID
     * @return Returns array of owner addresses
	 */
    function getConfirmations(uint _transactionId)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;

        for (i = 0; i < owners.length; i++) {
            if (confirmations[_transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        }

        _confirmations = new address[](count);

        for (i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
    }

    /**
	 * @dev Returns list of transaction IDs in defined range
	 * @param _from Index start position of transaction array
     * @param _to Index end position of transaction array
     * @param _pending Include pending transactions
     * @param _executed Include executed transactions
     * @return Returns array of transaction IDs
	 */
    function getTransactionIds(uint _from, uint _to, bool _pending, bool _executed)
        public
        constant
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;

        for (i = 0; i < transactionCount; i++) {
            if (_pending && !transactions[i].executed || _executed && transactions[i].executed) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        }

        _transactionIds = new uint[](_to - _from);
        
        for (i = _from; i < _to; i++) {
            _transactionIds[i - _from] = transactionIdsTemp[i];
        }
    }

}