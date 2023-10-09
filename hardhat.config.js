require("@nomicfoundation/hardhat-toolbox");
require("@tenderly/hardhat-tenderly");

require("dotenv").config();
PRIVATE_KEY = process.env.PRIVATE_KEY;
DEVNET_RPC_URL = process.env.DEVNET_RPC_URL;

const tdly = require("@tenderly/hardhat-tenderly");
var fs = require("fs");
tdly.setup({automaticVerifications: true});

const randomAccounts = JSON.parse(fs.readFileSync('./random_accounts.json', 'utf8'));
const accountPrivateKey = randomAccounts.map(account => account.privateKey);

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.1",
    settings:{
      optimizer:{
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "devnet",
  networks: {
    devnet: {
      url: DEVNET_RPC_URL,
      chainId: 1,
      gasPrice: 20000000000, // 可选，设置gas价格
      // 其他可选配置...
      accounts: accountPrivateKey
    }
  },
  tenderly:{
    project: "valuetoken",
    username: "Peanuts"
  }
};
