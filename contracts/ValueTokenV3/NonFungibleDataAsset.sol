// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDataAsset.sol";

contract NonFungibleDataAsset is IDataAsset, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenCounter;

    Item[] public items;

    address public immutable dataCreator; // 存储数据资产的创建者

    constructor(string memory name, string memory symbol) ERC721URIStorage() {
        dataCreator = msg.sender;
    }

    function dataCreator() external view override returns (address) {
        return dataCreator;
    }

    function createItem(string memory uri) external override returns (uint256) {
        _tokenCounter.increment();
        uint256 tokenId = _tokenCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        items[tokenId] = Item({
            itemId : tokenId,
            dataAsset : address(this),
            dataCreator : msg.sender,
            uri : uri,
            owner : msg.sender,
            timeCreated : block.timestamp,
            offerHistory : new Offer[](0),
            extraParams: "0x"
        });

        emit ItemCreated(tokenId, msg.sender, uri);

        return tokenId;
    }

    function startAuction(Condition calldata condition) external override returns (bool) {
        return true;
    }


    function bid(Offer calldata offer) external override returns (bool) {
//        require(items[itemId].temporaryOwner != address(0), "Item does not exist.");
//        require(block.timestamp < items[itemId].publishTime + items[itemId].auctionDuration, "Auction has ended.");
//
//        uint256 currentPrice = items[itemId].guidePrice;
//        if (bidHistory[itemId].length > 0) {
//            Bid memory lastBid = bidHistory[itemId][bidHistory[itemId].length - 1];
//            currentPrice = lastBid.price;
//        }
//
//        require(price > currentPrice, "Price is lower than current price or guide price.");
//
//        Bid memory newBid = Bid({
//            itemId: itemId,
//            temporaryOwner: msg.sender,
//            price: price,
//            timestamp: block.timestamp
//        });
//
//        bidHistory[itemId].push(newBid);
//
//        // 授权新的临时所有者
//        _approve(msg.sender, itemId);
//
//        // 转移资产给新的临时所有者
//        safeTransferFrom(items[itemId].temporaryOwner, msg.sender, itemId);
//
//        // 更新临时所有者
//        items[itemId].temporaryOwner = msg.sender;
        return true;
    }


    function endAuction(uint256 tokenId) external override returns (bool) {
        return true;
    }

}

