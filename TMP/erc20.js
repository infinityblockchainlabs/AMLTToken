// var Logger = require('./../helpers/logger');
// var Utils = require('./../helpers/utils');

// var MultiSigWallet = artifacts.require('./MultiSigWallet.sol');
// var ERC20 = artifacts.require('./ERC20.sol');

// var Buffer = require('buffer').Buffer;
// var ethUtil = require('ethereumjs-util');
// var ethAbi = require('ethereumjs-abi');

// contract('ERC20', (accounts) => {

//     const OWNER_1 = accounts[0];
//     const OWNER_2 = accounts[1];
//     const OWNER_3 = accounts[2];

//     const BUYER_1 = accounts[3];
//     const BUYER_2 = accounts[4];
//     const BUYER_3 = accounts[5];
//     const BUYER_4 = accounts[6];

//     const TOKEN_PRICE = 1000;
//     const GAS = 1000000;
//     const GAS_PRICE = 25000000000;

//     var multisigContract, erc20Contract;
//     var transactionCount = 0;
//     var remainingTokens = 1000000 * Math.pow(10, 18);

//     it('Prepare before test', () => {
//         return MultiSigWallet.new([OWNER_1, OWNER_2, OWNER_3], 2).then((instance) => {
//             multisigContract = instance;
//             return ERC20.new(multisigContract.address);

//         }).then((instance) => {
//             erc20Contract = instance;
//         });
//     });

//     it('Check initialized data', () => {
//         return erc20Contract.owner.call().then((result) => {
//             assert.equal(result, accounts[0]);
//             return erc20Contract.multisigWallet.call();

//         }).then((result) => {
//             assert.equal(result, multisigContract.address);
//         });
//     });

//     it('Throw in onlyOwner modifier when execute changeTokenPrice function', () => {
//         return erc20Contract.changeTokenPrice(1000, { from: OWNER_2 }).then((result) => {
//             Logger.writeLog(result);

//         }).catch((e) => {
//             console.log('');
//         });
//     });

//     it('Change token price', () => {
//         return erc20Contract.changeTokenPrice(TOKEN_PRICE, { from: OWNER_1 }).then((result) => {
//             Logger.writeLog(result);
//             return erc20Contract.tokenPrice.call();

//         }).then((result) => {
//             assert.equal(result, TOKEN_PRICE);
//         });
//     });

//     it('Throw in onlyMultisig modifier when execute changeMultisigWallet function', () => {
//         return erc20Contract.changeMultisigWallet(0x1, { from: OWNER_1 }).then((result) => {
//             Logger.writeLog(result);

//         }).catch((e) => {
//             console.log('');
//         });
//     });

//     it('Change address of Multisig Wallet contract', () => {
//         var encoded = ethAbi.simpleEncode("changeMultisigWallet(address)", 0x1);

//         return multisigContract.submitTransaction(erc20Contract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_1 }).then((result) => {
//             Logger.writeLog(result);
//             return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_2 });

//         }).then((result) => {
//             Logger.writeLog(result);
//             return erc20Contract.multisigWallet.call();

//         }).then((result) => {
//             assert.equal(result, 0x1);
//         });
//     });

//     it('BUYER_1 buy token', () => {
//         remainingTokens -= 100000 * Math.pow(10, 18);

//         return erc20Contract.sendTransaction({ from: BUYER_1, value: 100000 * TOKEN_PRICE, gas: GAS, gasPrice: GAS_PRICE }).then((result) => {
//             Logger.writeLog(result);
//             return erc20Contract.balanceOf.call(BUYER_1);

//         }).then((result) => {
//             assert.equal(result, 100000 * Math.pow(10, 18));
//             return erc20Contract.balanceOf.call(OWNER_1);

//         }).then((result) => {
//             assert.equal(result, remainingTokens);
//         });
//     });

//     it('Throw when BUYER_1 buy token because money is not enough', () => {
//         return erc20Contract.sendTransaction({ from: BUYER_1, value: TOKEN_PRICE / 2, gas: GAS, gasPrice: GAS_PRICE }).then((result) => {
//             Logger.writeLog(result);

//         }).catch((e) => {
//             console.log('');
//         });
//     });

//     it('BUYER_2 buy token', () => {
//         remainingTokens -= 200000 * Math.pow(10, 18);

//         return erc20Contract.sendTransaction({ from: BUYER_2, value: 200000 * TOKEN_PRICE, gas: GAS, gasPrice: GAS_PRICE }).then((result) => {
//             Logger.writeLog(result);
//             return erc20Contract.balanceOf.call(BUYER_2);

//         }).then((result) => {
//             assert.equal(result, 200000 * Math.pow(10, 18));
//             return erc20Contract.balanceOf.call(OWNER_1);

//         }).then((result) => {
//             assert.equal(result, remainingTokens);
//         });
//     });

//     it('BUYER_3 buy token', () => {
//         return erc20Contract.sendTransaction({ from: BUYER_3, value: 1000000 * TOKEN_PRICE, gas: GAS, gasPrice: GAS_PRICE }).then((result) => {
//             Logger.writeLog(result);
//             return erc20Contract.balanceOf.call(BUYER_3);

//         }).then((result) => {
//             assert.equal(result, remainingTokens);
//             return erc20Contract.balanceOf.call(OWNER_1);

//         }).then((result) => {
//             assert.equal(result, 0);
//         });
//     });

//     it('Throw when BUYER_4 buy token because token is not remaining', () => {
//         return erc20Contract.sendTransaction({ from: BUYER_4, value: TOKEN_PRICE, gas: GAS, gasPrice: GAS_PRICE }).then((result) => {
//             Logger.writeLog(result);

//         }).catch((e) => {
//             console.log('');
//         });
//     });

//     it('Throw in onlyMultisig modifier when execute moveFund function', () => {
//         return erc20Contract.moveFund(0x1, 1000000, { from: OWNER_1 }).then((result) => {
//             Logger.writeLog(result);

//         }).catch((e) => {
//             console.log('');
//         });
//     });

//     it('Move fund', () => {
//         var encoded = ethAbi.simpleEncode("moveFund(address,uint)", "0x0000000000002ca283ab1e8a05c0b6707bc03f97", 10000);

//         return multisigContract.submitTransaction(erc20Contract.address, 0, '0x' + new Buffer(encoded).toString('hex'), { from: OWNER_1 }).then((result) => {
//             Logger.writeLog(result);
//             return multisigContract.confirmTransaction(transactionCount++, { from: OWNER_2 });

//         }).then((result) => {
//             Logger.writeLog(result);
// console.log(Utils.getBalance("0x0000000000002ca283ab1e8a05c0b6707bc03f97"));
// console.log(Utils.getBalance(erc20Contract.address));
//             assert.equal(Utils.getBalance("0x0000000000002ca283ab1e8a05c0b6707bc03f97"), 10000);
//         });
//     });

// });