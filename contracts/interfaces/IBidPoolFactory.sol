// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBidPoolFactory {


    function getBidPool(uint256 index) external view returns (address);

    function getBidPoolsLength() external view returns (uint256);

    function getBidPoolByDataAsset(address dataAsset) external view  returns (address);

    function createBidPool(address dataAsset, string memory name, string memory symbol) external returns (address);
}
