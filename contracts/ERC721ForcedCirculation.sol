// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";  // 导入IERC20接口
import "@openzeppelin/contracts/access/Ownable.sol";


interface IValueTokenV2 {
    function transferFromForERC721(address from, address to, uint256 amount) external returns (bool);
}

contract ERC721ForcedCirculation is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemCounter;

    struct Item {
        uint256 itemId;
        string uri;
        uint256 guidePrice;
        uint256 publishTime;
        uint256 auctionDuration;
        address temporaryOwner;
    }

    struct Bid {
        uint256 itemId;
        address temporaryOwner;
        uint256 price;
        uint256 timestamp;
    }

    event ItemPublished(uint256 itemId, address publisher, string uri, uint256 guidePrice, uint256 publishTime, uint256 auctionDuration);

    mapping(uint256 => Item) public items;
    mapping(uint256 => Bid[]) public bidHistory;
    IValueTokenV2 public valueToken;  // 使用IERC20接口

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }

    function setValueToken(address _valueToken) public onlyOwner {
        valueToken = IValueTokenV2(_valueToken);
    }

    function publishItem(string memory uri, uint256 guidePrice, uint256 auctionDuration) public returns (uint256) {
        _itemCounter.increment();
        uint256 itemId = _itemCounter.current();
        _mint(msg.sender, itemId);
        _setTokenURI(itemId, uri);
        items[itemId] = Item({
            itemId: itemId,
            uri: uri,
            guidePrice: guidePrice,
            publishTime: block.timestamp,
            auctionDuration: auctionDuration,
            temporaryOwner: msg.sender
        });

        emit ItemPublished(itemId, msg.sender, uri, guidePrice, block.timestamp, auctionDuration);

        return itemId;
    }

    function bid(uint256 itemId, uint256 price) public {
        require(items[itemId].temporaryOwner != address(0), "Item does not exist.");
        require(block.timestamp < items[itemId].publishTime + items[itemId].auctionDuration, "Auction has ended.");

        uint256 currentPrice = items[itemId].guidePrice;
        if (bidHistory[itemId].length > 0) {
            Bid memory lastBid = bidHistory[itemId][bidHistory[itemId].length - 1];
            currentPrice = lastBid.price;
        }

        require(price > currentPrice, "Price is lower than current price or guide price.");

        Bid memory newBid = Bid({
            itemId: itemId,
            temporaryOwner: msg.sender,
            price: price,
            timestamp: block.timestamp
        });

        bidHistory[itemId].push(newBid);

        // 授权新的临时所有者
        _approve(msg.sender, itemId);

        // Force transfer of the item
        safeTransferFrom(items[itemId].temporaryOwner, msg.sender, itemId);

        // Pay to the previous temporary owner
        require(valueToken.transferFromForERC721(msg.sender, items[itemId].temporaryOwner, price), "Token transfer failed.");

        // Update the temporary owner
        items[itemId].temporaryOwner = msg.sender;
    }

    //get guide price
    function getGuidePrice(uint256 itemId) public view returns (uint256) {
        return items[itemId].guidePrice;
    }
}
