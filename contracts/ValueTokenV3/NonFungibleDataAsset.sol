// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDataAsset.sol";

contract NonFungibleDataAsset is IDataAsset, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemCounter;

    struct Item {
        uint256 tokenId;
        string uri;
        uint256 guidePrice;
        uint256 publishTime;
        uint256 auctionDuration;
        address temporaryOwner;
    }

    struct Bid {
        uint256 tokenId;
        address temporaryOwner;
        uint256 price;
        uint256 timestamp;
    }

    event ItemPublished(uint256 itemId, address publisher, string uri, uint256 guidePrice, uint256 publishTime, uint256 auctionDuration);

    mapping(uint256 => Item) public items;
    mapping(uint256 => Bid[]) public bidHistory;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }

    function publishItem(string memory uri, uint256 guidePrice, uint256 auctionDuration) public returns (uint256) {
        _itemCounter.increment();
        uint256 itemId = _itemCounter.current();
        _mint(msg.sender, itemId);
        _setTokenURI(itemId, uri);
        items[itemId] = Item({
            itemId: itemId,
            uri: uri,
            guidePrice: guidePrice,
            publishTime: block.timestamp,
            auctionDuration: auctionDuration,
            temporaryOwner: msg.sender
        });

        emit ItemPublished(itemId, msg.sender, uri, guidePrice, block.timestamp, auctionDuration);

        return itemId;
    }

    function bid(uint256 itemId, uint256 price) public {
        require(items[itemId].temporaryOwner != address(0), "Item does not exist.");
        require(block.timestamp < items[itemId].publishTime + items[itemId].auctionDuration, "Auction has ended.");

        uint256 currentPrice = items[itemId].guidePrice;
        if (bidHistory[itemId].length > 0) {
            Bid memory lastBid = bidHistory[itemId][bidHistory[itemId].length - 1];
            currentPrice = lastBid.price;
        }

        require(price > currentPrice, "Price is lower than current price or guide price.");

        Bid memory newBid = Bid({
            itemId: itemId,
            temporaryOwner: msg.sender,
            price: price,
            timestamp: block.timestamp
        });

        bidHistory[itemId].push(newBid);

        // 授权新的临时所有者
        _approve(msg.sender, itemId);

        // 转移资产给新的临时所有者
        safeTransferFrom(items[itemId].temporaryOwner, msg.sender, itemId);

        // 更新临时所有者
        items[itemId].temporaryOwner = msg.sender;
    }

    // 获取指导价格
    function getGuidePrice(uint256 itemId) public view returns (uint256) {
        return items[itemId].guidePrice;
    }
}

