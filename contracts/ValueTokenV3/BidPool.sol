// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IBidPool.sol";
import "../interfaces/IDataAsset.sol";
import "../interfaces/IPersonalValueDataAsset.sol";
import "../interfaces/IBidPoolCallee.sol";
import "../interfaces/IInfocode.sol";
import "../interfaces/IValuecode.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BidPool is IBidPool, ERC20, Ownable {
    address public dataAsset;
    uint256[] public itemIds;
    uint256 private behaviorInfoContent; //只要出价均可获得的奖励
    uint256 private totalEffectiveOfferCount; // 该出价池对应的所有itemId对应的所有offer总数；
    uint256 public infoContentCardinal; //信含基数

    mapping(uint256 => uint8) private itemIdToAuctionStatus; // 一个itemId对应一个竞拍状态
    mapping(uint256 => Condition) private itemIdToCondition; // 一个竞拍对应一个条件
    mapping(uint256 => Offer[]) private itemIdToOffers; //一个itemId对应多个offer
    mapping(uint256 => Offer) private itemIdToCurrentOffer; // 一个itemId对应一个目前最高出价；
    mapping(uint256 => InfoParams[]) private itemIdToInfoCluster; // 一个itemId对应多个出价信息簇（与多个offer一一对应）

    // 定义 InfoContentDistribution 结构体
    struct InfoContentDistribution {
        uint256 infoContentSum; // 和
        uint256 infoContentAverage; // 平均数
    }


    constructor(string memory name_, string memory symbol_, address dataAsset_, uint256 behaviorInfoContent_) ERC20(name_, symbol_) {
        dataAsset = dataAsset_;
        behaviorInfoContent = behaviorInfoContent_;
    }

    function initialize(uint256 itemId, Condition calldata condition) public override {
        address ownerOfItemId = ERC721(dataAsset).ownerOf(itemId);
        require(ownerOfItemId == msg.sender);
        itemIdToCondition[itemId] = condition;
        itemIdToAuctionStatus[itemId] = 1;
        itemIds.push(itemId);

        ERC721(dataAsset).transferFrom(ownerOfItemId, address(this), itemId);
    }

    function getConditionByItemId(uint256 itemId) public view override returns (Condition memory) {
        return itemIdToCondition[itemId];
    }

    function setBasicInfoContent(uint256 basicInfoContent_) public {
        behaviorInfoContent = basicInfoContent_;
    }

    function bid(uint256 itemId, Offer calldata offer) public override returns (uint256) {
        require(itemIdToAuctionStatus[itemId] == 1, "Auction status isn't pending.");

        address creator = IPersonalValueDataAsset(dataAsset).getCreatorById(itemId);
        require(creator != address(0), "Item does not exist.");

        require(block.timestamp >= itemIdToCondition[itemId].commenceTimestamp, "Auction hasn't started.");
        require( (block.timestamp <= itemIdToCondition[itemId].commenceTimestamp + itemIdToCondition[itemId].auctionDuration) || (block.timestamp < itemIdToCondition[itemId].expirationTimestamp), "Auction has ended.");

        itemIdToOffers[itemId].push(offer); // 不论是否是最高价，都记录到历史出价中
        uint256 priceInfoContent = offer.bidAmount > itemIdToCurrentOffer[itemId].bidAmount? offer.bidAmount - itemIdToCurrentOffer[itemId].bidAmount : 0;

        itemIdToInfoContents[itemId].push(InfoContent({
            bidder : msg.sender,
            amount : behaviorInfoContent + priceInfoContent,
            bidTime : block.timestamp
        }));

        if (priceInfoContent >0) {
            // 删除现有最高出价
            delete itemIdToCurrentOffer[itemId];
            // 将最新出价置为现有最高出价
            itemIdToCurrentOffer[itemId] = offer;
            totalEffectiveOfferCount++;
        }

        // 如果是最高价，先把dataAsset转移至receiver, 给闪电贷留空间
        // 有一个问题，就是在竞拍过程中，是否需要禁止除竞拍转让以外的其他转让？
        // 如果不禁止，那么在竞拍过程中，dataAsset的owner可能会发生变化，这样的话，bidPool可能没法把dataAsset转移回来
        // 这样我设计了一个新的接口，grantOwnershipToBidPool，用于在竞拍过程中，把dataAsset的owner转移到bidPool
        // 同时我设计了一个_afterTokenTransfer函数，用于在每次转让后，都会调用，使得bidpool永远是当前owner的approveForAll的operator

        // 转让成立的前提是，在每次转让后，都会调用_afterTokenTransfer函数，使得bidpool永远是当前owner的approveForAll的operator
        ERC721(dataAsset).transferFrom(ERC721(dataAsset).ownerOf(itemId), offer.receiver, itemId);

        // 回调函数
        if (offer.extraParams.length > 0) {
            IBidPoolCallee(offer.receiver).bidPoolCall(offer);
        }
        // 要求bidToken转bidAmount给bidpool
        (bool success, bytes memory data) = itemIdToCondition[itemId].bidToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", offer.bidder, address(this), offer.bidAmount));
        require(success, "Transfer bid token failed.");

        return behaviorInfoContent + priceInfoContent;
    }

//    function getInfoContentsDistributionById(uint256 tokenId, uint256 startTimestamp, uint256 endTimestamp) public view returns (InfoContentDistribution memory) {
//        uint256 infoContentSum;
//        uint256 duration = IPersonalValueDataAsset(dataAsset).getDurationById(tokenId);
//        for (uint256 i=0; i< itemIdToInfoContents[tokenId].length; i++) {
//            if ((itemIdToInfoContents[tokenId][i].bidTime>startTimestamp) && (itemIdToInfoContents[tokenId][i].bidTime<endTimestamp)) {
//                infoContentSum += itemIdToInfoContents[tokenId][i].amount;
//            }
//        }
//        uint256 personalTimeValue = infoContentSum / duration; // 本段时间内,该tokenId对应的奖励对应的时值
//        return InfoContentDistribution({infoContentSum : infoContentSum, infoContentAverage : personalTimeValue});
//    }
//
//    function getInfoContentsDistribution(uint256 startTimestamp, uint256 endTimestamp) public view override returns (uint256, uint256) {
//        uint256 totalInfoContentSum;
//        uint256 totalPTV;
//        for (uint256 i=0; i<ERC721(dataAsset).totalSupply();i++) {
//            totalInfoContentSum+=getInfoContentsDistributionById(i, startTimestamp, endTimestamp).infoContentSum;
//            totalPTV+=getInfoContentsDistributionById(i, startTimestamp,endTimestamp).infoContentAverage;
//        }
//        uint256 averageInfoContentSum = totalInfoContentSum / ERC721(dataAsset).totalSupply();
//        uint256 averagePTV = totalPTV / ERC721(dataAsset).totalSupply();
//        return (averageInfoContentSum, averagePTV);
//    }




}
