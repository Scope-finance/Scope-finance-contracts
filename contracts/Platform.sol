// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Thetix is Ownable {

    mapping (string => AggregatorV3Interface) internal assetAggregator;

    IERC20 internal scopeToken;

    mapping (string => int256) private _assetPrice;

    
    constructor(
        IERC20 token_
    ) {
        scopeToken = token_;
    }


    function addAsset(
        string memory name_,
        AggregatorV3Interface agg_
    ) external onlyOwner {
        assetAggregator[name_] = agg_;    
    }

    function speculate(
        string memory assetName_,
        uint128 amount_
    ) external {
        require(scopeToken.allowance(msg.sender, address(this)) >= amount_);
        scopeToken.transferFrom(msg.sender, address(this), amount_);
    } 

    function getLatestPrice(string memory asset_) public view returns (int) {
        (,int price,,,) = assetAggregator[asset_].latestRoundData();
        return price;
    }
}