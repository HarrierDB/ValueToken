const hre = require("hardhat");
require('dotenv').config();
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    // Replace with your deployed ValueTokenV2 contract address
    const valueTokenV2Address = process.env.VALUE_TOKEN_V2_ADDRESS
    const valueTokenV2 = await hre.ethers.getContractAt("ValueTokenV2", valueTokenV2Address);
    // get erc721forcirculation contract
    const erc721Address = process.env.ERC721_FORCED_CIRCULATION_ADDRESS; // 从.env文件中获取
    const eRC721ForcedCirculation = await hre.ethers.getContractAt("ERC721ForcedCirculation", erc721Address);


    const authorizeTx = await valueTokenV2.connect(deployer).authorizeERC721Address(erc721Address);
    await authorizeTx.wait();
    console.log(`Authorized ERC721 address ${erc721Address} for ValueTokenV2`);

    const setTokenTx = await eRC721ForcedCirculation.connect(deployer).setValueToken(valueTokenV2Address);
    await setTokenTx.wait();
    console.log(`Set ValueTokenV2 address ${valueTokenV2Address} for ERC721ForcedCirculation`);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
