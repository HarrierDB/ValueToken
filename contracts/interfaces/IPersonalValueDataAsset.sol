// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPersonalValueDataAsset {

    function getDurationById(uint256 tokenId) external view returns (uint256);

    function getCreatorById(uint256 tokenId) external view returns (address);

}