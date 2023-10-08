// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');

let envContent = fs.readFileSync('.env', 'utf8');
// 替换或添加环境变量
function replaceOrAddEnvVariable(variableName, variableValue) {
    const regex = new RegExp(`^${variableName}=.*$`, 'm');
    const newEntry = `${variableName}=${variableValue}`;

    if (envContent.match(regex)) {
        // 如果找到了变量，替换它
        envContent = envContent.replace(regex, newEntry);
    } else {
        // 否则，添加新的变量
        envContent += `\n${newEntry}`;
    }
}


async function main() {
    const [deployer, signer] = await hre.ethers.getSigners();

    const BidPoolFactory = await hre.ethers.getContractFactory("BidPoolFactory");
    // 部署
    const bidPoolFactory = await BidPoolFactory.deploy("0x054aC9314B05953BB65B155f59C83cbafD512F5b", { gasLimit: 15000000 });
    console.log(`3. BidPoolFactory contract has been successfully deployed at ${bidPoolFactory.address}!`);
    replaceOrAddEnvVariable("BID_POOL_FACTORY_ADDRESS", bidPoolFactory.address);

    // 调用createDataAsset函数
    const dataAssetAddress = process.env.DATA_ASSET_ADDRESS;
    const name = "YourName"
    const symbol = "YourAssetSymbol";

    const createBidPoolTx = await bidPoolFactory.createBidPool(dataAssetAddress, name, symbol);
    const createBidPoolReceipt = await createBidPoolTx.wait();

    // 获取新创建的dataasset地址
    const bidPoolAddress = createBidPoolReceipt.events[1].args[0];
    console.log(`4. BidPool created at ${bidPoolAddress}`);
    replaceOrAddEnvVariable("BID_POOL_ADDRESS", bidPoolAddress);
    fs.writeFileSync('.env', envContent, 'utf8');

    const DataAsset = await hre.ethers.getContractFactory("NonFungibleDataAsset");
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
