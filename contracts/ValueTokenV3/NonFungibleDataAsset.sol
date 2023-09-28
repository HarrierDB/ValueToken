// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDataAsset.sol";
import "./BidPool.sol";

contract NonFungibleDataAsset is IDataAsset, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenCounter;

    Item[] public items;
    Condition[] public conditions;
    Offer[][] public offersHistory;


    address public immutable dataCreator; // 存储数据资产的创建者
    address public bidPool; // 存储竞拍池地址

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        dataCreator = msg.sender;
    }

    function getDataCreator() external view override returns (address) {
        return dataCreator;
    }

    function getItem(uint256 tokenId) external view override returns (Item memory) {
        return items[tokenId];
    }

    function getAuctionStatus(uint256 tokenId) external view override returns (uint8) {
        return items[tokenId].auctionStatus;
    }


    function createItem(string memory uri) public override returns (uint256) {
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
            winner : address(0),
            timeCreated : block.timestamp,
            auctionStatus : 0,
            extraParams: "0x"
        });

        super.setApprovalForAll(address(this), true);

        emit ItemCreated(tokenId, msg.sender, uri);

        return tokenId;
    }

    // 每次转让后，新的拥有者只要不是bidPool，就会自动授权给bidPool
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
        if (to != bidPool) {
            _setApprovalForAll(to, bidPool, true);
        }
    }


    // 为BidPool开的收回所有权的接口
    function grantOwnershipToBidPool(uint256 tokenId) external override returns (bool) {
        require(msg.sender == bidPool, "Only BidPool can transfer ownership.");
        require(items[tokenId].dataCreator != address(0), "Item does not exist.");
        transferFrom(super.ownerOf(tokenId), bidPool, tokenId);
        return true;
    }


    function startAuction(Condition memory condition) public override returns (bool) {
        require(super.ownerOf(condition.itemId) == msg.sender, "Only owner can start auction."); // 只有数据资产的所有者(而非创建者)才能发起竞拍, 也就是甚至数据资产在流转到某个人手上时，他可以再次发起竞拍
        require(items[condition.itemId].auctionStatus == 0, "Auction has already started.");

        conditions[condition.itemId] = condition;
        if (bidPool == address(0)) {
            bidPool = address(new BidPool(_name, _symbol));
        }

        IBidPool(bidPool).initialize(condition);

        super.transferFrom(msg.sender, bidPool, condition.itemId); // 开始竞拍后将数据资产转移至bidpool合约地址
        items[condition.itemId].owner = address(this); // 开始竞拍后将数据资产转移至合约地址
        items[condition.itemId].auctionStatus = 1; // 竞拍状态改为开始

        return true;
    }



    function endAuction(uint256 tokenId) external override returns (bool) {
        return true;
    }

}

