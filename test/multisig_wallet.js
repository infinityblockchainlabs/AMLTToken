var Logger = require('./../helpers/logger');
var MultiSigWallet = artifacts.require('./MultiSigWallet.sol');

var Buffer = require('buffer').Buffer;
var ethUtil = require('ethereumjs-util');
var ethAbi = require('ethereumjs-abi');

contract('MultiSigWallet', (accounts) => {

    const OWNER_1 = accounts[0];
    const OWNER_2 = accounts[1];
    const OWNER_3 = accounts[2];
    const OWNER_4 = accounts[3];

    var multisigContract;
    var transactionCount = 0;

    it('Prepare before test', () => {
        return MultiSigWallet.new([OWNER_1, OWNER_2, OWNER_3], 2).then((instance) => {
            multisigContract = instance;
        });
    });

    it('Add OWNER_4', () => {
        var encoded = ethAbi.simpleEncode("addOwner(address)", OWNER_4);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_1 }).then((result) => {
            Logger.printLog(result);
            return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_2 });

        }).then((result) => {
            Logger.printLog(result);
            return multisigContract.isOwner.call(OWNER_4);

        }).then((result) => {
            assert.equal(result, true);
        });
    });

    it('Remove OWNER_1', () => {
        var encoded = ethAbi.simpleEncode("removeOwner(address)", OWNER_1);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_2 }).then((result) => {
            Logger.printLog(result);
            return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_4 });

        }).then((result) => {
            Logger.printLog(result);
            return multisigContract.isOwner.call(OWNER_1);

        }).then((result) => {
            assert.equal(result, false);
        });
    });

    it('Replace OWNER_4 by OWNER_1', () => {
        var encoded = ethAbi.simpleEncode("replaceOwner(address,address)", OWNER_4, OWNER_1);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_2 }).then((result) => {
            Logger.printLog(result);
            return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_3 });

        }).then((result) => {
            Logger.printLog(result);
            return multisigContract.isOwner.call(OWNER_1);

        }).then((result) => {
            assert.equal(result, true);
            return multisigContract.isOwner.call(OWNER_4);

        }).then((result) => {
            assert.equal(result, false);
        });
    });

    it('Change the number of required confirmations to 1', () => {
        var encoded = ethAbi.simpleEncode("changeRequirement(uint)", 1);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_1 }).then((result) => {
            Logger.printLog(result);
            return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_3 });

        }).then((result) => {
            Logger.printLog(result);
            return multisigContract.required.call();

        }).then((result) => {
            assert.equal(result, 1);
        });
    });

    it('Add OWNER_4', () => {
        var encoded = ethAbi.simpleEncode("addOwner(address)", OWNER_4);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_1 }).then((result) => {
            Logger.printLog(result);
            transactionCount++;

            return multisigContract.isOwner.call(OWNER_4);

        }).then((result) => {
            assert.equal(result, true);
        });
    });

    it('Change the number of required confirmations to 2', () => {
        var encoded = ethAbi.simpleEncode("changeRequirement(uint)", 2);

        return multisigContract.submitTransaction(multisigContract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_4 }).then((result) => {
            Logger.printLog(result);
            transactionCount++;

            return multisigContract.required.call();

        }).then((result) => {
            assert.equal(result, 2);
        });
    });

});