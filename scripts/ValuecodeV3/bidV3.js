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

    let itemId = 0;

    function constructRandomBid(signerId) {
        const minBidAmount = 100; // 最小的随机数
        const maxBidAmount = 1000; // 最大的随机数
        const bidAmount = Math.floor(Math.random() * (maxBidAmount - minBidAmount + 1)) + minBidAmount;

        const offer = {
            bidder : signers[signerId].address,
            receiver : signers[signerId].address,
            bidAmount : hre.ethers.utils.parseUnits(bidAmount.toString(), 18)._hex,
            bidTime : Math.floor(new Date().getTime()/1000),
            extraParams : "0x"
        }
        return offer;
    }

    for (let signerId = 2; signerId < 20; signerId++) {
        const randomBid = constructRandomBid(signerId);
        const bidPool = new hre.ethers.Contract(bidPoolAddress, BidPool.interface, signers[signerId]);
        const bidTx = await bidPool.bid(itemId, randomBid);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
