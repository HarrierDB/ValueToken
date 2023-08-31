// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './ERC20.sol';

contract InformationToken is ERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    // 定义事件
    event InformationListed(uint256 indexed infoIndex, address indexed seller, bytes32 keyHash, string description);
    event NewBid(uint256 indexed infoIndex, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 indexed infoIndex, address indexed winner, uint256 amount);

    // 存储密钥哈希和相关信息
    struct Information {
        bytes32 keyHash;  // 密钥的哈希值
        uint256 auctionEndTime;  // 竞拍结束时间
        address seller;  // 卖家地址
        bool isSold;  // 是否已售出
        string description;  // 信息内容和性质的描述
        uint256 highestBid;
        address highestBidder;
    }

    struct Bid {
        uint256 price;
        uint256 timestamp;
        address bidder;
    }

    mapping(uint256 => Bid[]) public bidHistory;  // 记录每个信息的出价历史

    Information[] public informations;  // 所有上架的信息

    mapping(address => uint256) public pendingReturns;  // 用于退款

    mapping(address => bool) public hasClaimed;  // 跟踪哪些地址已经领取过代币

    address public owner;  // 合约的所有者

//    string public name;
//    string public symbol;
//    uint8 public decimals = 18;

    // onlyOwner修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) public {
        name = name;
        symbol = symbol;
        owner = msg.sender;
    }

    // 发行代币给指定地址
    function mint(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Arrays must have the same length.");
        for (uint i = 0; i < recipients.length; i++) {
            _balances[recipients[i]] += amounts[i];
            _totalSupply += amounts[i];
            emit Transfer(address(0), recipients[i], amounts[i]);
        }
    }

    // 领取10000个InformationToken
    function claimTokens() public {
        require(!hasClaimed[msg.sender], "You have already claimed tokens.");

        uint256 amount = 10000 * 10 ** decimals();  // 考虑了小数位
        _balances[msg.sender] += amount;
        _totalSupply += amount;

        hasClaimed[msg.sender] = true;  // 标记该地址已领取

        emit Transfer(address(0), msg.sender, amount);
    }

    // 上架信息
    function listInformation(bytes32 _keyHash, uint256 _auctionDuration, string memory _description) public {
        uint256 auctionEndTime = block.timestamp + _auctionDuration;

        Information memory newInformation = Information({
            keyHash: _keyHash,
            auctionEndTime: auctionEndTime,
            seller: msg.sender,
            isSold: false,
            description: _description,
            highestBid: 0,
            highestBidder: address(0)
        });

        informations.push(newInformation);

        emit InformationListed(informations.length - 1, msg.sender, _keyHash, _description);  // 触发事件

    }

    // 出价
    function bid(uint256 infoIndex, uint256 tokenAmount) public {
        require(transfer(address(this), tokenAmount), "Token transfer failed.");

        Information storage info = informations[infoIndex];

        require(block.timestamp < info.auctionEndTime, "Auction has ended.");
        require(tokenAmount > info.highestBid, "There is a higher bid.");

        if (info.highestBid != 0) {
            require(transfer(info.highestBidder, info.highestBid), "Refunding failed.");
        }

        info.highestBid = tokenAmount;
        info.highestBidder = msg.sender;

        Bid memory newBid = Bid({
            price: tokenAmount,
            timestamp: block.timestamp,
            bidder: msg.sender
        });

        bidHistory[infoIndex].push(newBid);

        emit NewBid(infoIndex, msg.sender, tokenAmount);
    }

    // 获取出价历史
    function getBidHistory(uint256 infoIndex) public view returns (Bid[] memory) {
        return bidHistory[infoIndex];
    }


    // 结束竞拍
    function endAuction(uint256 infoIndex) public {
        Information storage info = informations[infoIndex];

        require(block.timestamp >= info.auctionEndTime, "Auction not yet ended.");
        require(!info.isSold, "Auction has already ended.");

        info.isSold = true;

        address seller = info.seller;
        uint256 amount = info.highestBid;

        emit AuctionEnded(infoIndex, info.highestBidder, info.highestBid);  // 触发事件
    }
}
