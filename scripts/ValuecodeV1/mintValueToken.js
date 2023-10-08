const hre = require("hardhat");
const fs = require('fs');

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    const valueTokenAddress = process.env.VALUE_TOKEN_V2_ADDRESS;
    const valueToken = await hre.ethers.getContractAt("ValueTokenV2", valueTokenAddress);

    const randomAccounts = [];
    const mintAmount = hre.ethers.utils.parseUnits("1000", 18);

    for (let i = 0; i < 15; i++) {
        const randomWallet = hre.ethers.Wallet.createRandom();
        randomAccounts.push(randomWallet);
        const tx = await valueToken.connect(deployer).mint(randomWallet.address, mintAmount);
        await tx.wait();
        console.log(`Minted ${mintAmount} ValueToken to ${randomWallet.address}`);
    }

    // Save the random accounts to a JSON file for future use
    fs.writeFileSync('randomAccounts.json', JSON.stringify(randomAccounts.map(acc => ({address: acc.address, privateKey: acc.privateKey}))));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
