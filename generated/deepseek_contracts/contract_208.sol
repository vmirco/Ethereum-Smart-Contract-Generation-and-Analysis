// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Leb128 {
    function encodeUnsignedLeb128(uint64 value) public pure returns (bytes memory) {
        bytes memory buffer = new bytes(10);
        uint index = 0;
        while (true) {
            uint8 byte = uint8(value & 0x7F);
            value >>= 7;
            if (value != 0) {
                buffer[index++] = bytes1(byte | 0x80);
            } else {
                buffer[index++] = bytes1(byte);
                break;
            }
        }
        bytes memory result = new bytes(index);
        for (uint i = 0; i < index; i++) {
            result[i] = buffer[i];
        }
        return result;
    }

    function decodeUnsignedLeb128(bytes memory data) public pure returns (uint64) {
        uint64 result = 0;
        uint64 shift = 0;
        for (uint i = 0; i < data.length; i++) {
            uint8 byte = uint8(data[i]);
            result |= uint64(byte & 0x7F) << shift;
            if ((byte & 0x80) == 0) {
                break;
            }
            shift += 7;
        }
        return result;
    }
}