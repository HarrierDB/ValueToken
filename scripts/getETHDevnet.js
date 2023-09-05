const axios = require('axios');
const fs = require('fs');

require("dotenv").config();
DEVNET_RPC_URL = process.env.DEVNET_RPC_URL;

async function sendCustomRPC() {
    // 读取并解析randomAccounts.json文件
    const randomAccountsJSON = fs.readFileSync('../randomAccounts.json', 'utf8');
    const randomAccounts = JSON.parse(randomAccountsJSON);
    const addresses = randomAccounts.map(account => account.address);

    const data = {
        jsonrpc: "2.0",
        method: "tenderly_setBalance",
        params: [
            addresses,
            "0x56BC75E2D63100000"
        ],
        id: "1234"
    };

    const config = {
        headers: {
            "Content-Type": "application/json"
        }
    };

    try {
        const response = await axios.post(`${DEVNET_RPC_URL}:8545`, data, config); // 替换为你的Ethereum节点的URL
        console.log("Response:", response.data);
    } catch (error) {
        console.error("Error:", error);
    }
}

sendCustomRPC();
