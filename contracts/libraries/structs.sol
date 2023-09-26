// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// 竞拍条件
struct Condition {
    uint256 tokenId;
    uint256 startPrice;
    uint256 startTime;
    uint256 reservePrice;
    uint256 auctionDuration;
    uint256 expirationTime;
    bytes calldata data;
}

struct Offer {
    uint256 tokenId;
    uint256 price;
    bytes calldata data;
}
