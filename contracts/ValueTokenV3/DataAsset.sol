// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDataAsset.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


abstract contract DataAsset is IDataAsset, ERC721URIStorage {


    address public factory; // 创建该DA的Factory
    address public creator; // 存储数据资产的创建者
    address public bidPool; // 每一个dataAsset都有对应的bidPool
    uint256 public timeValue; // 该数据资产创建者的时值

    function getTimeValue() external view override returns (uint256) {
        return timeValue;
    }

    function getFactory() public view override returns (address) {
        return factory;
    }

    function getCreator() external view override returns (address) {
        return creator;
    }


    function setBidPool(address _bidPool) public override returns (bool) {
        bidPool = _bidPool;
        super._setApprovalForAll(msg.sender, _bidPool, true);
        return true;
    }
}
