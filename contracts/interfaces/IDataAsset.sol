// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDataAsset {

    // 发布个人价值数据与个人数据资产
    event ItemPublished(uint256 itemId, address publisher, string uri, uint256 guidePrice, uint256 publishTime, uint256 auctionDuration);

    // 输出数据工厂地址
    function factory() external view returns (address);
    // 输出数据资产所有者
    function owner() external view returns (address);

    //
}
