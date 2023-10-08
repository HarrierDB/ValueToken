// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IDataAsset.sol";

interface INonFungibleDataAsset{
    // 事件： 数据资产创建
    event ItemCreated(uint256 tokenId, address dataCreator, string uri);
    // 事件：竞拍开始
    event auctionStarted(uint256 tokenId, uint256 startTime, uint256 startPrice, uint256 reservePrice, address bidToken, uint256 auctionDuration, uint256 expirationTime);
    // 事件：出价
    event bidPlaced(uint256 tokenId, address bidder, uint256 bidAmount, uint256 bidTime);

    // 输出数据工厂地址
//    function factory() external view returns (address);
    // 输出数据资产所有者
    function getDataCreator() external view returns (address);

    // 输出item基础信息
    function getItem(uint256 tokenId) external view returns (Item memory);

    // 输出拍卖状态
    // 0： pending 等待拍卖开始
    // 1： open 正在开放，允许竞标者提交出价
    // 2： closed 拍卖已经结束，不再接受新的出价
    // 4： Reserve Not Met (未达到保留价)
    // 5： Winner Declared (获胜者宣布)
    // 6： Expired (过期)
    function getAuctionStatus(uint256 tokenId) external view returns (uint8);

    // uri包含了数据资产的元数据信息，对于个人价值数据，即时间戳、任务戳、任务相关参数，如交付地点等；
    function createItem(string memory uri) external returns (uint256);
    // 为BidPool开的转让接口
    function grantOwnershipToBidPool(uint256 tokenId) external returns (bool);
    // 发起竞拍
    function startAuction(Condition calldata condition) external returns (bool);

    // 结束竞拍
    function endAuction(Condition memory condition) external returns (bool);
}
