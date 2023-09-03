// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./InformationToken.sol";  // 导入InformationToken合约

contract ValueToken is ERC20 {
    InformationToken public informationToken;  // InformationToken合约的实例

    constructor(
        string memory name_,
        string memory symbol_,
        address _informationToken
    ) ERC20(name_, symbol_) {
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
        uint256 scalingFactor = 10**18;  // 用于模拟小数点后18位
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
                    valueTokenAmount = (bids[i].price * scalingFactor) / averagePrice;  // 归一化
                } else {
                    valueTokenAmount = ((bids[i].price - previousBid) * scalingFactor) / averagePrice;  // 归一化差额
                }

                // 更新上一个出价和出价者
                previousBid = bids[i].price;
                previousBidder = bids[i].bidder;

                // 派发ValueToken
                _mint(bids[i].bidder, valueTokenAmount);  // 这里再次除以 scalingFactor 以恢复原始单位
            }
        }
    }
}
