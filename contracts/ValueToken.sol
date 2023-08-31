// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./InformationToken.sol";  // 导入InformationToken合约

contract ValueToken is ERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    InformationToken public informationToken;  // InformationToken合约的实例


    constructor(
        string memory name,
        string memory symbol,
        address _informationToken
    ) ERC20(name, symbol) public {
        informationToken = InformationToken(_informationToken);

    }
    // 重计量
    function remeasure(uint256 infoIndex) public view returns (uint256) {
        InformationToken.Bid[] memory bids = informationToken.getBidHistory(infoIndex);
        uint256 sum = 0;
        uint256 count = 0;
        uint256 oneHourAgo = block.timestamp - 1 hours;

        for (uint i = 0; i < bids.length; i++) {
            if (bids[i].timestamp >= oneHourAgo) {
                sum += bids[i].price;
                count++;
            }
        }

        if (count == 0) return 0;

        return sum / count;  // 计算平均价
    }

    function distributeValueTokens(uint256 infoIndex) public {
        uint256 averagePrice = remeasure(infoIndex);  // 获取平均价
        require(averagePrice > 0, "Average price must be greater than zero.");

        InformationToken.Bid[] memory bids = informationToken.getBidHistory(infoIndex);
        uint256 oneHourAgo = block.timestamp - 1 hours;

        address previousBidder = address(0);
        uint256 previousBid = 0;

        for (uint i = 0; i < bids.length; i++) {
            if (bids[i].timestamp >= oneHourAgo) {
                uint256 valueTokenAmount;
                if (previousBidder == address(0)) {
                    valueTokenAmount = bids[i].price / averagePrice;  // 归一化
                } else {
                    valueTokenAmount = (bids[i].price - previousBid) / averagePrice;  // 归一化差额
                }

                // 更新上一个出价和出价者
                previousBid = bids[i].price;
                previousBidder = bids[i].bidder;

                // 派发ValueToken
                _balances[bids[i].bidder] += valueTokenAmount;
                _totalSupply += valueTokenAmount;

                emit Transfer(address(0), bids[i].bidder, valueTokenAmount);
            }
        }
    }

}