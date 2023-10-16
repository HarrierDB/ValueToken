// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ValueManagementPool.sol";


contract ValueManagementFactory is AccessControl, Ownable {
    bytes32 public constant VME_ROLE = keccak256("VME_ROLE"); // Value Management Engineer
    address[] public deployedValueManagementPools;
    mapping(address => address) private dataAssetToValueManagementPool;

    event ValueManagementPoolCreated(address indexed valueManagementPoolAddress, address indexed dataAssetAddress, address creator, uint256 timestamp);

    constructor(){

    }

    //
    function setupRole(address vmeAddress) public onlyOwner {
        _setupRole(VME_ROLE, vmeAddress);
    }

    function createValueManagementPool(string memory name, string memory symbol, address dataAsset) public onlyRole(VME_ROLE) returns (address) {
        // 创建一个新的ValueManagement合约
        // 返回合约地址
        ValueManagementPool valueManagementPool = new ValueManagementPool(name, symbol, dataAsset);
        address valueManagementPoolAddress = address(valueManagementPool);
        deployedValueManagementPools.push(valueManagementPoolAddress);

        // 将新创建的 BidPool 和相应的数据资产地址关联起来
        dataAssetToValueManagementPool[dataAsset] = valueManagementPoolAddress;

        emit ValueManagementPoolCreated(valueManagementPoolAddress, dataAsset, msg.sender, block.timestamp);

        return valueManagementPoolAddress;

    }

}
