// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IInfocode.sol";

contract Infocode is IInfocode {
    uint256 public totalSupply;
    constructor(){

    }

    function mint(uint256 amount) public override returns (bool) {
         return true;
    }
}
