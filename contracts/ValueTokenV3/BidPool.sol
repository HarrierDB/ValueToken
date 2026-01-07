// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IBidPool.sol";
import "../interfaces/IDataAsset.sol";
import "../interfaces/IPersonalValueDataAsset.sol";
import "../interfaces/IBidPoolCallee.sol";
import "../interfaces/IInfocode.sol";
import "../interfaces/IValuecode.sol";
import "../libraries/Utils.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BidPool is IBidPool, ERC20, Ownable {
    address public dataAsset;
    uint256[] public targets; // 指的是dataAsset里进行出价的具体id,是一个列表
    uint256 public behaviorGradient; // 行为信含密度梯度，只要出价，就会获得该值
    address public infoContent; // 信含

    mapping(uint256 => uint8) private targetToAuctionStatus; // 一个itemId对应一个竞拍状态
    mapping(uint256 => Condition) private targetToCondition; // 一个竞拍对应一个条件
    mapping(uint256 => Offer[]) private targetToOfferGroup; //一个itemId对应多个offer


    constructor(string memory name_, string memory symbol_, address dataAsset_, uint256 behaviorGradient_) ERC20(name_, symbol_) {
        dataAsset = dataAsset_;
        behaviorGradient = behaviorGradient_;
    }

    function initialize(uint256 target, Condition calldata condition) public override {
        address ownerOfTarget = ERC721(dataAsset).ownerOf(target);
        require(ownerOfTarget == msg.sender);
        targetToCondition[target] = condition;
        targetToAuctionStatus[target] = 1;
        targets.push(target);

        ERC721(dataAsset).transferFrom(ownerOfTarget, address(this), target);
    }

    function getMaxOfferByTarget(uint256 target) public view returns (Offer memory) {
        Offer[] memory offerGroup = targetToOfferGroup[target];
        Offer memory maxOffer = Utils.getMaxOffer(offerGroup);
        return maxOffer;
    }

    function getConditionByItemId(uint256 itemId) public view override returns (Condition memory) {
        return targetToCondition[itemId];
    }

    function setBasicInfoContent(uint256 basicInfoContent_) public {
        behaviorGradient = basicInfoContent_;
    }

    function bid(uint256 target, Offer calldata offer) public override returns (uint256) {
        require(targetToAuctionStatus[target] == 1, "Auction status isn't pending.");

        address creator = IPersonalValueDataAsset(dataAsset).getCreatorById(target);
        require(creator != address(0), "Item does not exist.");

        require(block.timestamp >= targetToCondition[target].commenceTimestamp, "Auction hasn't started.");
        require( (block.timestamp <= targetToCondition[target].commenceTimestamp + targetToCondition[target].auctionDuration) || (block.timestamp < targetToCondition[target].expirationTimestamp), "Auction has ended.");

        targetToOfferGroup[target].push(offer); // 不论是否是最高价，都记录到历史出价中
        uint256 maxOfferAmount = getMaxOfferByTarget(target).bidAmount; // 获取最高出价
        uint256 priceGradient = offer.bidAmount >  maxOfferAmount? offer.bidAmount - maxOfferAmount : 0;

        uint256 length = IPersonalValueDataAsset(dataAsset).getDurationById(target);

        // 调infoContent的record函数
        infoContent.call(abi.encodeWithSignature("record(address,uint256,InfoParams)", address(this), target, InfoParams({
            bidder : msg.sender,
            length : length, // 该任务的时长
            amount : behaviorGradient + priceGradient,
            bidTime : block.timestamp
        })));

        // 如果是最高价，先把dataAsset转移至receiver, 给闪电贷留空间
        // 有一个问题，就是在竞拍过程中，是否需要禁止除竞拍转让以外的其他转让？
        // 如果不禁止，那么在竞拍过程中，dataAsset的owner可能会发生变化，这样的话，bidPool可能没法把dataAsset转移回来
        // 这样我设计了一个新的接口，grantOwnershipToBidPool，用于在竞拍过程中，把dataAsset的owner转移到bidPool
        // 同时我设计了一个_afterTokenTransfer函数，用于在每次转让后，都会调用，使得bidpool永远是当前owner的approveForAll的operator

        // 转让成立的前提是，在每次转让后，都会调用_afterTokenTransfer函数，使得bidpool永远是当前owner的approveForAll的operator
        ERC721(dataAsset).transferFrom(ERC721(dataAsset).ownerOf(target), offer.receiver, target);

        // 回调函数
        if (offer.extraParams.length > 0) {
            IBidPoolCallee(offer.receiver).bidPoolCall(offer);
        }
        // 要求bidToken转bidAmount给bidpool
        (bool success, bytes memory data) = targetToCondition[target].bidToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", offer.bidder, address(this), offer.bidAmount));
        require(success, "Transfer bid token failed.");

        return behaviorGradient + priceGradient;
    }

}
