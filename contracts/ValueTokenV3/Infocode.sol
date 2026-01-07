// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IInfocode.sol";
import "../interfaces/IBidPoolFactory.sol";
import "../interfaces/IBidPool.sol";
import "../libraries/ERC20.sol";

contract Infocode is IInfocode, ERC20 {
    address public immutable BidPoolFactory;
    uint256 public infoContentCardinal;
    constructor(string memory name_, string memory symbol_, address BidPoolFactory_) ERC20(name_, symbol_) {
        BidPoolFactory = BidPoolFactory_;
    }

    // get all BidPools -> walk over all BidPools by index -> for each bid pool get rewards


    function mint(address account, uint256 amount) public override {
         _mint(account, amount);
    }

    // reverse指的是infocode转换成valuecode
    function reverse(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // 计算信含基数
//    function calculateInfoContentCardinal(uint256 startTimestamp, uint256 endTimestamp) public returns (uint256) {
//        uint256 PTVSum;
//        uint256 poolsLength = IBidPoolFactory(BidPoolFactory).getBidPoolsLength();
//        for (uint256 i=0; i<poolsLength; i++) {
//            (, uint256 averagePTV)=IBidPool(IBidPoolFactory(BidPoolFactory).getBidPool(i)).getInfoContentsDistribution(startTimestamp, endTimestamp);
//            PTVSum += averagePTV;
//        }
//        infoContentCardinal  = PTVSum/poolsLength;
//        return infoContentCardinal;
//    }
}
