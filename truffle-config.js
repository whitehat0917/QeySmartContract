var HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = '';
const apiKey = '';

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    testnet: {
      networkCheckTimeout: 10000,
      provider: () => new HDWalletProvider(MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(MNEMONIC, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    ropsten: {
      networkCheckTimeout: 10000,
      provider: () => new HDWalletProvider(MNEMONIC, `https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`),
      network_id: 3,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: apiKey
  },
  compilers: {
    solc: {
      version: "^0.8.0"
    }
  }
};