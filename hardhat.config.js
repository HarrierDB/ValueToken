require("@nomicfoundation/hardhat-toolbox");
require("@tenderly/hardhat-tenderly");

require("dotenv").config();
privateKey = process.env.PRIVATE_KEY;

const tdly = require("@tenderly/hardhat-tenderly");
tdly.setup({automaticVerifications: true});

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
      url: "https://rpc.vnet.tenderly.co/devnet/valuetokentest/448efe38-bffb-4ea7-a704-176d1b148da7",
      chainId: 1,
      gasPrice: 20000000000, // 可选，设置gas价格
      // 其他可选配置...
    },
  },
  tenderly:{
    project: "valuetoken",
    username: "Peanuts",
  }
};
