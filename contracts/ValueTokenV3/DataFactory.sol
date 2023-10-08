// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol"; // 导入 Ownable 合约

import "../interfaces/IDataFactory.sol";
import "./NonFungibleDataAsset.sol"; // 导入非同质化数据资产合约
import "./MultiDuplicateNonFungibleDataAssetContract.sol"; //导入多副本非同质化数据资产合约
import "./SemiFungibleDataAsset.sol"; // 导入半同质化数据资产合约

contract DataFactory is IDataFactory, Ownable {
    address public treasury;
    // 存储创建的数据资产合约地址
    address[] public deployedDataAssets;
    address[] public deployedPersonalValueDataAssets;
    address[] public deployedPersonalDataAssets;
    address[] public deployedCommodities;

    // 存储数据所有者创建的数据资产合约地址
    mapping(address => address[]) public deployedDataAssetsByDataCreator;
    // 黑名单映射
    mapping(address => bool) public blacklist;

    // 构造函数
    constructor(address _treasury) {
        treasury = _treasury;
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

    // 实现接口函数 - 获取所有数据资产地址
    function getDataAssets(uint256 index) external view override returns (address) {
        // 根据index返回数据资产地址
        return deployedDataAssets[index];
    }

    // 实现接口函数 - 获取所有数据资产数量
    function getDataAssetsLength() external view override returns (uint256) {
        // 返回数据资产的总数量
        return deployedDataAssets.length;
    }

    // 实现接口函数 - 根据数据所有者获取数据资产地址
    function getDataAssetByDataCreator(address dataCreator, uint256 index) external view override returns (address) {
        // 根据数据所有者和index返回数据资产地址
        return deployedDataAssetsByDataCreator[dataCreator][index];
    }

    function getDataAssetsLengthByDataCreator(address dataCreator) external view override returns (uint256) {
        // 根据数据所有者返回其数据资产的数量
        return deployedDataAssetsByDataCreator[dataCreator].length;
    }

    // 实现接口函数 - 创建数据资产
    function createDataAsset(string memory name, string memory symbol, uint8 dataType, uint16 dataStandard) external override returns (address) {
        // 检查是否在黑名单上
        require(!blacklist[msg.sender], "Address is blacklisted");

        address dataAsset; // 声明数据资产地址变量

        // 数据类型为0，创建个人价值数据资产
        // 数据类型为1，创建个人数据资产
        // 数据类型为2, 创建商品数据
        if (dataType == 0) {
            dataAsset = createPersonalValueDataAsset(name, symbol, dataStandard);
        } else if (dataType == 1) {
            dataAsset = createPersonalDataAsset(name, symbol, dataStandard);
        } else if (dataType == 2) {
            dataAsset = createCommodity(name, symbol, dataStandard);
        } else {
            revert("Invalid datatype");
        }

        // 将数据资产地址存储在deployedDataAssets数组中
        deployedDataAssets.push(dataAsset);

        // 将数据资产地址存储在deployedDataAssetsByDataCreator映射中
        deployedDataAssetsByDataCreator[msg.sender].push(dataAsset);

        // 触发事件
        emit DataAssetCreated(dataAsset, msg.sender);

        // 返回新创建的数据资产合约地址
        return dataAsset;
    }

    // 适用于个人劳动，规定时间戳、任务戳
    // 可接受721, 1155, 3525标准
    // 根据标准不同，创建不同的数据资产标准
    function createPersonalValueDataAsset(string memory name, string memory symbol, uint16 dataStandard) internal returns (address) {

        address personalValueDataAsset;

        if (dataStandard == 721) {
            personalValueDataAsset = address(new NonFungibleDataAsset(name, symbol));
        } else if (dataStandard == 1155) {
            personalValueDataAsset = address(new MultiDuplicateNonFungibleDataAssetContract(name, symbol));
        } else if (dataStandard == 3525) {
            personalValueDataAsset = address(new SemiFungibleDataAsset(name, symbol));
        } else {
            revert("Invalid data standard");
        }

        deployedPersonalValueDataAssets.push(personalValueDataAsset);
        return personalValueDataAsset;
    }

    // 适用于个人基础信息、个人收入、个人支出、个人投资数据
    // 只接受721标准
    function createPersonalDataAsset(string memory name, string memory symbol, uint16 dataStandard) internal returns (address) {
        require(dataStandard == 721, "Invalid data standard");

        address personalDataAsset;

        personalDataAsset = address(new NonFungibleDataAsset(name, symbol));
        deployedPersonalDataAssets.push(personalDataAsset);

        return personalDataAsset;
    }

    // 适用于商品数据
    // 只接受721标准
    function createCommodity(string memory name, string memory symbol, uint16 dataStandard) internal returns (address) {
        require(dataStandard == 721, "Invalid data standard");

        address commodity;

        commodity = address(new NonFungibleDataAsset(name, symbol));
        deployedCommodities.push(commodity);

        return commodity;
    }

}
