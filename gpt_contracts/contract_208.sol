pragma solidity ^0.8.0;

contract Leb128 {
    function leb128Encode(uint64 value) public pure returns (bytes memory) {
        bytes memory result = new bytes(10);
        uint8 length = 0;
        
        while (value != 0) {
            uint8 byteValue = uint8(value & 0x7F);
            value >>= 7;
            
            if (value != 0) {
                byteValue |= 0x80;
            }
            
            result[length++] = bytes1(byteValue);
        }
        
        bytes memory finalResult = new bytes(length);
        for (uint8 i = 0; i < length; i++) {
            finalResult[i] = result[i];
        }
        return finalResult;
    }

    function leb128Decode(bytes memory data) public pure returns (uint64) {
        uint64 result = 0;
        uint8 shift = 0;
        
        for (uint8 i = 0; i < data.length; i++) {
            uint64 byteValue = uint64(uint8(data[i]));
            result |= (byteValue & 0x7F) << shift;
            if ((byteValue & 0x80) == 0) {
                break;
            }
            shift += 7;
        }
        
        return result;
    }
}