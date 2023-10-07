// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IBidPool {

    function initialize(Condition calldata condition) external;

    function updateCondition(Condition calldata newCondition) external;

    // 发起出价
    function bid(Offer calldata offer) external returns (bool);

    // 增发infocode作为奖励 todo
//    function mintInfocode(uint256 amount) internal returns (bool);

    // 分发奖励 todo
//    function distributeRewards(mapping (address => uint256) rewardHistory) public returns (mapping(uint256 => uint256));

    // 计算出价差额 todo
//    function calculateRewards(Offer[][] offersHistory) internal returns (bool);

}
