// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

contract InfoContent {

    mapping(address => mapping(uint256 => InfoParams[])) public dataAssetsToTokenIdToInfoParams;

    constructor(){

    }

    function setInfoParams(address bidPool_, uint256 tokenId, InfoParams calldata infoParams) public returns (bool) {
        dataAssetsToTokenIdToInfoParams[bidPool_][tokenId].push(infoParams);
        return true;
    }

    function calculateInfoContentDensityGradientByBidPoolItem(address bidPool_, uint256 tokenId, uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256 totalInfoTargetLength = 0;
        uint256 totalInfoAmount = 0;
        for (uint256 i = 0; i < dataAssetsToTokenIdToInfoParams[bidPool_][tokenId].length; i++) {
            InfoParams memory infoParams = dataAssetsToTokenIdToInfoParams[bidPool_][tokenId][i];
            if (infoParams.bidTime >= startTimestamp && infoParams.bidTime <= endTimestamp) {
                totalInfoTargetLength += infoParams.targetLength;
                totalInfoAmount += infoParams.amount;
            }
        }
        if (totalInfoTargetLength == 0) {
            return 0;
        }
        return totalInfoAmount / totalInfoTargetLength; // 信含密度梯度， 针对DA下的单个item
    }

    function calculateInfoContentDensityByBidPool(address bidPool_, uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256[] memory itemIds = bidPool_.call("itemIds()");
        uint256 infoContentMass;
        for (uint256 i=0; i<itemIds.length; i++) {
            infoContentMass += calculateInfoContentDensityGradientByBidPoolItem(bidPool_, itemIds[i], startTimestamp, endTimestamp);
        }
        return infoContentMass / itemIds.length; // 信含密度， 针对某个DA
    }


    function calculateInfoContentCardinal(uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256 infoContentDensity;
        uint256 poolsLength = IBidPoolFactory(BidPoolFactory).getBidPoolsLength();
        for (uint256 i=0; i<poolsLength; i++) {
            address bidPool_ = IBidPoolFactory(BidPoolFactory).getBidPool(i);
            infoContentDensity += calculateInfoContentDensityByBidPool(bidPool_, startTimestamp, endTimestamp);

        }
        return infoContentDensity/poolsLength; // 信含基数
    }
}
