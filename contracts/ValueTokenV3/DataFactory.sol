// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDataFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // 导入 Ownable 合约

contract DataFactory is IDataFactory, Ownable {
    // 存储创建的数据资产合约地址
    address[] public deployedDataAssets;
    // 存储数据所有者创建的数据资产合约地址
    mapping(address dataOwner => address[]) public deployedDataAssetsByDataOwner;

    // 黑名单映射
    mapping(address => bool) public blacklist;

    // 构造函数
    constructor() {
        // 设置合约所有者为部署者（您）
        transferOwnership(msg.sender);
    }

    // 实现接口函数 - 获取合约所有者
    function owner() external view override returns (address) {
        return owner();
    }

    // 实现接口函数 - 设置合约所有者
    function setOwner(address _owner) external override onlyOwner {
        transferOwnership(_owner);
    }

    // 实现接口函数 - 获取所有数据资产地址
    function getDataAssets(uint256 index) external view override returns (address) {
        // 根据index返回数据资产地址
        return deployedDataAssets[index];
    }

    // 实现接口函数 - 获取所有数据资产数量
    function allDataAssetsLength() external view override returns (uint256) {
        // 返回数据资产的总数量
        return deployedDataAssets.length;
    }

    // 实现接口函数 - 根据数据所有者获取数据资产地址
    function getDataAssetByDataOwner(address dataOwner, uint256 index) external view override returns (address) {
        // 根据数据所有者和index返回数据资产地址
        return deployedDataAssetsByDataOwner[dataOwner][index];
    }

    function allDataAssetsLengthByDataOwner(address dataOwner) external view override returns (uint256) {
        // 根据数据所有者返回其数据资产的数量
        return deployedDataAssetsByDataOwner[dataOwner].length;
    }

    // 实现接口函数 - 创建数据资产
    function createDataAsset(string memory name, string memory symbol, uint256 datatype, bytes calldata data) external override onlyOwner returns (address) {
        // 检查是否在黑名单上
        require(!blacklist[msg.sender], "Address is blacklisted");

        // 在这里实现创建数据资产的逻辑
        // 部署一个新的数据资产合约，并将其地址存储在deployedDataAssets数组中

        // 触发事件
        emit DataAssetCreated(address(dataAsset), msg.sender);

        // 返回新创建的数据资产合约地址
        return address(dataAsset);
    }

    // 实现接口函数 - 添加地址到黑名单
    function addToBlacklist(address user) external override onlyOwner {
        // 在这里添加地址到黑名单的逻辑
        blacklist[user] = true;

        // 触发事件
        emit BlacklistAdded(user);
    }

    // 实现接口函数 - 从黑名单中移除地址
    function removeFromBlacklist(address user) external override onlyOwner {
        // 在这里移除地址从黑名单的逻辑
        blacklist[user] = false;

        // 触发事件
        emit BlacklistRemoved(user);
    }
}
