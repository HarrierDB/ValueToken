// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDataFactory {
    event DataAssetCreated(address indexed dataAsset, address indexed dataCreator);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event BlacklistAdded(address indexed user);
    event BlacklistRemoved(address indexed user);

    // 管理函数
    function addToBlacklist(address user) external;
    function removeFromBlacklist(address user) external;

    // 方便根据数据所有者和索引获取数据资产地址和长度
    function getDataAssets(uint256 index) external view returns (address);
    function getDataAssetsLength() external view returns (uint256);
    function getDataAssetByDataCreator(address dataCreator, uint256 index) external view returns (address);
    function getDataAssetsLengthByDataCreator(address dataCreator) external view returns (uint256);

    // 核心功能: 创建数据资产
    function createDataAsset(string memory name, string memory symbol, uint8 dataType, uint16 dataStandard) external returns (address);

}
