// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ValueTokenV3/InfoAsset.sol";
import "./Valuecode.sol";

contract InfoFactory is Ownable {
    // 存储已部署的 NFT 合约地址
    address[] public deployedNFTs;

    // 黑名单映射
    mapping(address => bool) public blacklist;

    // 映射以关联 NFT Collection 合约地址和奖励数量
    mapping(address => uint256) public nftRewards;

    // ERC20 Token 作为奖励
    Valuecode public valuecode;

    // 事件，用于记录新 NFT 合约的部署
    event NFTDeployed(address indexed nftContract, address indexed owner);

    // 构造函数，设置 ValueToken 地址
    constructor(address _valuecode) {
        valuecode = Valuecode(_valuecode);
    }

    // 生成信息资产的函数
    function createInfoAsset(string memory name, string memory symbol, uint256 _type, bytes calldata _infoFactoryCalleeData) external onlyOwner returns (address) {
        // 检查是否在黑名单上
        require(!blacklist[msg.sender], "Address is blacklisted");

        // 部署新的 ERC721ForcedCirculation 合约
        InfoAsset infoAsset = new InfoAsset(name, symbol, _type);

        // 记录部署的 NFT Collection 合约地址
        deployedNFTs.push(address(infoAsset));

        // 触发部署事件
        emit NFTDeployed(address(infoAsset), msg.sender);

        // 检查是否有与 NFT Collection 关联的奖励
        uint256 rewardAmount = nftRewards[address(infoAsset)];
        if (rewardAmount > 0) {
            // 转移奖励给 NFT 创建者
            valuecode.transfer(msg.sender, rewardAmount);
        }

        // 调用 InfoFactoryCallee 函数并传入 calldata
        if (_infoFactoryCalleeData.length > 0) {
            require(address(infoAsset).call(_infoFactoryCalleeData), "InfoFactoryCallee call failed");
        }

        // 返回新合约的地址
        return address(infoAsset);
    }

    // 获取已部署的 NFT Collection 合约数量
    function getDeployedNFTsCount() external view returns (uint256) {
        return deployedNFTs.length;
    }

    // 获取用户拥有的 NFT Collection 合约地址数组
    function getUserNFTCollections(address user) external view returns (address[] memory) {
        return userToNFTCollections[user];
    }

    // 添加地址到黑名单，只有合约所有者可以调用
    function addToBlacklist(address user) external onlyOwner {
        blacklist[user] = true;
    }

    // 从黑名单中移除地址，只有合约所有者可以调用
    function removeFromBlacklist(address user) external onlyOwner {
        blacklist[user] = false;
    }

    // 更新奖励数量，只有合约所有者可以调用
    function updateReward(address nftCollection, uint256 rewardAmount) external onlyOwner {
        nftRewards[nftCollection] = rewardAmount;
    }
}
