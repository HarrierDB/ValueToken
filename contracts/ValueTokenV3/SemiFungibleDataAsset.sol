// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SemiFungibleDataAsset {
    string public name;
    string public symbol;
    bytes public data;

    constructor(string memory _name, string memory _symbol, bytes memory _data){
        name = _name;
        symbol = _symbol;
        data = _data;
    }
}
