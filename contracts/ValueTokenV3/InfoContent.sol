// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";
import "../interfaces/IBidPoolFactory.sol";

contract InfoContent {

    mapping(address => mapping(uint256 => InfoParams[])) public targetToInfoCluster;
    address public BidPoolFactory;

    constructor(){
    }

    function setBidPoolFactory(address BidPoolFactory_) public {
        BidPoolFactory = BidPoolFactory_;
    }

    // 每当有出价的时候，会形成信息含量梯度，出价池会通过这个函数将其记录下来
    function record(address bidPool, uint256 target, InfoParams calldata infoParams) public returns (bool) {
        targetToInfoCluster[bidPool][target].push(infoParams);
        return true;
    }

    function calculateInfoContentDensityGradientByTarget(address bidPool, uint256 target, uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256 totalInfoTargetLength = 0;
        uint256 totalInfoAmount = 0;
        for (uint256 i = 0; i < targetToInfoCluster[bidPool][target].length; i++) {
            InfoParams memory infoParams = targetToInfoCluster[bidPool][target][i];
            if (infoParams.bidTime >= startTimestamp && infoParams.bidTime <= endTimestamp) {
                totalInfoTargetLength += infoParams.length;
                totalInfoAmount += infoParams.amount;
            }
        }
        if (totalInfoTargetLength == 0) {
            return 0;
        }
        return totalInfoAmount / totalInfoTargetLength; // 信含密度梯度， 针对DA下的单个item
    }

    function calculateInfoContentDensityByBidPool(address bidPool, uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        (bool success, bytes memory data) = bidPool.staticcall("targets()");
        uint256[] memory targets = abi.decode(data, (uint256[]));
        uint256 infoContentMass;
        for (uint256 i=0; i< targets.length; i++) {
            infoContentMass += calculateInfoContentDensityGradientByTarget(bidPool, targets[i], startTimestamp, endTimestamp);
        }
        return infoContentMass / targets.length; // 信含密度， 针对某个DA
    }


    function calculateInfoContentCardinal(uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256 infoContentDensity;
        uint256 poolsLength = IBidPoolFactory(BidPoolFactory).getBidPoolsLength();
        for (uint256 i=0; i<poolsLength; i++) {
            address bidPool = IBidPoolFactory(BidPoolFactory).getBidPool(i);
            infoContentDensity += calculateInfoContentDensityByBidPool(bidPool, startTimestamp, endTimestamp);

        }
        return infoContentDensity/poolsLength; // 信含基数
    }
}
