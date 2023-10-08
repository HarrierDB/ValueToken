// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBidPoolFactory {


    function getBidPool(uint256 index) external view returns (address);

    function getBidPoolsLength() external view returns (uint256);

    function getBidPoolByDataAsset(address dataAsset) external view  returns (address);

    function createBidPool(string memory name, string memory symbol, address dataAsset, uint256 basicReward) external returns (address);
}
