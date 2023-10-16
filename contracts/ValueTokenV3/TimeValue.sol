// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/ERC20.sol";

contract TimeValue is ERC20 {

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        revert("Transfers are not allowed");
    }

    // 禁止 transferFrom 操作
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        revert("Transfers are not allowed");
    }

    // 设置每个人的TimeValue余额，只有合约所有者可以调用
    // timeValue本身就是时值，它的余额就是时值（不可转让）
    // 所以这个函数的作用就是设置每个人的时值
    // 只要通过balanceOf函数就可以获取到每个人的时值
    function setBalance(address account, uint256 amount) public onlyOwner {
        _balances[account] = amount;
        emit Transfer(address(0), account, amount);
    }

}
