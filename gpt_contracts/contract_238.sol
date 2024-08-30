// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Converters {

    function uintToHex(uint256 value) public pure returns (string memory) {
        return appendHexPrefix(_toHex(value));
    }

    function uintToEther(uint256 value) public pure returns (string memory) {
        uint256 MIC = value;
        uint256 milliMIC = value / 1e3;
        uint256 Gwei = value / 1e9;
        if(Gwei > 0) {
            return appendGweiUnits(toString(Gwei));
        } else if(milliMIC > 0) {
            return appendMilliMicUnits(toString(milliMIC));
        } else {
            return appendMicUnits(toString(MIC));
        }
    }
    
    function _toHex(uint256 value) private pure returns (string memory) {
        if (value == 0)
            return "0";
        uint j = value.length;
        bytes memory bstr = new bytes(j);
        uint i;

        while (value != 0) {
            uint remainder = value % 16;
            value = value / 16;
            if (remainder < 10)
                bstr[--j] = bytes1(uint8(48 + remainder));
            else
                bstr[--j] = bytes1(uint8(87 + remainder));
        }
        return string(bstr);
    }
    
    function appendHexPrefix(string memory _hex) private pure returns (string memory) {
        return string(abi.encodePacked("0x", _hex));
    }
    
    function appendMicUnits(string memory _value) private pure returns(string memory){
        return string(abi.encodePacked(_value, " MIC"));
    }
    
    function appendMilliMicUnits(string memory _value) private pure returns(string memory){
        return string(abi.encodePacked(_value, " milliMIC"));
    }
    
    function appendGweiUnits(string memory _value) private pure returns(string memory){
        return string(abi.encodePacked(_value, " Gwei"));
    }
    
    function toString(uint256 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}