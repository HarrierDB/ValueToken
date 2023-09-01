const hre = require("hardhat");

async function main() {

    const [owner, bidder1, bidder2] = await hre.ethers.getSigners();
    console.log("Owner address:", owner.address);
    console.log("Bidder1 address:", bidder1.address);
    console.log("Bidder2 address:", bidder2.address);

    const InformationToken = await hre.ethers.getContractFactory("InformationToken");
    const informationToken = new hre.ethers.Contract("0x27c0c23fbb60417e712e91e4ee104a70edfcc8ed", InformationToken.interface, owner);

    // claim token
    await informationToken.connect(bidder1).claimTokens({gasLimit: 1000000});
    await informationToken.connect(bidder2).claimTokens({gasLimit: 1000000});

    const balance1 = await informationToken.balanceOf(bidder1.address);
    const balance2 = await informationToken.balanceOf(bidder2.address);

    console.log("Bidder 1 balance:", balance1.toString());
    console.log("Bidder 2 balance:", balance2.toString());

    // 无限额度授权
    await informationToken.connect(bidder1).approve(informationToken.address, hre.ethers.constants.MaxUint256);
    await informationToken.connect(bidder2).approve(informationToken.address, hre.ethers.constants.MaxUint256);

    // 检查 allowance
    const allowance1 = await informationToken.allowance(bidder1.address, informationToken.address);
    const allowance2 = await informationToken.allowance(bidder2.address, informationToken.address);

    console.log("Bidder 1 allowance:", allowance1.toString());
    console.log("Bidder 2 allowance:", allowance2.toString());

    // 出价
    const infoIndex = hre.ethers.BigNumber.from("1");  // 将JavaScript数值转换为BigNumber
    // const tokenAmount1 = hre.ethers.BigNumber.from("1");  // 将JavaScript数值转换为BigNumber
    //
    // await informationToken.connect(bidder1).bid(infoIndex, tokenAmount1);
    // console.log("Bid placed by bidder 1");

    const tokenAmount2 = hre.ethers.BigNumber.from("2");  // 将JavaScript数值转换为BigNumber
    await informationToken.connect(bidder2).bid(infoIndex, tokenAmount2);
    console.log("Bid placed by bidder 2");


    // 获取出价历史
    const bids = await informationToken.getBidHistory(infoIndex);
    console.log("Bids:", bids);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
