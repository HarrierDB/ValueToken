// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IBidPool {


    function initialize(uint256 itemId, Condition calldata condition) external;

    function getConditionByItemId(uint256 itemId) external view returns (Condition calldata);

    // 发起出价
    function bid(uint256 itemId, Offer calldata offer) external returns (uint256);

}
