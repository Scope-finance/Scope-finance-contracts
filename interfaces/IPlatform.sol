// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IPlatform {

    function addAsset(string memory name_, address address_) external ;

    function addStakeToken(string memory asset_, address token_) external;
}