// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Converter {
    function uintToHex(uint256 value) public pure returns (string memory) {
        bytes memory buffer = new bytes(64);
        for (uint256 i = 63; i < 64; --i) {
            uint8 byteValue = uint8(value & 0xff);
            buffer[i] = byteValue > 9 ? bytes1(uint8(byteValue + 87)) : bytes1(uint8(byteValue + 48));
            value >>= 8;
        }
        return string(buffer);
    }

    function uintToEther(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0 MIC";
        }
        if (value < 1e15) {
            return "< 0.001 MIC";
        }
        uint256 quotient = value / 1e15;
        uint256 remainder = value % 1e15;
        string memory result = uint2str(quotient);
        if (remainder > 0) {
            result = string(abi.encodePacked(result, ".", uint2str(remainder)));
        }
        return string(abi.encodePacked(result, " MIC"));
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}