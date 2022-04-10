// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IPlatform} from "../interfaces/IPlatform.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract StakersToken is ERC20, ERC20Burnable, Ownable, ERC20Snapshot {

    address private platform;
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000000000000);
    }


    modifier onlyPlatform(){
        require(msg.sender == platform);
        _;
    }
    function snapshot() public onlyOwner {
        _snapshot();
    }

     function addPlatform(address platform_) external onlyOwner {
        platform = platform_;
    }
    function claimReturns(string memory asset_) public {
        uint256 reward = IPlatform(platform).claimRewards(asset_, msg.sender);
        _mint(msg.sender, reward);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function exchangerewards(string memory asset_, uint256 amount_) external onlyPlatform {
        _burn(msg.sender, amount_);
        IPlatform(platform).exchangeStakeToken(asset_, amount_, msg.sender);
    }
}