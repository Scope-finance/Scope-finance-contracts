// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IPlatform {

    function addAsset(string memory name_, address address_) external ;

    function addStakeToken(string memory asset_, address token_) external;

    function buyAsset(string memory name_, uint256 amount_, address buyer_) external returns(uint256);

    function checkOut(
        string memory asset_,
        uint256 amount_,
        address sender_
    ) external;

    function claimRewards(
        string memory asset_,
        address sender
    ) external returns(uint256) ;

    function exchangeStakeToken(
        string memory asset_,
        uint256 amount_,
        address sender
    ) external;
}