// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IBidPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BidPool is IBidPool, ERC20, Ownable {
    mapping(uint256 => Condition) public conditions; // itemId to condition
    Offer[][] public offersHistory;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    function initialize(Condition calldata condition) public {
        conditions[condition.itemId] = condition;
    }

    function bid(Offer memory offer) public override returns (bool) {
//        require(items[offer.itemId].dataCreator != address(0), "Item does not exist.");
//        require(items[offer.itemId].auctionStatus == 1, "Auction is not open.");
        require(block.timestamp >= conditions[offer.itemId].startPrice, "Auction hasn't started.");
        require( (block.timestamp <= conditions[offer.itemId].startTime + conditions[offer.itemId].auctionDuration) || (block.timestamp < conditions[offer.itemId].expirationTime), "Auction has ended.");

//        super._approve(msg.sender, offer.itemId); // 之后要unapprove掉

        // 先把dataAsset转移至receiver
        // 实现一个闪电贷的功能
//        super.safeTransferFrom(super.ownerOf(offer.itemId), offer.receiver, offer.itemId);

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

    function updateCondition(Condition calldata newCondition) public {
        conditions[condition.itemId] = condition;
    }

}
