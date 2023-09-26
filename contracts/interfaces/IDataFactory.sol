// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDataFactory {
    event DataAssetCreated(address indexed dataAsset, address indexed owner);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event BlacklistAdded(address indexed user);
    event BlacklistRemoved(address indexed user);

    function owner() external view returns (address);
    function setOwner(address _owner) external;

    function getDataAssets(uint256 index) external view returns (address);
    function allDataAssetsLength() external view returns (uint256);
    function getDataAssetByDataOwner(address dataOwner, uint256 index) external view returns (address);
    function allDataAssetsLengthByDataOwner(address dataOwner) external view override returns (uint256);

    function createDataAsset(string memory name, string memory symbol, uint256 datatype, bytes calldata data) external onlyOwner returns (address);

    function addToBlacklist(address user) external;
    function removeFromBlacklist(address user) external;
}
