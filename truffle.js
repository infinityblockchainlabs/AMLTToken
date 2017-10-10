module.exports = {
	networks: {
		development: {
			host: "localhost",
			port: 8545,
			network_id: "*"
		},

		private: {
			host: 'localhost',
			port: 8545,
			network_id: "*",
			gas: 4000000,
			gasPrice: 20000000000,
			from: '0x6f41fffc0338e715e8aac4851afc4079b712af70'
		},

		ropsten: {
			host: '192.168.134.207',
			port: 8545,
			network_id: "*",
			gas: 4000000,
			gasPrice: 20000000000,
			from: '0x3c6381e9dc812d393faf3b0ffc189e798f2775a3'
		},

		mainnet: {
			host: '192.168.134.207',
			port: 8545,
			network_id: "*",
			gas: 4000000,
			gasPrice: 20000000000,
			from: '0x3c6381e9dc812d393faf3b0ffc189e798f2775a3'
		}
	}
};