const hre = require("hardhat");

async function main() {
    // 获取部署者和其他测试账户
    const [deployer, testAccount] = await hre.ethers.getSigners();

    // 获取已部署的InformationToken合约
    const InformationToken = await hre.ethers.getContractFactory("InformationToken");
    const informationToken = new hre.ethers.Contract("0x5d569831a189103ae868cea5f07e574abb76620b", InformationToken.interface, testAccount);



    // 准备listInformation函数的参数
    const keyHash = ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("some random string"));
    const auctionDuration = 600; // 以秒为单位，例如600秒
    const description = "This is a test information.";

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
