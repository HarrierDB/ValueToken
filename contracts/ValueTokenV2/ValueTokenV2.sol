// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ValueTokenV2 is ERC20, Ownable {
    mapping(address => bool) public authorizedERC721Addresses;  // 存储被授权的ERC721合约地址
    mapping(address => uint256) public lastHourBalance;  // 存储上一个小时每个地址的余额
    mapping(address => uint256) public lastHourTimestamp;  // 存储每个地址上次更新余额的时间戳

    address[] public holders;  // 存储所有持有人的地址
    mapping(address => bool) public isHolder;  // 存储地址是否是持有人

    uint256 public totalTransferredAmount;  // 存储过去一个小时内所有转账的总金额
    uint256 public transferCount;  // 存储过去一个小时内的转账次数
    uint256 public lastRebaseTimestamp;  // 存储上次rebase的时间戳

    event Rebased(uint256 averageAmount);
    event Normalized(address indexed holder, uint256 normalizedChange);
    event BalanceUpdated(address indexed account, uint256 newBalance, uint256 timestamp);
    event HolderUpdated(address indexed account, bool isHolder);

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function authorizeERC721Address(address _erc721Address) public onlyOwner {
        authorizedERC721Addresses[_erc721Address] = true;
    }

    function revokeERC721Address(address _erc721Address) public onlyOwner {
        authorizedERC721Addresses[_erc721Address] = false;
    }

    function transferFromForERC721(address from, address to, uint256 amount) public returns (bool) {
        require(authorizedERC721Addresses[msg.sender], "Only authorized ERC721 contracts can call this function");

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);

        // 更新转账统计
        totalTransferredAmount += amount;
        transferCount++;

        // 更新余额
        _updateBalance(sender);
        _updateBalance(recipient);

        // 更新持有人列表
        _updateHolders(sender);
        _updateHolders(recipient);
    }

    function _updateBalance(address account) internal {
        uint256 currentTimestamp = block.timestamp;
        uint256 lastUpdate = lastHourTimestamp[account];
        if (currentTimestamp - lastUpdate >= 1 hours) {
            lastHourBalance[account] = balanceOf(account);
            lastHourTimestamp[account] = currentTimestamp;
        }
        // 触发事件
        emit BalanceUpdated(account, lastHourBalance[account], currentTimestamp);

    }

    function _updateHolders(address account) internal {
        if (!isHolder[account]) {
            holders.push(account);
            isHolder[account] = true;
        }

        // 触发事件
        emit HolderUpdated(account, true);
    }

    function getNumberOfHolders() public view returns (uint256) {
        return holders.length;
    }

    function getHolder(uint256 index) public view returns (address) {
        require(index < holders.length, "Index out of bounds");
        return holders[index];
    }

    function rebase() public {
//        require(block.timestamp - lastRebaseTimestamp >= 1 hours, "Can only rebase once per hour");
        lastRebaseTimestamp = block.timestamp;

        uint256 averageAmount = transferCount == 0 ? 1 : totalTransferredAmount / transferCount;  // 避免除以零

        emit Rebased(averageAmount);

        // 重置统计数据
        totalTransferredAmount = 0;
        transferCount = 0;

        // 执行规范化
        for (uint256 i = 0; i < getNumberOfHolders(); i++) {
            address holder = getHolder(i);
            uint256 balanceChange = balanceOf(holder) > lastHourBalance[holder] ? balanceOf(holder) - lastHourBalance[holder] : lastHourBalance[holder] - balanceOf(holder);
            uint256 balanceChangeScaled = balanceChange >=1 ? balanceChange : 1;
            uint256 normalizedChange = balanceChange / averageAmount;

            // 在这里执行你的规范化逻辑
            uint256 newBalance = lastHourBalance[holder] - balanceChangeScaled;
            _burn(holder, balanceOf(holder));  // 移除旧余额
            _mint(holder, newBalance);  // 添加新余额

            emit Normalized(holder, normalizedChange);

            // 更新上一个小时的余额
            lastHourBalance[holder] = newBalance;
            lastHourTimestamp[holder] = block.timestamp;
        }
    }

    // 允许任何人铸币
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);

        // 更新统计数据
        totalTransferredAmount += amount;
        transferCount++;

        // 更新余额
        _updateBalance(from);
        _updateBalance(to);
    }

}
