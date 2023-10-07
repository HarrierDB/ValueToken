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
        envContent += `\n${newEntry}`;
    }
}


async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const DataAssetFactory = await ethers.getContractFactory("DataAssetFactory");
    console.log("get contract right.")
    // 估算 gas
    // const estimatedGas = await deployer.estimateGas(await DataAssetFactory.deploy("DataFactory","DF"));
    //
    // console.log(`Estimated Gas: ${estimatedGas.toString()}`);
    // 部署
    const dataFactory = await DataAssetFactory.deploy("DataFactory","DataFactory");
    console.log("get deployed right.")
    //
    // await dataFactory.deployed();
    //
    // console.log(
    //     `DataFactory deployed to ${dataFactory.address}`
    // );
    //
    //
    // replaceOrAddEnvVariable('DATA_FACTORY_ADDRESS', dataFactory.address);
    // // replaceOrAddEnvVariable('VALUE_TOKEN_V2_ADDRESS', valueTokenV2.address);
    // fs.writeFileSync('.env', envContent, 'utf8');


    await hre.tenderly.persistArtifacts({
        name: "DataFactory",
        address: dataFactory.address,
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
