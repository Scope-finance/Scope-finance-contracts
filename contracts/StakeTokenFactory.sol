// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import {StakersToken} from "./StakeToken.sol";
import {IPlatform} from "../interfaces/IPlatform.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeTokenFactory is Ownable {

    IPlatform private platform;

    mapping(string => address) public assetAddress; 

    event Deployed(string indexed _name, address addr);

    function getBytecode(
        string memory _name,
        string memory _symbol
    ) public pure returns (bytes memory) {
        bytes memory bytecode = type(StakersToken).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
    }
/*
    function addPlatform(address platform_) external onlyOwner {
        platform = platform_;
    }
*/
    function deploy(bytes memory bytecode, uint _salt, string memory _name) public payable {
        address addr;

        assembly {
            addr := create2(
                callvalue(),
                add(bytecode, 0x20),
                mload(bytecode),
                _salt 
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        assetAddress[_name] = addr;

        platform.addStakeToken(_name, addr);
        emit Deployed(_name, addr);
    }
}
