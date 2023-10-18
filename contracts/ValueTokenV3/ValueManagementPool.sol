// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



contract ValueManagementPool {
    address public dataAsset;
    address public valuecode;

    constructor(string memory name_, string memory symbol_, address dataAsset_) ERC20(name_, symbol_) {
        dataAsset = dataAsset_;
    }

    function initialize(uint256 itemId) public override {
        address ownerOfItemId = ERC721(dataAsset).ownerOf(itemId);

        ERC721(dataAsset).transferFrom(ownerOfItemId, address(this), itemId);
    }

    // 1. 先将DA转给管理工程师；
    // 2. 再调回调接口；
    // 3. 再拿到DA的现在的Valuecode；
    // 4. 价值管理工程师要支付该Valuecode;
    // 5. 再拿到价值管理工程师的时值；
    // 6. 再把时值加到DA的Valuecode里；
    // 7. 最后将DA转回VMPool；
    function manageValue(uint256 tokenId, address timeValue,uint256 timeLength, bytes extraParams) public {
        // 1先将DA转给管理工程师；
        ERC721(dataAsset).transferFrom(address(this), msg.sender, tokenId);
        // 2. 再调回调接口；
        if (extraParams.length >0) {IValueManagementPoolCallee(msg.sender).valueManagementPoolCall(tokenId, timeValue, timeLength, extraParams);}

        // 3. 再拿到DA的现在的Valuecode；
        (bool success, bytes memory data) = dataAsset.call(abi.encodeWithSignature("getValuecode()"));
        require(success, "Cannot fetch time value of engineer.");
        uint256 valuecodePrevious = abi.decode(data, (uint256));
        // 4. 价值管理工程师要支付该Valuecode;
        IERC20(valuecode).transferFrom(msg.sender, address(this), valuecodePrevious);

        // 5. 再拿到价值管理工程师的时值；
        (bool success_, bytes memory data_) = timeValue.call(abi.encodeWithSignature("balanceOf(address)", msg.sender));
        require(success_, "Cannot fetch time value of engineer.");
        uint256 timeValueOfEngineer = abi.decode(data_, (uint256));
        uint256 valuecodeAdded = timeValueOfEngineer * timeLength;
        // 6. 再把时值加到DA的Valuecode里
        IDataAsset(dataAsset).setValuecode(tokenId, valuecodePrevious+valuecodeAdded);
        // 7. 最后将DA转回VMPool；
        ERC721(dataAsset).transferFrom(msg.sender, address(this), tokenId);
    }
}
