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
    uint256 private basicReward; //只要出价均可获得的奖励
    uint256 private totalEffectiveOfferCount; // 该出价池对应的所有itemId对应的所有offer总数；

    mapping(uint256 => uint8) private itemIdToAuctionStatus; // 一个itemId对应一个竞拍状态
    mapping(uint256 => Condition) private itemIdToCondition; // 一个竞拍对应一个条件
    mapping(uint256 => Offer[]) private itemIdToOffers; //一个itemId对应多个offer
    mapping(uint256 => Offer) private itemIdToCurrentOffer; // 一个itemId对应一个目前最高出价；
    mapping(uint256 => Reward[]) private itemIdToRewards; // 一个itemId对应多个出价奖励（与多个offer一一对应）

    // 定义 RewardsDistribution 结构体
    struct RewardDistribution {
        uint256 rewardSum; // 和
        uint256 rewardAverage; // 平均数
    }


    constructor(string memory name_, string memory symbol_, address dataAsset_, uint256 basicReward_) ERC20(name_, symbol_) {
        dataAsset = dataAsset_;
        basicReward = basicReward_;
    }

    function initialize(uint256 itemId, Condition calldata condition) public override {
        address ownerOfItemId = ERC721(dataAsset).ownerOf(itemId);
        require(ownerOfItemId == msg.sender);
        itemIdToCondition[itemId] = condition;
        itemIdToAuctionStatus[itemId] = 1;


        ERC721(dataAsset).transferFrom(ownerOfItemId, address(this), itemId);
    }

    function getConditionByItemId(uint256 itemId) public view override returns (Condition memory) {
        return itemIdToCondition[itemId];
    }

    function setBasicReward(uint256 basicReward_) public {
        basicReward = basicReward_;
    }

    function bid(uint256 itemId, Offer calldata offer) public override returns (uint256) {
        require(itemIdToAuctionStatus[itemId] == 1, "Auction status isn't pending.");

        address creator = IPersonalValueDataAsset(dataAsset).getCreatorById(itemId);
        require(creator != address(0), "Item does not exist.");

        require(block.timestamp >= itemIdToCondition[itemId].commenceTimestamp, "Auction hasn't started.");
        require( (block.timestamp <= itemIdToCondition[itemId].commenceTimestamp + itemIdToCondition[itemId].auctionDuration) || (block.timestamp < itemIdToCondition[itemId].expirationTimestamp), "Auction has ended.");

        itemIdToOffers[itemId].push(offer); // 不论是否是最高价，都记录到历史出价中
        uint256 extraReward = offer.bidAmount > itemIdToCurrentOffer[itemId].bidAmount? offer.bidAmount - itemIdToCurrentOffer[itemId].bidAmount : 0;

        itemIdToRewards[itemId].push(Reward({
            bidder : msg.sender,
            amount : basicReward+extraReward,
            bidTime : block.timestamp
        }));

        if (extraReward>0) {
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

        return basicReward+extraReward;
    }

    function getRewardsDistributionById(uint256 tokenId, uint256 startTimestamp, uint256 endTimestamp) public view returns (RewardDistribution memory) {
        uint256 rewardSum;
        uint256 duration = IPersonalValueDataAsset(dataAsset).getDurationById(tokenId);
        for (uint256 i=0; i<itemIdToRewards[tokenId].length; i++) {
            if ((itemIdToRewards[tokenId][i].bidTime>startTimestamp) && (itemIdToRewards[tokenId][i].bidTime<endTimestamp)) {
                rewardSum += itemIdToRewards[tokenId][i].amount;
            }
        }
        uint256 personalTimeValue = rewardSum / duration; // 本段时间内,该tokenId对应的奖励对应的时值
        return RewardDistribution({rewardSum : rewardSum, rewardAverage : personalTimeValue});
    }

    function getRewardsDistribution(uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256, uint256) {
        uint256 totalRewardSum;
        uint256 totalPTV;
        for (uint256 i=0; i<ERC721(dataAsset).totalSupply();i++) {
            totalRewardSum+=getRewardsDistributionById(i, startTimestamp, endTimestamp).rewardSum;
            totalPTV+=getRewardsDistributionById(i, startTimestamp,endTimestamp).rewardAverage;
        }
        uint256 averageRewardSum = totalRewardSum / ERC721(dataAsset).totalSupply();
        uint256 averagePTV = totalPTV / ERC721(dataAsset).totalSupply();
        return (averageRewardSum, averagePTV);
    }

//    function mintInfocode(uint256 amount) internal returns (bool) {
//        infocode.mint(amount);
//        return true;
//    }

//    function distributeRewards(mapping (address => uint256) rewardHistory) public returns (mapping(uint256 => uint256)) {
//        uint256 totalRewards;
//        uint256 memory i;
//        uint256 memory j;
//        for (i==0; i< rewardList.length; i++) {
//            for (j==0; j< rewardList[i].length; j++) {
//                mintInfocode(rewardList[i][j]);
//                totalRewards += totalRewards;
//            }
//        }
//
//        return true;
//    }

//    function calculateRewards(Offer[][] offersHistory) internal returns (bool) {
//        uint256 memory i;
//        uint256 memory j;
//        for (i==0; i<offersHistory.length; i++) {
//            for (j==0; j<offersHistory[i].length; j++) {
//                if (j ==0) {
//                    rewardList[i][j] == 0;
//                } else {
//                    rewardList[i][j] == offersHistory[i][j].bidAmount - offersHistory[i][j-1].bidAmount;
//                }
//            }
//        }
//        return true;
//    }


}
