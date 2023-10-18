// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BidPool.sol";
import "../interfaces/IBidPoolFactory.sol";
import "../libraries/structs.sol";

contract BidPoolFactory is IBidPoolFactory {
    address public treasury;

    address[] public deployedBidPools;
    mapping(address => address) private dataAssetToBidPool;
    Condition[] public conditions;

    event BidPoolCreated(address indexed bidPoolAddress, address indexed dataAssetAddress, address creator, uint256 timestamp);

    // 构造函数
    constructor(address _treasury) {
        treasury = _treasury;
    }

    // 实现接口函数 - 获取出价池
    function getBidPool(uint256 index) public view override returns (address) {
        // 根据index返回数据资产地址
        return deployedBidPools[index];
    }

    // 实现接口函数 - 获取出价池总数
    function getBidPoolsLength() public view override returns (uint256) {
        // 返回数据资产的总数量
        return deployedBidPools.length;
    }

    // 实现接口函数 - 根据数据资产地址获取对应的出价池
    function getBidPoolByDataAsset(address dataAsset) external view override returns (address) {
        return dataAssetToBidPool[dataAsset];
    }


    function createBidPool(string memory name, string memory symbol, address dataAsset, uint256 basicReward) public override returns (address) {
        BidPool bidPool = new BidPool(name, symbol, dataAsset, basicReward);
        deployedBidPools.push(address(bidPool));

        // 将新创建的 BidPool 和相应的数据资产地址关联起来
        dataAssetToBidPool[dataAsset] = address(bidPool);

        emit BidPoolCreated(address(bidPool), dataAsset, msg.sender, block.timestamp);

        return address(bidPool);
    }

//    function startAuction(Condition memory condition) public override returns (bool) {
////        require(super.ownerOf(condition.itemId) == msg.sender, "Only owner can start auction."); // 只有数据资产的所有者(而非创建者)才能发起竞拍, 也就是甚至数据资产在流转到某个人手上时，他可以再次发起竞拍
////        require(items[condition.itemId].auctionStatus == 0, "Auction isn't in a status of pending.");
//
//        conditions[condition.itemId] = condition;
//        if (bidPool == address(0)) {
//            bidPool = address(new BidPool(_name, _symbol, address(0))); // todo
//        }
//
//        IBidPool(bidPool).initialize(condition);
//
//        super.transferFrom(msg.sender, bidPool, condition.itemId); // 开始竞拍后将数据资产转移至bidpool合约地址
//        items[condition.itemId].owner = address(this); // 开始竞拍后将数据资产转移至合约地址
//        items[condition.itemId].auctionStatus = 1; // 竞拍状态改为开始
//
//        return true;
//    }


//    function endAuction(Condition memory condition) public override returns (bool) {
//        require(super.ownerOf(condition.itemId) == msg.sender, "Only owner can start auction."); // 只有数据资产的所有者(而非创建者)才能发起竞拍, 也就是甚至数据资产在流转到某个人手上时，他可以再次发起竞拍
//        // openness 如何在time expired之后自动改状态
//        require(items[condition.itemId].auctionStatus == 1, "Auction isn't in a status of openness.");
////        IBidPool(bidPool).distributeRewards(); //todo
//        return true;
//    }

}
