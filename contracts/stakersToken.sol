// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract StakersToken is ERC20, ERC20Burnable, Ownable, ERC20Snapshot {

    address private platform;
    constructor(
        address _platform
    ) ERC20("Stakers Token", "STKTN") {
        platform = _platform;
    }


    modifier onlyPlatform(){
        require(msg.sender == platform);
        _;
    }
    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function burn(address owner_, uint256 amount_) external onlyPlatform {
        _burn(owner_, amount_);
    }
}