// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScopeToken is ERC20, Ownable {

    constructor(
    ) ERC20("ScopeToken", "SCPT") {
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}