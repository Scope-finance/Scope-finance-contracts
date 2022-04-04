// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import {AssetContract} from "./AssetContract.sol";
contract Factory {

    mapping(string => address) public assetAddress; 

    event Deployed(string indexed _name, address addr);

    function getBytecode(string memory _name, string memory _symbol) private pure returns (bytes memory) {
        bytes memory bytecode = type(AssetContract).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
    }


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


        emit Deployed(_name, addr);
    }
}
