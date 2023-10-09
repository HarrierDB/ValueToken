const hre = require("hardhat");
const fs = require('fs');
const {task} = require("hardhat/config");
const { replaceOrAddEnvVariable } = require('../envUtils.js');


// const randomAccounts = JSON.parse(fs.readFileSync('./random_accounts.json', 'utf8'));
// const signers = randomAccounts.map(account => {
//     // Extract the privateKey from each account object
//     const privateKey = account.privateKey;
//
//     // Create a Wallet instance using the private key
//     return new hre.ethers.Wallet(privateKey, hre.ethers.provider);
// });



async function main() {

    const signers = await hre.ethers.getSigners();
    // console.log('Signers show',signers[0].address);

    const DataFactory = await hre.ethers.getContractFactory("DataFactory");
    // 由第一个人signers[0]来部署
    let dataFactory = await DataFactory.connect(signers[0]).deploy("0x054aC9314B05953BB65B155f59C83cbafD512F5b", { gasLimit: 15000000 });
    await dataFactory.deployed();
    console.log(`1. User ${signers[0].address} deployed DataFactory contract at ${dataFactory.address} successfully!`)
    replaceOrAddEnvVariable("DATA_FACTORY_ADDRESS", dataFactory.address);


    // 调用createDataAsset函数
    const name = "YourAssetName";
    const symbol = "YourAssetSymbol";
    const dataType = 0; // 0表示个人价值数据资产，根据你的需求选择合适的dataType
    const dataStandard = 721; // 721表示数据标准，根据你的需求选择合适的dataStandard

    // 换一个人signers[1]来调用createDataAsset函数，
    dataFactory = new hre.ethers.Contract(dataFactory.address, dataFactory.interface, signers[1]);
    const createDataAssetTx = await dataFactory.createDataAsset(name, symbol, dataType, dataStandard);
    const createDataAssetReceipt = await createDataAssetTx.wait();

    // 获取新创建的dataasset地址
    const dataAssetAddress = createDataAssetReceipt.events[1].args[0];
    const dataAssetCreator = createDataAssetReceipt.events[1].args[1];
    console.log(`2. User ${dataAssetCreator} created DataAsset at ${dataAssetAddress} successfully!`);

    replaceOrAddEnvVariable("DATA_ASSET_ADDRESS", dataAssetAddress);

    // 在dataasset里调用createItem函数
    const DataAsset = await hre.ethers.getContractFactory("PersonalValueDataAsset");
    const dataAsset = new hre.ethers.Contract(dataAssetAddress, DataAsset.interface);

    await hre.tenderly.persistArtifacts({
        name: "PersonalValueDataAsset",
        address: dataAssetAddress,
    })

    await hre.tenderly.verify({
        name: "PersonalValueDataAsset",
        address: dataAssetAddress,
    })

    // 还是由signer[1]来发布自己的具体任务
    const uri = "https://www.baidu.com";
    const duration = 7200;
    const startTimestamp = Math.floor(Date.now() / 1000 + 3*24*60*60); // 将时间戳转换为秒
    const taskParams = {startTimestamp: startTimestamp, endTimestamp : startTimestamp + duration, duration : duration}
    const createItemTx = await dataAsset.connect(signers[1]).createItem(uri, taskParams);
    const createItemReceipt = await createItemTx.wait();

    const personalValueCreatedEvent = createItemReceipt.events[5].args;
    const durationInSeconds = personalValueCreatedEvent[5];
    const hours = durationInSeconds / 3600;
    console.log(`3. User ${personalValueCreatedEvent[1]} published task with id=${personalValueCreatedEvent[0]}, link=${personalValueCreatedEvent[2]}, task starts at ${new Date(personalValueCreatedEvent[3] * 1000).toLocaleString()} with duration equaling ${hours.toFixed(2)} hours.`);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
