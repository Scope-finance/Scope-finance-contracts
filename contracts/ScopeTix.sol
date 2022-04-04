// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScopeToken is ERC20, ERC20Burnable, Ownable {

    address private platform;
    constructor(
        address _platform
    ) ERC20("ScopeToken", "SCPT") {
        platform = _platform;
    }

    modifier onlyPlatform(){
        require(msg.sender == platform);
        _;
    }

    function mint(address to, uint256 amount) public onlyPlatform {
        _mint(to, amount);
    }

    function burn(address owner_, uint256 amount_) external onlyPlatform {
        _burn(owner_, amount_);
    }
}