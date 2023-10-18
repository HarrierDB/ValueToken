// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDataAsset.sol";



// 数据资产基础信息
struct BasicInfo {
    uint256 itemId;
    address dataAsset; // 指数据资产地址，需要手动转换成数据资产
    address creator;  // 指数据的最初创建者
    string uri; // 数据资产的URI
    address owner; // 指数据的当前所有者
    address winner; // 指数据的最终获胜者（即劳动或数据的最终购买者）
    uint256 timeCreated; // 数据资产创建时间
    bytes extraParams;
}

// 个人价值数据资产的任务参数
struct TaskParams {
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 duration;
}

// 个人价值数据资产(任务)
struct PersonalValue {
    BasicInfo basicInfo;
    TaskParams taskParams;
}

// 普通数据资产（成包大数据\数商)
struct OrdinalData {
    BasicInfo basicInfo;
    uint256 size; //数据包大小
    bytes encryptedHash; //加密后哈希
}

// 商品数据资产
struct Commodity {
    BasicInfo basicInfo;
    uint256 amount;
}



// 竞拍开始条件
struct Condition {
    uint256 commenceTimestamp;
    uint256 startPrice;
    uint256 reservePrice;
    address bidToken;  //要求的出价代币，通常为Valuecode
    uint256 auctionDuration;
    uint256 expirationTimestamp;
    bytes extraParams;
}


// 出价条件
// todo: batch bid and itemIds
struct Offer {
    address bidder; // 出价者
    address receiver; // 接收者，可与出价者不同
    uint256 bidAmount; // 以出价代币为计数货币的出价总金额
    uint256 bidTime; //出价时间
    bytes extraParams;
}

// 信息含量
struct infoContent {
    address bidder; // 出价者
    uint256 amount; //信含金额
    uint256 bidTime;
}


