// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IValueManagementPoolCallee {


    function valueManagementPoolCall(uint256 tokenId, address timeValue,uint256 timeLength, bytes calldata extraParams) external returns (bool);

}
