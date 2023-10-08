//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
//
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
//
//import "./DataAsset.sol";
//
//contract NonFungibleDataAsset is DataAsset, ERC721URIStorage, Ownable {
//    using Counters for Counters.Counter;
//    Counters.Counter private _tokenCounter;
//
//
//    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
//        dataCreator = msg.sender;
//    }
//
//
//    function createItem(string memory uri) public override returns (uint256) {
//        uint256 tokenId = _tokenCounter.current();
//        _mint(msg.sender, tokenId);
//        _setTokenURI(tokenId, uri);
//
//        items.push(Item({
//            itemId : tokenId,
//            dataAsset : address(this),
//            dataCreator : msg.sender,
//            uri : uri,
//            owner : msg.sender,
//            winner : address(0),
//            timeCreated : block.timestamp,
//            extraParams: "0x"
//        }));
//
//        super.setApprovalForAll(address(this), true);
//
//        emit ItemCreated(tokenId, msg.sender, uri);
//        _tokenCounter.increment();
//
//
//    return tokenId;
//    }
//
//    // 每次转让后，新的拥有者只要不是bidPool，就会自动授权给bidPool
//    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
//        if (to != bidPool) {
//            _setApprovalForAll(to, bidPool, true);
//        }
//    }
//
//
//    // 为BidPool开的收回所有权的接口
////    function grantOwnershipToBidPool(uint256 tokenId) external override returns (bool) {
////        require(msg.sender == bidPool, "Only BidPool can transfer ownership.");
////        require(items[tokenId].dataCreator != address(0), "Item does not exist.");
////        transferFrom(super.ownerOf(tokenId), bidPool, tokenId);
////        return true;
////    }
//
//
////    function startAuction(Condition memory condition) public override returns (bool) {
////        require(super.ownerOf(condition.itemId) == msg.sender, "Only owner can start auction."); // 只有数据资产的所有者(而非创建者)才能发起竞拍, 也就是甚至数据资产在流转到某个人手上时，他可以再次发起竞拍
////        require(items[condition.itemId].auctionStatus == 0, "Auction isn't in a status of pending.");
////
////        conditions[condition.itemId] = condition;
////        if (bidPool == address(0)) {
////            bidPool = address(new BidPool(_name, _symbol, address(0))); // todo
////        }
////
////        IBidPool(bidPool).initialize(condition);
////
////        super.transferFrom(msg.sender, bidPool, condition.itemId); // 开始竞拍后将数据资产转移至bidpool合约地址
////        items[condition.itemId].owner = address(this); // 开始竞拍后将数据资产转移至合约地址
////        items[condition.itemId].auctionStatus = 1; // 竞拍状态改为开始
////
////        return true;
////    }
////
////
////    function endAuction(Condition memory condition) public override returns (bool) {
////        require(super.ownerOf(condition.itemId) == msg.sender, "Only owner can start auction."); // 只有数据资产的所有者(而非创建者)才能发起竞拍, 也就是甚至数据资产在流转到某个人手上时，他可以再次发起竞拍
////        // openness 如何在time expired之后自动改状态
////        require(items[condition.itemId].auctionStatus == 1, "Auction isn't in a status of openness.");
//////        IBidPool(bidPool).distributeRewards(); //todo
////        return true;
////    }
//
//}
//
