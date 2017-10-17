var Logger = require('./../helpers/logger');
var AMLT = artifacts.require('./AMLT.sol');

contract('AMLT', (accounts) => {

    const HOLDER_1 = accounts[0];
    const HOLDER_2 = accounts[1];
    const HOLDER_3 = accounts[2];

    const USER_1 = accounts[3];
    const USER_2 = accounts[4];
    const USER_3 = accounts[5];

    var amltContract;
    var holder1Balance, holder2Balance;

    it('Prepare before test', () => {
        return AMLT.new(HOLDER_1, HOLDER_2, HOLDER_3).then((instance) => {
            amltContract = instance;
            return amltContract.balanceOf.call(HOLDER_1);

        }).then((result) => {
            holder1Balance = result;
            return amltContract.balanceOf.call(HOLDER_2);

        }).then((result) => {
            holder2Balance = result;
        });
    });

    it('Allow USER_1 to use tokens from HOLDER_1 with specific amount', () => {
        return amltContract.approve(USER_1, 1000 * Math.pow(10, 18), { from: HOLDER_1 }).then((result) => {
            Logger.printLog(result);
            return amltContract.allowance.call(HOLDER_1, USER_1);

        }).then((result) => {
            assert.equal(result, 1000 * Math.pow(10, 18));
        });
    });

    it('USER_1 transfer tokens from HOLDER_1 to USER_2', () => {
        holder1Balance -= 200 * Math.pow(10, 18);

        return amltContract.transferFrom(HOLDER_1, USER_2, 200 * Math.pow(10, 18), { from: USER_1 }).then((result) => {
            Logger.printLog(result);
            return amltContract.balanceOf.call(HOLDER_1);

        }).then((result) => {
            assert.equal(result, holder1Balance);
            return amltContract.balanceOf.call(USER_2);

        }).then((result) => {
            assert.equal(result, 200 * Math.pow(10, 18));
            return amltContract.allowance.call(HOLDER_1, USER_1);

        }).then((result) => {
            assert.equal(result, 800 * Math.pow(10, 18));
        });
    });

    it('USER_1 can\'t transfer 1000 tokens from HOLDER_1 to USER_3 because USER_1 is only used 800 tokens from HOLDER_1', () => {
        return amltContract.transferFrom(HOLDER_1, USER_3, 1000 * Math.pow(10, 18), { from: USER_1 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Allow USER_1 to use tokens from HOLDER_2 with specific amount', () => {
        return amltContract.approve(USER_1, 2 * holder2Balance, { from: HOLDER_2 }).then((result) => {
            Logger.printLog(result);
            return amltContract.allowance.call(HOLDER_2, USER_1);

        }).then((result) => {
            assert.equal(result, 2 * holder2Balance);
        });
    });

    it('USER_1 can\'t transfer tokens from HOLDER_2 to USER_3 because balance of HOLDER_2 is not enough', () => {
        return amltContract.transferFrom(HOLDER_2, USER_3, 2 * holder2Balance, { from: USER_1 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('HOLDER_2 transfer tokens to USER_1', () => {
        holder2Balance -= 200 * Math.pow(10, 18);

        return amltContract.transfer(USER_1, 200 * Math.pow(10, 18), { from: HOLDER_2 }).then((result) => {
            Logger.printLog(result);
            return amltContract.balanceOf.call(HOLDER_2);

        }).then((result) => {
            assert.equal(result, holder2Balance);
            return amltContract.balanceOf.call(USER_1);

        }).then((result) => {
            assert.equal(result, 200 * Math.pow(10, 18));
        });
    });

    it('HOLDER_2 can\'t transfer 0 token to USER_2', () => {
        return amltContract.transfer(USER_2, 0, { from: HOLDER_2 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

});