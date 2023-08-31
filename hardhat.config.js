require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
privateKey = process.env.PRIVATE_KEY;

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
      url: "https://rpc.vnet.tenderly.co/devnet/valuetokentest/bcb8753b-60d3-4216-87cc-d868f3024baf",
      chainId: 1,
      gasPrice: 20000000000, // 可选，设置gas价格
      // 其他可选配置...
    },
  },
};
