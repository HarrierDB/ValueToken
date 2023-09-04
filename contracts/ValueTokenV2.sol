// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ValueTokenV2 is ERC20, Ownable {
    mapping(address => bool) public authorizedERC721Addresses;  // 存储被授权的ERC721合约地址

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function authorizeERC721Address(address _erc721Address) public onlyOwner {
        authorizedERC721Addresses[_erc721Address] = true;
    }

    function revokeERC721Address(address _erc721Address) public onlyOwner {
        authorizedERC721Addresses[_erc721Address] = false;
    }

    function transferFromForERC721(address from, address to, uint256 amount) public returns (bool) {
//        require(authorizedERC721Addresses[msg.sender], "Only authorized ERC721 contracts can call this function");

        _transfer(from, to, amount);
        return true;
    }

    // 允许任何人铸币
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // 重计量
    function remeasure(uint256 infoIndex) public view returns (uint256) {
        return 0;
    }
}
