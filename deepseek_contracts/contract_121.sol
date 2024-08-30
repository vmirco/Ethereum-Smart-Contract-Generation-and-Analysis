// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OraclizeI {
    // Placeholder for OraclizeI contract functionality
}

contract Buffer {
    // Placeholder for Buffer library functionality
}

contract CBOR {
    // Placeholder for CBOR library functionality
}

contract DataSourceManager is OraclizeI {
    mapping(bytes32 => string) public dataSources;
    mapping(bytes32 => uint256) public gasPrices;

    event DataSourceSet(bytes32 indexed id, string source);
    event GasPriceSet(bytes32 indexed id, uint256 price);

    function setDataSource(bytes32 _id, string memory _source) public {
        dataSources[_id] = _source;
        emit DataSourceSet(_id, _source);
    }

    function getDataSource(bytes32 _id) public view returns (string memory) {
        return dataSources[_id];
    }

    function setGasPrice(bytes32 _id, uint256 _price) public {
        gasPrices[_id] = _price;
        emit GasPriceSet(_id, _price);
    }

    function getGasPrice(bytes32 _id) public view returns (uint256) {
        return gasPrices[_id];
    }
}

// Placeholder implementations for Buffer and CBOR libraries
contract Buffer {
    function buffer(uint capacity) internal pure returns (Buffer memory r) {
        assembly {
            r := mload(0x40)
            mstore(0x40, add(r, and(add(add(0x20, 0x1f), capacity), not(0x1f))))
            mstore(r, capacity)
        }
    }

    function append(Buffer memory buf, uint8 data) internal pure {
        assembly {
            let newOffset := add(buf, 0x20)
            mstore8(newOffset, data)
            mstore(buf, add(mload(buf), 1))
        }
    }
}

contract CBOR {
    using Buffer for Buffer.Buffer;

    function encodeType(Buffer.Buffer memory buf, uint8 major, uint value) internal pure {
        if(value < 24) {
            buf.append(uint8((major << 5) | value));
        } else if(value <= 0xFF) {
            buf.append(uint8((major << 5) | 24));
            buf.append(uint8(value));
        } else if(value <= 0xFFFF) {
            buf.append(uint8((major << 5) | 25));
            buf.append(uint8((value >> 8) & 0xFF));
            buf.append(uint8(value & 0xFF));
        } else if(value <= 0xFFFFFFFF) {
            buf.append(uint8((major << 5) | 26));
            buf.append(uint8((value >> 24) & 0xFF));
            buf.append(uint8((value >> 16) & 0xFF));
            buf.append(uint8((value >> 8) & 0xFF));
            buf.append(uint8(value & 0xFF));
        } else {
            buf.append(uint8((major << 5) | 27));
            buf.append(uint8((value >> 56) & 0xFF));
            buf.append(uint8((value >> 48) & 0xFF));
            buf.append(uint8((value >> 40) & 0xFF));
            buf.append(uint8((value >> 32) & 0xFF));
            buf.append(uint8((value >> 24) & 0xFF));
            buf.append(uint8((value >> 16) & 0xFF));
            buf.append(uint8((value >> 8) & 0xFF));
            buf.append(uint8(value & 0xFF));
        }
    }
}