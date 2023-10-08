
require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');
const { replaceOrAddEnvVariable } = require('../envUtils.js');

let envContent = fs.readFileSync('.env', 'utf8');

async function main() {
    const [deployer, signer] = await hre.ethers.getSigners();

    const BidPoolFactory = await hre.ethers.getContractFactory("BidPoolFactory");
    const treasury = "0x054aC9314B05953BB65B155f59C83cbafD512F5b"
    // 部署
    const bidPoolFactory = await BidPoolFactory.deploy(treasury, { gasLimit: 15000000 });
    console.log(`3. BidPoolFactory contract has been successfully deployed at ${bidPoolFactory.address}!`);
    replaceOrAddEnvVariable("BID_POOL_FACTORY_ADDRESS", bidPoolFactory.address);

    // 调用createDataAsset函数
    const dataAssetAddress = process.env.DATA_ASSET_ADDRESS;
    const name = "YourName"
    const symbol = "YourAssetSymbol";

    const createBidPoolTx = await bidPoolFactory.createBidPool(name, symbol, dataAssetAddress, 0);
    const createBidPoolReceipt = await createBidPoolTx.wait();

    // 获取新创建的dataasset地址
    const bidPoolAddress = createBidPoolReceipt.events[1].args[0];
    console.log(`4. BidPool created at ${bidPoolAddress}`);
    replaceOrAddEnvVariable("BID_POOL_ADDRESS", bidPoolAddress);
    fs.writeFileSync('.env', envContent, 'utf8');

    const DataAsset = await hre.ethers.getContractFactory("PersonalValueDataAsset");
    const dataAsset = new hre.ethers.Contract(dataAssetAddress, DataAsset.interface);

    const setBidPoolTx = await dataAsset.connect(signer).setBidPool(bidPoolAddress);
    console.log(`5. DataAsset successfully set its corresponding bid pool.`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
