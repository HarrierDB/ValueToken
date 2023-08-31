// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const InformationToken = await hre.ethers.getContractFactory("InformationToken");
  const informationToken = await InformationToken.deploy('InformationToken', 'INFO');

  await informationToken.deployed();

  console.log(
    `Information token deployed to ${informationToken.address}`
  );

  const ValueToken = await hre.ethers.getContractFactory("ValueToken");
  const valueToken = await ValueToken.deploy('ValueToken','VALUE', informationToken.address);

  await valueToken.deployed();

  console.log(
      `Value token deployed to ${valueToken.address}`
  );
 
  const mintTx = await informationToken.mint(['0x380CF025FB4763e6C3b811938c12e4790496925f'], [1000]);

  await hre.tenderly.persistArtifacts({
    name: "informationToken",
    address: informationToken.address,
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
