// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IBidPool {

    function initialize(Condition calldata condition) external;

    function updateCondition(Condition calldata newCondition) external;

    // 发起出价
    function bid(Offer calldata offer) external returns (bool);

    // 增发infocode作为奖励
    function mintInfocode(uint256 amount) internal returns (bool);

    // 计算出价差额
    function calculateRewards(Offer[][] offersHistory) internal returns (mapping (address => uint256));

}
