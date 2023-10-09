require('dotenv').config();
const hre = require("hardhat");
const fs = require('fs');
const { ethers } = hre;

async function main() {
    const signers = await ethers.getSigners();

    // 首先通过env里的bid pool address来构成 bid pool对象以使用其bid函数
    const bidPoolAddress = process.env.BID_POOL_ADDRESS;
    const BidPool = await hre.ethers.getContractFactory("BidPool");

    // signers[1] 来initialize bid pool
    const bidPool = new hre.ethers.Contract(bidPoolAddress, BidPool.interface, signers[1]);

    let itemId = 0;

    const commenceTimestamp = Math.floor(Date.now()/1000);
    const auctionDuration = 3*3600;
    const expirationTime = commenceTimestamp + auctionDuration;

    const condition = {
        commenceTimestamp: commenceTimestamp, // 一小时以后开始竞拍
        startPrice: ethers.utils.parseUnits("100", 18),
        reservePrice: ethers.utils.parseUnits("50", 18),
        bidToken: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // 用WETH做测试
        auctionDuration: auctionDuration, //竞拍持续3个小时
        expirationTimestamp: expirationTime,
        extraParams: "0x" // 你的额外参数
    }

    const initializeTx = await bidPool.initialize(itemId, condition);
    console.log(`6. User ${signers[1].address} initialized Bid Pool successfully.`);

    async function fetchCondition() {
        const ConditionGot = await bidPool.getConditionByItemId(itemId);
        const commenceTimestamp = new Date(ConditionGot.commenceTimestamp * 1000).toLocaleString();
        const startPrice = ethers.utils.formatUnits(ConditionGot.startPrice, 18);
        const reservePrice = ethers.utils.formatUnits(ConditionGot.reservePrice, 18);
        const bidToken = ConditionGot.bidToken;
        const expirationTimestamp = new Date(ConditionGot.expirationTimestamp * 1000).toLocaleString();
        console.log(`7. BID_POOL_ADDRESS ${bidPoolAddress} id=${itemId} bid commences at ${commenceTimestamp}, ends at ${expirationTimestamp}, startPrice=${startPrice}, reservePrice=${reservePrice}, bidToken=${bidToken}.`);
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
