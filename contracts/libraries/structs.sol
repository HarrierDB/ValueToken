// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// 竞拍条件
struct Condition {
    uint256 tokenId;
    uint256 startPrice;
    uint256 auctionDuration;
}

struct Offer {
    uint256 tokenId;
    uint256 price;
    bytes calldata data;
}
