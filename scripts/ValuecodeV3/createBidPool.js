
require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');
const { replaceOrAddEnvVariable } = require('../envUtils.js');

let envContent = fs.readFileSync('.env', 'utf8');

async function main() {
    const signers = await hre.ethers.getSigners();

    const BidPoolFactory = await hre.ethers.getContractFactory("BidPoolFactory");
    const treasury = "0x054aC9314B05953BB65B155f59C83cbafD512F5b" //资金库地址
    // 由第一个人来部署
    let bidPoolFactory = await BidPoolFactory.connect(signers[0]).deploy(treasury, { gasLimit: 15000000 });
    console.log(`3. User ${signers[0].address} deployed BidPoolFactory contract at ${bidPoolFactory.address} successfully!`);
    replaceOrAddEnvVariable("BID_POOL_FACTORY_ADDRESS", bidPoolFactory.address);

    // 调用createDataAsset函数
    const dataAssetAddress = process.env.DATA_ASSET_ADDRESS;
    const name = "Do Chores";
    const symbol = "CHR";

    // 换一个人signers[1]来调用createBidPool函数
    bidPoolFactory = new hre.ethers.Contract(bidPoolFactory.address, bidPoolFactory.interface, signers[1]);
    const createBidPoolTx = await bidPoolFactory.createBidPool(name, symbol, dataAssetAddress, 0);
    const createBidPoolReceipt = await createBidPoolTx.wait();

    // 获取新创建的dataasset地址
    const bidPoolAddress = createBidPoolReceipt.events[1].args[0];
    console.log(`4. User ${signers[1].address} created BidPool at ${bidPoolAddress}`);
    replaceOrAddEnvVariable("BID_POOL_ADDRESS", bidPoolAddress);

    const DataAsset = await hre.ethers.getContractFactory("PersonalValueDataAsset");
    const dataAsset = new hre.ethers.Contract(dataAssetAddress, DataAsset.interface, signers[1]);

    const setBidPoolTx = await dataAsset.setBidPool(bidPoolAddress);
    console.log(`5. User ${signers[1].address} set DataAsset's corresponding bid pool with address=${bidPoolAddress}.`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
