// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";
import "../libraries/Offer.sol";

interface IDataAsset {

    // 输出数据工厂地址
    function factory() external view returns (address);
    // 输出数据资产所有者
    function owner() external view returns (address);

    // 输出拍卖状态
    // 1： open 正在开放，允许竞标者提交出价
    // 2： closed 拍卖已经结束，不再接受新的出价
    // 4： Reserve Not Met (未达到保留价)
    // 5： Winner Declared (获胜者宣布)
    // 6： Expired (过期)
    function auctionStatus(uint256 tokenId) external view returns (uint8);

    // 发起竞拍
    function startAuction(Condition calldata condition) external returns (bool);
    // 发起出价
    function bid(Offer calldata offer) external returns (bool);
    // 结束竞拍
    function endAuction(uint256 tokenId) external returns (bool);
}
