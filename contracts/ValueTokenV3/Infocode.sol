// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IInfocode.sol";
import "../libraries/ERC20.sol";

contract Infocode is IInfocode, ERC20 {
    address public immutable BidPoolFactory;
    constructor(string memory name_, string memory symbol_, address BidPoolFactory_) ERC20(name_, symbol_) {
        BidPoolFactory = BidPoolFactory_;
    }

    // get all BidPools -> walk over all BidPools by index -> for each bid pool get rewards


    function mint(address account, uint256 amount) public override {
         _mint(account, amount);
    }

    // reverse指的是infocode转换成valuecode
    function reverse(uint256 amount) public override {
        _burn(msg.sender, amount);
    }
}
