// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Leb128 {
    function encodeUnsignedLeb128(uint64 value) public pure returns (bytes memory) {
        bytes memory buffer = new bytes(10); // Max 10 bytes for uint64
        uint index = 0;
        do {
            uint8 byteValue = uint8(value & 0x7F);
            value >>= 7;
            if (value != 0) {
                byteValue |= 0x80;
            }
            buffer[index++] = bytes1(byteValue);
        } while (value != 0);

        bytes memory result = new bytes(index);
        for (uint i = 0; i < index; i++) {
            result[i] = buffer[i];
        }
        return result;
    }

    function decodeUnsignedLeb128(bytes memory data) public pure returns (uint64, uint) {
        uint64 result = 0;
        uint shift = 0;
        uint index = 0;

        while (true) {
            uint8 byteValue = uint8(data[index++]);
            result |= uint64(byteValue & 0x7F) << shift;
            if ((byteValue & 0x80) == 0) {
                break;
            }
            shift += 7;
        }

        return (result, index);
    }
}