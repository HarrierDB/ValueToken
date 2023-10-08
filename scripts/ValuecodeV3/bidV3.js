require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');
const { ethers } = hre;

async function main() {
    const accounts = await ethers.getSigners();

    // Read the random accounts from the JSON file
    const randomAccounts = JSON.parse(fs.readFileSync('randomAccounts.json', 'utf8'));
    // Connect to the random accounts
    const biddingAccounts = randomAccounts.map(account => hre.ethers.provider.getSigner(account.address));

    // 首先通过env里的bid pool address来构成 bid pool对象以使用其bid函数
    const bidPoolAddress = process.env.BID_POOL_ADDRESS;
    const BidPool = await hre.ethers.getContractFactory("BidPool");

    const bidPool = new hre.ethers.Contract(bidPoolAddress, BidPool.interface);

    let itemId = 0;

    const commenceTimestamp = Math.floor(Date.now()/1000+3600);
    const auctionDuration = 3*3600;
    const expirationTime = commenceTimestamp + auctionDuration;

    const condition = {
        commenceTimestamp: commenceTimestamp, // 一小时以后开始竞拍
        startPrice: ethers.utils.parseUnits("100", 18),
        reservePrice: ethers.utils.parseUnits("50", 18),
        bidToken: "0x3c0b6110994DCcCaafEE985D020f00840E57b1ef", // 你的代币地址
        auctionDuration: auctionDuration, //竞拍持续3个小时
        expirationTimestamp: expirationTime,
        extraParams: "0x" // 你的额外参数
    }

    const initializeTx = await bidPool.connect(accounts[0]).initialize(itemId, condition);
    console.log("6. Bid Pool is successfully initialized.");

    async function fetchCondition() {
        const ConditionGot = await bidPool.getConditionByItemId(itemId);
        console.log(`BID_POOL_ADDRESS ${bidPoolAddress} id=${itemId} successfully set bidding condition= ${ConditionGot}.`);
    }

    await fetchCondition();

    // for (let i = 0; i < biddingAccounts.length; i++) {
    //     const user = biddingAccounts[i];
    //     const basicPrice = await contract.getGuidePrice(itemId);
    //     const bidAmount = basicPrice.add(ethers.utils.parseUnits(((i % 10) + 15).toString(), 18)); // 出价高于指导价，并依次递增
    //
    //     const bidTx = await bidPool.connect(user).bid(itemId, bidAmount);
    //     await bidTx.wait();
    //
    //     console.log(`User${i + 1} bid on tokenId: ${itemId} with amount: ${ethers.utils.formatUnits(bidAmount, 18)}`);
    //
    //     // 每10个账户更换一次tokenId
    //     if ((i + 1) % 10 === 0) {
    //         tokenId++;
    //     }
    // }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
