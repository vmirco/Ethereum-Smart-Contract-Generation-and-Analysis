// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Converter {
    function uintToHex(uint256 value) public pure returns (string memory) {
        bytes memory buffer = new bytes(64); // Enough to hold 256 bits in hexadecimal
        for (uint256 i = 0; i < 64; i++) {
            uint8 nibble = uint8(value >> ((63 - i) * 4)) & 0xF;
            if (nibble < 10) {
                buffer[i] = bytes1(uint8(nibble + 48)); // 0-9
            } else {
                buffer[i] = bytes1(uint8(nibble + 87)); // a-f
            }
        }
        return string(buffer);
    }

    function uintToEther(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0 MIC";
        }
        if (value < 1e15) { // Less than 0.001 MIC (1e15 wei)
            return "< 0.001 MIC";
        }
        if (value == 1e15) { // Exactly 0.001 MIC
            return "0.001 MIC";
        }
        if (value > 1e15) { // Greater than 0.001 MIC
            uint256 wholePart = value / 1e18;
            uint256 fractionalPart = value % 1e18;
            string memory result = string(abi.encodePacked(uint2str(wholePart), "."));
            // Convert fractional part to string with leading zeros if necessary
            bytes memory fractionalBytes = bytes(uint2str(fractionalPart));
            uint256 leadingZeros = 18 - fractionalBytes.length;
            for (uint256 i = 0; i < leadingZeros; i++) {
                result = string(abi.encodePacked(result, "0"));
            }
            result = string(abi.encodePacked(result, fractionalBytes, " MIC"));
            return result;
        }
        return ""; // Fallback, should never reach here
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