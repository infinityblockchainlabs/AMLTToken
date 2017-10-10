var Logger = require('./../helpers/logger');
var AMLTAdmin = artifacts.require('./AMLTAdmin.sol');

contract('AMLTAdmin', (accounts) => {

    const OPERATOR_1 = accounts[0];
    const OPERATOR_2 = accounts[1];
    const OPERATOR_3 = accounts[2];

    var adminContract;

    it('Prepare before test', () => {
        return AMLTAdmin.new(OPERATOR_1).then((instance) => {
            adminContract = instance;
        });
    });

    it('Throw in onlyOperator modifier when execute addOperator function', () => {
        return adminContract.addOperator(OPERATOR_3, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Throw in notNull modifier when execute addOperator function', () => {
        return adminContract.addOperator(0x0, { from: OPERATOR_1 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Add OPERATOR_2', () => {
        return adminContract.addOperator(OPERATOR_2, { from: OPERATOR_1 }).then((result) => {
            Logger.printLog(result);
            return adminContract.operatorList.call(OPERATOR_2);

        }).then((result) => {
            assert.equal(result, true);
        });
    });

    it('Can\'t add OPERATOR_2 because OPERATOR_2 existed', () => {
        return adminContract.addOperator(OPERATOR_2, { from: OPERATOR_1 }).then((result) => {
            Logger.printLog(result);
        });
    });

    it('Throw in onlyOperator modifier when execute removeOperator function', () => {
        return adminContract.removeOperator(OPERATOR_1, { from: OPERATOR_3 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Remove OPERATOR_1', () => {
        return adminContract.removeOperator(OPERATOR_1, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
            return adminContract.operatorList.call(OPERATOR_1);

        }).then((result) => {
            assert.equal(result, false);
        });
    });

    it('Can\'t remove OPERATOR_1 because OPERATOR_1 is not exist', () => {
        return adminContract.removeOperator(OPERATOR_1, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
        });
    });

    it('Throw in onlyOperator modifier when execute replaceOperator function', () => {
        return adminContract.replaceOperator(OPERATOR_2, OPERATOR_3, { from: OPERATOR_1 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Throw in notNull modifier when execute replaceOperator function', () => {
        return adminContract.replaceOperator(OPERATOR_2, 0x0, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);

        }).catch((e) => {
            console.log('');
        });
    });

    it('Can\'t replace OPERATOR_1 to OPERATOR_3 because OPERATOR_1 is not exist', () => {
        return adminContract.replaceOperator(OPERATOR_1, OPERATOR_3, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
        });
    });

    it('Add OPERATOR_3', () => {
        return adminContract.addOperator(OPERATOR_3, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
            return adminContract.operatorList.call(OPERATOR_3);

        }).then((result) => {
            assert.equal(result, true);
        });
    });

    it('Can\'t replace OPERATOR_2 to OPERATOR_3 because OPERATOR_3 existed', () => {
        return adminContract.replaceOperator(OPERATOR_2, OPERATOR_3, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
        });
    });

    it('Replace OPERATOR_2 to OPERATOR_1', () => {
        return adminContract.replaceOperator(OPERATOR_2, OPERATOR_1, { from: OPERATOR_2 }).then((result) => {
            Logger.printLog(result);
            return adminContract.operatorList.call(OPERATOR_2);

        }).then((result) => {
            assert.equal(result, false);
            return adminContract.operatorList.call(OPERATOR_1);

        }).then((result) => {
            assert.equal(result, true);
        });
    });

});