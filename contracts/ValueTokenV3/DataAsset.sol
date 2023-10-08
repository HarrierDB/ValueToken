// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDataAsset.sol";


abstract contract DataAsset is IDataAsset {


    Item[] public items;
    Offer[][] public offersHistory;


    address public dataCreator; // 存储数据资产的创建者
    address public bidPool; // 存储竞拍池地址

    function getDataCreator() external view override returns (address) {
        return dataCreator;
    }

    function getItem(uint256 tokenId) external view override returns (Item memory) {
        return items[tokenId];
    }

    function getAuctionStatus(uint256 tokenId) external view override returns (uint8) {
        return items[tokenId].auctionStatus;
    }

    function setBidPool(address _bidPool) public override returns (bool) {
        bidPool = _bidPool;
        return true;
    }
}
