// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import {AssetContract} from "./AssetContract.sol";
import {IPlatform} from "../interfaces/IPlatform.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IAsset} from "../interfaces/IAssets.sol";


contract Factory is Ownable {

    IPlatform private platform;

    mapping(string => address) public assetAddress; 

    event Deployed(string indexed _name, address addr);

    function getBytecode(
        string memory _name,
        string memory _symbol
    ) public pure returns (bytes memory) {
        bytes memory bytecode = type(AssetContract).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
    }


    function addPlatform(address platform_) external onlyOwner {
        platform = IPlatform(platform_);
    }


    function deploy(uint _salt, string memory _name, string memory symbol) public payable {

        bytes memory bytecode = type(AssetContract).creationCode;

        bytes memory bytecode_ = abi.encodePacked(
            bytecode,
            abi.encode(_name, symbol)
        );        
        address addr;

        assembly {
            addr := create2(
                callvalue(),
                add(bytecode_, 0x20),
                mload(bytecode_),
                _salt 
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        assetAddress[_name] = addr;

        platform.addAsset(_name, addr);
        IAsset(addr).addPlatform(address(platform));
        emit Deployed(_name, addr);
    }


}
