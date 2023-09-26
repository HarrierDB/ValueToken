// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDataAsset.sol";



// 数据资产基础信息
struct Item {
    uint256 itemId;
    address dataAsset; // 指数据资产地址，需要手动转换成数据资产
    address dataCreator;  // 指数据的最初创建者
    string uri; // 数据资产的URI
    address owner; // 指数据的当前所有者
    address winner; // 指数据的最终获胜者（即劳动或数据的最终购买者）
    uint256 timeCreated; // 数据资产创建时间
    uint8 auctionStatus; // 拍卖状态
    bytes extraParams;
}



// 竞拍开始条件
struct Condition {
    uint256 itemId;
    uint256 startTime;
    uint256 startPrice;
    uint256 reservePrice;
    address bidToken;  //要求的出价代币，通常为Valuecode
    uint256 auctionDuration;
    uint256 expirationTime;
    bytes extraParams;
}


// 出价条件
struct Offer {
    uint256 itemId;
    address bidder; // 出价者
    address receiver; // 接收者，可与出价者不同
    uint256 bidAmount; // 以出价代币为计数货币的出价金额
    uint256 bidTime; //出价时间
    bytes extraParams;
}
