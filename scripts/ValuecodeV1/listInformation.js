const hre = require("hardhat");

async function main() {
    // 获取部署者和其他测试账户
    const [deployer, testAccount] = await hre.ethers.getSigners();

    // 获取已部署的InformationToken合约
    const InformationToken = await hre.ethers.getContractFactory("InformationToken");
    const informationToken = new hre.ethers.Contract("0x7589347fe7b52c7da161f9abc2d36a5d26786bf3", InformationToken.interface, testAccount);



    // 准备listInformation函数的参数
    const keyHash = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("交割"));
    const auctionDuration = 60000000000000; // 以秒为单位，例如600秒
    const description = "眼镜，品牌：XX,种类：墨镜、功能：防紫外线，材质：树脂.";

    // 使用测试账户调用listInformation函数
    const listInformationTx = await informationToken.connect(testAccount).listInformation(keyHash, auctionDuration, description);

    // 等待交易被确认
    await listInformationTx.wait();

    console.log(`listInformation function called from account: ${testAccount.address}`);
}

// 执行脚本并捕获错误
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
