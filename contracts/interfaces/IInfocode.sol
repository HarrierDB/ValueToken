// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IInfocode {
    // 增发
    function mint(uint256) external returns (bool);

    // 转换成Valuecode
    function swapIntoValuecode() external returns (bool);

    // 重计量
    function rebase() internal returns (bool);

    // 计算过去一小时内增发的infocode
    function getMintAmount() internal returns (uint256);
}
