// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OraclizeI {
    function query(uint _timestamp, string memory _datasource, string memory _arg) public payable returns (bytes32 _id);
}

library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint capacity) internal pure returns (buffer memory) {
        bytes memory newBuf = new bytes(capacity);
        return buffer({buf: newBuf, capacity: capacity});
    }

    function append(buffer memory buf, bytes memory data) internal pure {
        uint length = data.length;
        require(buf.capacity >= buf.buf.length + length, "Buffer overflow");
        uint destPtr;
        assembly {
            destPtr := add(add(buf.buf, 32), mload(buf.buf))
        }
        memcpy(destPtr, data, length);
        assembly {
            mstore(buf.buf, add(mload(buf.buf), length))
        }
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(srcpart, destpart))
        }
    }
}

library CBOR {
    using Buffer for Buffer.buffer;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
        if(value <= 23) {
            buf.append(abi.encodePacked(uint8((major << 5) | value)));
        } else if(value <= 0xFF) {
            buf.append(abi.encodePacked(uint8((major << 5) | 24), uint8(value)));
        } else if(value <= 0xFFFF) {
            buf.append(abi.encodePacked(uint8((major << 5) | 25), uint16(value)));
        } else if(value <= 0xFFFFFFFF) {
            buf.append(abi.encodePacked(uint8((major << 5) | 26), uint32(value)));
        } else {
            buf.append(abi.encodePacked(uint8((major << 5) | 27), uint64(value)));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes memory value) internal pure {
        encodeType(buf, 2, value.length);
        buf.append(value);
    }
}

contract DataSourceManager is OraclizeI {
    using CBOR for Buffer.buffer;

    struct DataSource {
        string name;
        uint gasPrice;
    }

    mapping(bytes32 => DataSource) public dataSources;
    mapping(bytes32 => uint) public gasPrices;

    function setDataSource(string memory _name, uint _gasPrice) public returns (bytes32) {
        bytes32 id = keccak256(abi.encodePacked(_name, block.timestamp));
        dataSources[id] = DataSource(_name, _gasPrice);
        gasPrices[id] = _gasPrice;
        return id;
    }

    function getDataSource(bytes32 _id) public view returns (string memory, uint) {
        DataSource memory ds = dataSources[_id];
        return (ds.name, ds.gasPrice);
    }

    function query(uint _timestamp, string memory _datasource, string memory _arg) public payable override returns (bytes32 _id) {
        _id = super.query(_timestamp, _datasource, _arg);
        gasPrices[_id] = msg.value;
    }
}