// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // 导入 Ownable 合约



contract Valuecode is ERC20, Ownable {

    uint256[] public records; // 记录每个观测的结束时间戳
    uint256[] public metrics; // 记录每个观测的度量衡单位

    constructor() {

    }

    function getLatestRecord() public view returns (uint256) {
        require(records.length() > 0, "No records available.");
        return records[records.length() - 1];
    }

    function getLatestMetric() public view returns (uint256) {
        require(metrics.length() > 0, "No metrics available.");
        return metrics[metrics.length() - 1];
    }


    // 入参是观测的开始时间和结束时间
    // 说白了就是观测bidPool的奖励分布？
    function setLatestMetric(uint256 newValue) public OnlyOwner {
        require(metrics.length() > 0, "No metrics available.");
        metrics[metrics.length() - 1] = newValue;
    }


    //
    function convert() public returns (bool) {
        // 要转的话，必须获得一个上一个时刻的基数（数学期望和方差）

        return true;
    }
}
