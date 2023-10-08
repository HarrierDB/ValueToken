// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
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
        envContent += `${newEntry}`;
    }
}


async function main() {
    const [deployer, signer] = await hre.ethers.getSigners();

    const DataFactory = await hre.ethers.getContractFactory("DataFactory");
    // 部署
    const dataFactory = await DataFactory.deploy("0x054aC9314B05953BB65B155f59C83cbafD512F5b", { gasLimit: 15000000 });
    console.log(`1. DataFactory contract has been successfully deployed at ${dataFactory.address}!`)
    replaceOrAddEnvVariable("DATA_FACTORY_ADDRESS", dataFactory.address);

    //
    // await hre.tenderly.persistArtifacts({
    //     name: "DataFactory",
    //     address: dataFactory.address,
    // })


    // 调用createDataAsset函数
    const name = "YourAssetName";
    const symbol = "YourAssetSymbol";
    const dataType = 0; // 0表示个人价值数据资产，根据你的需求选择合适的dataType
    const dataStandard = 721; // 721表示数据标准，根据你的需求选择合适的dataStandard

    const createDataAssetTx = await dataFactory.createDataAsset(name, symbol, dataType, dataStandard);
    const createDataAssetReceipt = await createDataAssetTx.wait();

    // 获取新创建的dataasset地址
    const dataAssetAddress = createDataAssetReceipt.events[1].args[0];
    console.log(`2. DataAsset created at ${dataAssetAddress}`);

    replaceOrAddEnvVariable("DATA_ASSET_ADDRESS", dataAssetAddress);
    fs.writeFileSync('.env', envContent, 'utf8');





    // 在dataasset里调用createItem函数
    const DataAsset = await hre.ethers.getContractFactory("NonFungibleDataAsset");
    const dataAsset = new hre.ethers.Contract(dataAssetAddress, DataAsset.interface);

    await hre.tenderly.persistArtifacts({
        name: "NonFungibleDataAsset",
        address: dataAssetAddress,
    })

    await hre.tenderly.verify({
        name: "NonFungibleDataAsset",
        address: dataAssetAddress,
    })


    const createItemTx = await dataAsset.connect(signer).createItem("https://www.baidu.com");
    const createItemReceipt = await createItemTx.wait();

    const itemCreatedEvent = createItemReceipt.events[3].args;
    console.log(`3. User${itemCreatedEvent[1]} successfully published task with id=${itemCreatedEvent[0]} and uri=${itemCreatedEvent[2]}.`);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
