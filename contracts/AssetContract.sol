// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IPlatform} from "../interfaces/IPlatform.sol";

contract AssetContract is ERC20, ERC20Burnable, Ownable {

    address private platform;
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, 1000000000000000000);
    }
    modifier onlyPlatform(){
        require(msg.sender == platform);
        _;
    }

     function addPlatform(address platform_) external /*onlyOwner*/ {
        platform = platform_;
    }

    function purchaseAssets(string memory name_, uint256 amount) public {
        uint mintables = IPlatform(platform).buyAsset(name_, amount, msg.sender);
        _mint(msg.sender, mintables);
    }

    function sellAsset(string memory name_, uint256 amount) public {
        IPlatform(platform).checkOut(name_, amount, msg.sender);
        _burn(msg.sender, amount);
    }

}