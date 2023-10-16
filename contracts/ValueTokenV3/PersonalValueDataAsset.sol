// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./DataAsset.sol";

contract PersonalValueDataAsset is DataAsset, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenCounter;
    PersonalValue[] private personalValues;
    uint256 private totalDuration;

    event PersonalValueCreated(uint256 tokenId, address creator, string uri, uint256 startTimestamp, uint256 endTimestamp, uint256 duration);


    constructor(string memory name, string memory symbol, uint256 _timeValue) ERC721(name, symbol) {
        creator = msg.sender;
        timeValue = _timeValue;
    }

    function getTotalDuration() public view returns (uint256) {
        return totalDuration;
    }

    function getDurationById(uint256 tokenId) public view returns (uint256) {
        return personalValues[tokenId].taskParams.duration;
    }

    function getCreatorById(uint256 tokenId) public view returns (address) {
        return personalValues[tokenId].basicInfo.creator;
    }


    // taskParams来规定该工种下的某项任务的具体时间
    // 例如，该工种为打扫卫生，即本DA为打扫卫生，而具体任务为任务创建者本人 在某个时刻 某个地点 打扫某个时长 的卫生
    function createItem(string memory uri, TaskParams memory taskParams) public override returns (uint256) {
        uint256 tokenId = _tokenCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        personalValues.push(PersonalValue({
            basicInfo : BasicInfo({
                itemId : tokenId,
                dataAsset : address(this),
                creator : msg.sender,
                uri : uri,
                owner : msg.sender,
                winner : address(0),
                timeCreated : block.timestamp,
                extraParams: "0x"
            }),
            taskParams : TaskParams({
                startTimestamp : taskParams.startTimestamp,
                endTimestamp : taskParams.endTimestamp,
                duration : taskParams.duration
            })
        }));

        totalDuration += taskParams.duration;

        super.setApprovalForAll(address(this), true);

        emit ItemCreated(tokenId, msg.sender, uri);
        emit PersonalValueCreated(tokenId, msg.sender, uri, taskParams.startTimestamp, taskParams.endTimestamp, taskParams.duration);
        _tokenCounter.increment();


        return tokenId;
    }

    // 每次转让后，新的拥有者只要不是bidPool，就会自动授权给bidPool
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
        if (to != bidPool) {
            _setApprovalForAll(to, bidPool, true);
        }
    }

}

