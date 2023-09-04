require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');
const { ethers } = hre;

async function main() {
    const accounts = await ethers.getSigners();

    // Read the random accounts from the JSON file
    const randomAccounts = JSON.parse(fs.readFileSync('randomAccounts.json', 'utf8'));
    // Connect to the random accounts
    const biddingAccounts = randomAccounts.map(address => hre.ethers.provider.getSigner(address));

    const contractAddress = process.env.ERC721_FORCED_CIRCULATION_ADDRESS; // 从.env文件中获取
    const contract = await ethers.getContractAt("ERC721ForcedCirculation", contractAddress);

    let tokenId = 1;

    for (let i = 0; i < biddingAccounts.length; i++) {
        const user = biddingAccounts[i];
        const guidePrice = await contract.getGuidePrice(tokenId);
        const bidAmount = guidePrice.add(ethers.utils.parseUnits(((i % 10) + 15).toString(), 18)); // 出价高于指导价，并依次递增

        const tx = await contract.connect(user).bid(tokenId, bidAmount);
        await tx.wait();

        console.log(`User${i + 1} bid on tokenId: ${tokenId} with amount: ${ethers.utils.formatUnits(bidAmount, 18)}`);

        // 每10个账户更换一次tokenId
        if ((i + 1) % 10 === 0) {
            tokenId++;
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
