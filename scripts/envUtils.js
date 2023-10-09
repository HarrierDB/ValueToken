// envUtils.js
const fs = require("fs");

function replaceOrAddEnvVariable(variableName, variableValue) {
    let envContent = fs.readFileSync('.env', 'utf8');
    const regex = new RegExp(`^${variableName}=.*$`, 'm');
    const newEntry = `${variableName}=${variableValue}`;

    if (envContent.match(regex)) {
        // 如果找到了变量，替换它
        envContent = envContent.replace(regex, newEntry);
    } else {
        // 否则，添加新的变量
        envContent += `${newEntry}`;
    }
    fs.writeFileSync('.env', envContent, 'utf8');

}

module.exports = { replaceOrAddEnvVariable };
