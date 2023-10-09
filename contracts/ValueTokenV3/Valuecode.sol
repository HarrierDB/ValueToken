// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Valuecode {

    mapping(uint256 => uint256) public metrics; // 键是结束时间戳，值是过去一个小时内的价值的数学期望，即度量衡单位，默认计算出来也可以人为设定

    constructor(){

    }

    function getLatestMetric() public view returns (uint256) {
        require(metrics.length() > 0, "No metrics available.");
        return metrics[metrics.length() - 1];
    }


    // 入参是观测的开始时间和结束时间
    // 说白了就是观测bidPool的奖励分布？
    function setLatestMetric(uint256 newValue) public {
        require(metrics.length() > 0, "No metrics available.");
        metrics[metrics.length() - 1] = newValue;
    }


    //
    function convert() public returns (bool) {
        // 要转的话，必须获得一个上一个时刻的基数（数学期望和方差）

        return true;
    }
}
