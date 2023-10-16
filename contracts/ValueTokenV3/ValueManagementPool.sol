// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ValueManagementPool {
    address public dataAsset;

    constructor(string memory name_, string memory symbol_, address dataAsset_) ERC20(name_, symbol_) {
        dataAsset = dataAsset_;
    }

    function initialize(uint256 itemId) public override {
        address ownerOfItemId = ERC721(dataAsset).ownerOf(itemId);

        ERC721(dataAsset).transferFrom(ownerOfItemId, address(this), itemId);
    }

    // 首先要找到msg.sender作为价值管理工程师的时值
    // 然后
    function manageValue(uint256 tokenId, address timeValue,uint256 timeLength) public {
        (bool success, bytes memory data) = timeValue.call(abi.encodeWithSignature("balanceOf(address)", msg.sender));
        require(success, "Cannot fetch time value of engineer.");
        uint256 timeValueOfEngineer = abi.decode(data, (uint256));

    }

}
