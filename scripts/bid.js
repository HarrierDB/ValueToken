const hre = require("hardhat");

async function main() {

    const [owner, bidder1, bidder2, bidder3, bidder4, bidder5, bidder6, bidder7] = await hre.ethers.getSigners();
    const bidders = [bidder1, bidder2, bidder3, bidder4, bidder5, bidder6, bidder7];

    let currentBid = hre.ethers.BigNumber.from("7"); // 初始出价
    const infoIndex = hre.ethers.BigNumber.from("0");  // 将JavaScript数值转换为BigNumber

    const InformationToken = await hre.ethers.getContractFactory("InformationToken");
    const informationToken = new hre.ethers.Contract("0x7589347fe7b52c7da161f9abc2d36a5d26786bf3", InformationToken.interface, owner);

    // 循环为每个出价者进行出价 //0x9dC2980387fBC589B2d232dD5cB85CeE0eE95868 ValueToken
    for (const bidder of bidders) {
        // claim tokens
        await informationToken.connect(bidder).claimTokens();
        // approve
        await informationToken.connect(bidder).approve(informationToken.address, hre.ethers.constants.MaxUint256);

        currentBid = currentBid.add(100); // 每次增加1

        // 执行出价操作
        await informationToken.connect(bidder).bid(infoIndex, currentBid);

        console.log(`Bidder ${bidder.address} placed a bid of ${currentBid.toString()}`);
    }

    // 获取出价历史
    const bids = await informationToken.getBidHistory(infoIndex);
    console.log("Bids:", bids);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
