var Logger = function () {
};

/**
 * Print log
 */
Logger.printLog = function (result) {
    var logs = result.logs

    console.log('\x1b[36m');
    console.log('    TXID :', result.tx);

    if (result.receipt) {
        console.log('    GAS  :', result.receipt.gasUsed);
    }

    if (!logs) {
        console.log('\x1b[37m');
        return;
    }

    for (var i = 0; i < logs.length; i++) {
        var log = logs[i];
        console.log('    EVENT:', log.event);

        for (var key in log.args) {
            console.log('          ', key, log.args[key].toString());
        }
    }

    console.log('\x1b[37m');
};

module.exports = Logger;