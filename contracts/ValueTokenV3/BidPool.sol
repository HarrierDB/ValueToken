// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IBidPool.sol";
import "../interfaces/IDataAsset.sol";
import "../interfaces/IBidPoolCallee.sol";
import "../interfaces/IInfocode.sol";
import "../interfaces/IValuecode";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BidPool is IBidPool, ERC20, Ownable {
    address public dataAsset;
    mapping(uint256 => Condition) public conditions; // itemId to condition
    mapping(uint256 => Offer) public currentOffer; // itemId to offer

    Offer[][] public offersHistory;
    mapping(uint256 => mapping (address => uint256)) public rewardHistory; // itemId to (bidder to rewardAmount);

    IInfocode public infocode;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    function initialize(Condition calldata condition) public override {
        conditions[condition.itemId] = condition;
    }

    function bid(Offer calldata offer) public override returns (bool) {
        Item memory item = IDataAsset(dataAsset).getItem(offer.itemId);
        require(item.dataCreator != address(0), "Item does not exist.");
        require(item.auctionStatus == 1, "Auction is not open.");

        require(block.timestamp >= conditions[offer.itemId].startPrice, "Auction hasn't started.");
        require( (block.timestamp <= conditions[offer.itemId].startTime + conditions[offer.itemId].auctionDuration) || (block.timestamp < conditions[offer.itemId].expirationTime), "Auction has ended.");

        offersHistory[offer.itemId].push(offer); // 不论是否是最高价，都记录到历史出价中

        // currentOffer 记录当前最高价
        // 如果是最高价，先把dataAsset转移至receiver, 给闪电贷留空间
        // 有一个问题，就是在竞拍过程中，是否需要禁止除竞拍转让以外的其他转让？
        // 如果不禁止，那么在竞拍过程中，dataAsset的owner可能会发生变化，这样的话，bidPool可能没法把dataAsset转移回来
        // 这样我设计了一个新的接口，grantOwnershipToBidPool，用于在竞拍过程中，把dataAsset的owner转移到bidPool
        // 同时我设计了一个_afterTokenTransfer函数，用于在每次转让后，都会调用，使得bidpool永远是当前owner的approveForAll的operator
        require(offer.bidAmount > currentOffer[offer.itemId].bidAmount, "Bid amount is not higher than current offer.");

        currentOffer[offer.itemId] = offer;
        // 转让成立的前提是，在每次转让后，都会调用_afterTokenTransfer函数，使得bidpool永远是当前owner的approveForAll的operator
        IERC721(dataAsset).transferFrom(IERC721(dataAsset).ownerOf(offer.itemId), offer.receiver, offer.itemId);
        if (offer.extraParams.length > 0) {
            IBidPoolCallee(offer.receiver).bidPoolCall(offer);
        }
        // 要求bidToken转bidAmount给bidpool
        (bool success, bytes memory data) = conditions[offer.itemId].bidToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", offer.bidder, address(this), offer.bidAmount));
        require(success, "Transfer bid token failed.");

        return true;
    }

    function mintInfocode(uint256 amount) internal returns (bool){
        infocode.mint(amount);
        return true;
    }

    function distributeRewards(mapping (address => uint256) rewardHistory) internal returns (bool) {
        uint256 memory i;
        uint256 memory j;
        for (i==0; i<rewardHistory.length; i++) {
            for (j==0; j<rewardHistory[i].length; j++) {
                mintInfocode(rewardHistory[i][j]);
            }
        }

        return true;
    }

    function calculateRewards(Offer[][] offersHistory) internal returns (mapping (address => uint256)) {
        uint256 memory i;
        uint256 memory j;
        for (i==0; i<offersHistory.length; i++) {
            for (j==0; j<offersHistory[i].length; j++) {
                if (j ==0) {
                    rewardHistory[i][j] == 0;
                } else {
                    rewardHistory[i][j] == offersHistory[i][j].bidAmount - offersHistory[i][j-1].bidAmount;
                }
            }
        }
        return true;
    }


    function updateCondition(Condition calldata newCondition) public override {
        conditions[newCondition.itemId] = newCondition;
    }

}
