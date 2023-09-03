// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('fs');

async function main() {
    const ERC721ForcedCirculation = await hre.ethers.getContractFactory("ERC721ForcedCirculation");
    const eRC721ForcedCirculation = await ERC721ForcedCirculation.deploy('ERC721ForcedCirculation', 'ERC721FC');

    await eRC721ForcedCirculation.deployed();

    console.log(
        `Information token deployed to ${eRC721ForcedCirculation.address}`
    );

    const ValueTokenV2 = await hre.ethers.getContractFactory("ValueTokenV2");
    const valueTokenV2 = await ValueTokenV2.deploy('ValueTokenV2','VALUEV2');

    await valueTokenV2.deployed();

    console.log(
        `Value token deployed to ${valueTokenV2.address}`
    );

    fs.appendFileSync('.env', `\nERC721_FORCED_CIRCULATION_ADDRESS=${eRC721ForcedCirculation.address}`);
    fs.appendFileSync('.env', `\nVALUE_TOKEN_V2_ADDRESS=${valueTokenV2.address}`);


    await hre.tenderly.persistArtifacts({
        name: "ERC721ForcedCirculation",
        address: eRC721ForcedCirculation.address,
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
