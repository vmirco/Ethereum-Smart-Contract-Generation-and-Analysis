// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    function f(bytes memory param1, bytes calldata param2, uint[] memory param3) public pure returns (uint, uint, uint, uint, uint, uint) {
        uint sum = 0;
        for (uint i = 0; i < param3.length; i++) {
            sum += param3[i];
        }
        return (param1.length, param2.length, param3.length, sum, 0, 0);
    }

    function g() public pure returns (uint, uint, uint, uint, uint, uint) {
        bytes memory predefinedBytes = hex"00010203";
        bytes memory predefinedBytesCalldata = hex"04050607";
        uint[] memory predefinedUintArray = new uint[](3);
        predefinedUintArray[0] = 1;
        predefinedUintArray[1] = 2;
        predefinedUintArray[2] = 3;
        return f(predefinedBytes, predefinedBytesCalldata, predefinedUintArray);
    }
}