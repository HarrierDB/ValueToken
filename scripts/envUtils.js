// envUtils.js

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

module.exports = { replaceOrAddEnvVariable };
