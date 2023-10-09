require('dotenv').config();
const axios = require('axios');
const hre = require("hardhat");
const fs = require("fs");

DEVNET_RPC_URL = process.env.DEVNET_RPC_URL;

// function generateRandomAccountsSync() {
//     const numberOfAccounts = 110;
//     const accounts = [];
//
//     for (let i = 0; i < numberOfAccounts; i++) {
//         const wallet = hre.ethers.Wallet.createRandom();
//         const account = {
//             address: wallet.address,
//             privateKey: wallet.privateKey
//         };
//         accounts.push(account);
//     }
//
//     const jsonAccounts = JSON.stringify(accounts, null, 2);
//
//     try {
//         fs.writeFileSync('random_accounts.json', jsonAccounts);
//         console.log('Random accounts saved to random_accounts.json');
//     } catch (err) {
//         console.error('Error writing to file:', err);
//     }
// }
//
// generateRandomAccountsSync();

const randomAccounts = JSON.parse(fs.readFileSync('./random_accounts.json', 'utf8'));
const accountAddresses = randomAccounts.map(account => account.address);

const requestData = {
    jsonrpc: '2.0',
    method: 'tenderly_setBalance',
    params: [
        accountAddresses,
        '0x8AC7230489E80000',
    ],
    id: '1234',
};
axios
    .post(DEVNET_RPC_URL, requestData)
    .then((response) => {
        console.log('Response:', response.data);
        console.log('Successfully set balances for accounts.')
    })
    .catch((error) => {
        console.error('Error:', error);
    });



// async function printBalances() {
//     const accountSigners = randomAccounts.map(account => hre.ethers.provider.getSigner(account.address));
// // print out the balances of accountSigners
//     for (let i = 0; i < accountSigners.length; i++) {
//         console.log(`Account ${i + 1} address: ${accountSigners[i]._address}`);
//         let balance = await hre.ethers.provider.getBalance(accountSigners[i]._address);
//         console.log(`Account ${i + 1} has balance: ${hre.ethers.utils.formatEther(balance)}`);
//     }
// }
//
// printBalances().then(() => process.exit(0));