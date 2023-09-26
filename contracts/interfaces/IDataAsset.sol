// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDataAsset {

    // 发布个人价值数据与个人数据资产
    event ItemPublished(uint256 itemId, address publisher, string uri, uint256 guidePrice, uint256 publishTime, uint256 auctionDuration);

    // 输出数据工厂地址
    function factory() external view returns (address);
    // 输出数据资产所有者
    function owner() external view returns (address);
    // 输出拍卖状态
    function auctionStatus() external view returns (uint8);

    // 发布项目
    function publishItem(string memory uri) external returns (uint256);

    // 发起竞拍
    function launchAuction(uint256 itemId, uint256 startPrice, uint256 auctionDuration) external returns (bool);
    // 发起出价
    function bid(uint256 itemId, uint256 price) external returns (bool);
    // 结束竞拍
    function endAuction(uint256 itemId) external returns (bool);
}
