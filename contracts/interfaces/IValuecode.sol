// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IValuecode {
    // 转换成Infocode用于竞价
    function swapIntoInfocode(uint256) external returns (bool);

}
