// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IDataAsset.sol";


abstract contract DataAsset is IDataAsset {


    address public factory; // 创建该DA的Factory
    address public creator; // 存储数据资产的创建者
    address public bidPool; // 每一个dataAsset都有对应的bidPool

    function getFactory() public view override returns (address) {
        return factory;
    }

    function getCreator() external view override returns (address) {
        return creator;
    }


    function setBidPool(address _bidPool) public override returns (bool) {
        bidPool = _bidPool;
        return true;
    }
}
