// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/ERC20.sol";


contract Valuecode is ERC20 {

    uint256[] public records; // 记录每个观测的结束时间戳
    uint256[] public metrics; // 记录每个观测的度量衡单位
    uint256 private topUpRate; // CNY转换比例

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {

    }

    function getLatestRecord() public view returns (uint256) {
        require(records.length > 0, "No records available.");
        return records[records.length - 1];
    }

    function getLatestMetric() public view returns (uint256) {
        require(metrics.length > 0, "No metrics available.");
        return metrics[metrics.length - 1];
    }


    // 入参是观测的开始时间和结束时间
    // 说白了就是观测bidPool的奖励分布？
    function setLatestMetric(uint256 newValue) public {
        require(metrics.length > 0, "No metrics available.");
        metrics[metrics.length - 1] = newValue;
    }


    //
    function convert() public returns (bool) {
        // 要转的话，必须获得一个上一个时刻的基数（数学期望和方差）

        return true;
    }

    function topUp(uint256 amount) public returns (bool) {
        // 人民币转成valuecode的入口
        _balances[msg.sender] += amount * topUpRate;
        return true;
    }

    function setTopUpRate(uint256 _topUpRate) public returns (bool) {
        // 设置CNY转换比例
        topUpRate = _topUpRate;
        return true;
    }
}
