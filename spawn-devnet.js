const util = require('util');
const fs = require('fs');
const dotenv = require("dotenv");
const exec = util.promisify(require('child_process').exec);

dotenv.config();
let envContent = fs.readFileSync('.env', 'utf8');
// 替换或添加环境变量
function replaceOrAddEnvVariable(variableName, variableValue) {
    const regex = new RegExp(`^${variableName}=.*$`, 'm');
    const newEntry = `${variableName}=${variableValue}`;

    if (envContent.match(regex)) {
        // 如果找到了变量，替换它
        envContent = envContent.replace(regex, newEntry);
    } else {
        // 否则，添加新的变量
        envContent += `${newEntry}`;
    }
}

const {
    TENDERLY_ACCESS_KEY,
} = process.env;

const TENDERLY_PROJECT_SLUG="valuetoken";
const TENDERLY_ACCOUNT_ID="2f514053-c655-4e0e-8b7c-863efc3836c4";
const TENDERLY_DEVNET_TEMPLATE="valuetokentest";

let command = `tenderly devnet spawn-rpc --project ${TENDERLY_PROJECT_SLUG} --template ${TENDERLY_DEVNET_TEMPLATE} --account ${TENDERLY_ACCOUNT_ID}  --access_key ${TENDERLY_ACCESS_KEY}`

const createDevNet = async () => {
    const {stderr} = await exec(command);
    const devNetUrl = stderr.trim().toString();

    console.log("DEVNET_RPC_URL=" + devNetUrl)

    replaceOrAddEnvVariable("DEVNET_RPC_URL", devNetUrl);
    fs.writeFileSync('.env', envContent, 'utf8');

}

createDevNet().then(() => {
}).catch((error) => {
});
