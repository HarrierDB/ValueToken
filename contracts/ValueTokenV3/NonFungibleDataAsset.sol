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
    Condition[] public conditions;
    Offer[][] public offersHistory;


    address public immutable dataCreator; // 存储数据资产的创建者

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        dataCreator = msg.sender;
    }

    function getDataCreator() external view override returns (address) {
        return dataCreator;
    }

    function getAuctionStatus(uint256 tokenId) external view override returns (uint8) {
        return items[tokenId].auctionStatus;
    }


    function createItem(string memory uri) public override returns (uint256) {
        _tokenCounter.increment();
        uint256 tokenId = _tokenCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        // 在此处初始化 offerHistory 数组
        offersHistory[tokenId].push(Offer({
            itemId : tokenId,
            bidder : address(0),
            receiver : address(0),
            bidAmount : 0,
            bidTime : block.timestamp,
            extraParams : "0x"
        }));

        items[tokenId] = Item({
            itemId : tokenId,
            dataAsset : address(this),
            dataCreator : msg.sender,
            uri : uri,
            owner : msg.sender,
            winner : address(0),
            timeCreated : block.timestamp,
            auctionStatus : 0,
            extraParams: "0x"
        });

        super.setApprovalForAll(address(this), true);

        emit ItemCreated(tokenId, msg.sender, uri);

        return tokenId;
    }

    function startAuction(Condition calldata condition) public override returns (bool) {
        require(items[condition.itemId].dataCreator == msg.sender, "Only data creator can start auction.");
        require(items[condition.itemId].auctionStatus == 0, "Auction has already started.");

        conditions[condition.itemId] = condition;

        items[condition.itemId].auctionStatus = 1;
        return true;
    }


    function bid(Offer calldata offer) public override returns (bool) {
        require(items[offer.itemId].dataCreator != address(0), "Item does not exist.");
        require(items[offer.itemId].auctionStatus == 1, "Auction is not open.");
        require(block.timestamp >= conditions[offer.itemId].startPrice, "Auction hasn't started.");
        require( (block.timestamp <= conditions[offer.itemId].startTime + conditions[offer.itemId].auctionDuration) || (block.timestamp < conditions[offer.itemId].expirationTime), "Auction has ended.");

        super._approve(msg.sender, offer.itemId); // 之后要unapprove掉

        // 先把dataAsset转移至receiver
        super.safeTransferFrom(super.ownerOf(offer.itemId), offer.receiver, offer.itemId);


        // 实现一个闪电贷的功能



        // 要求bidToken转bidAmount给owner
        (bool success, bytes memory data) = conditions[offer.itemId].bidToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", offer.bidder, super.ownerOf(offer.itemId), offer.bidAmount));
        require(success, "Transfer bid token failed.");



        offersHistory[offer.itemId].push(offer);


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

