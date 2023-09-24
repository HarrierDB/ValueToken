require('dotenv').config();
const hre = require("hardhat");
const { ethers } = hre;
const fs = require('fs');

async function main() {
    const accounts = await ethers.getSigners();
    const testAccounts = accounts.slice(0, 10); // 取前10个账户

    const contractAddress = process.env.ERC721_FORCED_CIRCULATION_ADDRESS; // 从.env文件中获取
    const contract = await ethers.getContractAt("ERC721ForcedCirculation", contractAddress);

    const auctionTimeDuration = 60 * 60 * 24 * 7; // 7 days

    // const uri = 'https://gist.githubusercontent.com/HarrierDB/4df3ae0a5f36a3171d6484bb3f815532/raw'
    const uri = "https://gist.githubusercontent.com/HarrierDB/135cfbfbb25840ffd71dd4c2b39ab3e3/raw"

    for (let i = 0; i < testAccounts.length; i++) {
        const user = testAccounts[i];
        const valueAmount = ethers.utils.parseUnits((100 * (i + 1)).toString(), 18); // 指导价格依次递增

        const tx = await contract.connect(user).publishItem(uri, valueAmount, auctionTimeDuration);
        await tx.wait();

        console.log(`User${i + 1} published an item with URI: "${uri}" and guide price: ${100 * (i + 1)}`);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
