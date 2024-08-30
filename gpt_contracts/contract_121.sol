// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint _capacity) internal pure {
        if(_capacity%32 != 0) _capacity += 32 - (_capacity%32);
        // Allocate space for the buffer data
        buf.capacity = _capacity;
        assembly { mstore(buf, _capacity) }
    }

    function resize(buffer memory buf, uint _capacity) pure private {
        if(_capacity%32 != 0) _capacity += 32 - (_capacity%32);
        // Allocate space for the new buffer
        bytes memory newbuf = new bytes(_capacity);
        // Copy buffer to the new buffer
        for(uint i = 0; i < buf.capacity; i++) {
            newbuf[i] = buf.buf[i];
        }
        buf.buf = newbuf;
        buf.capacity = _capacity;
    }

    function append(buffer memory buf, bytes memory data) internal pure {
        if (data.length + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, data.length) * 2);
        }
        uint dest;
        uint src;
        assembly {
            dest := add(add(buf, 32), mload(buf))
            src := add(data, 32)
        }
        memcpy(dest,src, data.length);
        assembly { mstore(buf, add(mload(buf), mload(data))) }
    }

    function memcpy(uint _dest, uint _src, uint _len) pure private {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }
        // Copy remaining bytes
        uint mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    function max(uint a, uint b) internal pure returns(uint) {
        if(a > b) {
            return a;
        } else {
            return b;
        }
    }
}

library CBOR {
    using Buffer for Buffer.buffer;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) internal pure {
        if(value <= 23) {
            buf.append(byte(bytes1(uint8((major << 5) | value))));
        } else if(value <= 0xFF) {
            buf.append(byte(bytes1(uint8((major << 5) | 24))));
            buf.append(byte(bytes1(uint8(value))));
        } else if(value <= 0xFFFF) {
            buf.append(byte(bytes1(uint8((major << 5) | 25))));
            buf.append(abi.encodePacked(uint16(value)));
        } else if(value <= 0xFFFFFFFF) {
            buf.append(byte(bytes1(uint8((major << 5) | 26))));
            buf.append(abi.encodePacked(uint32(value)));
        } else if(value <= 0xFFFFFFFFFFFFFFFF) {
            buf.append(byte(bytes1(uint8((major << 5) | 27))));
            buf.append(abi.encodePacked(uint64(value)));
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) internal pure {
        buf.append(byte(bytes1(uint8((major << 5) | 31))));
    }

    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {
        encodeType(buf, 0, value);
    }

    function encodeInt(Buffer.buffer memory buf, int value) internal pure {
        if(value < -0x10000000000000000) {
            encodeType(buf, 1, uint(-value));
        } else {
            encodeType(buf, 0, uint(value));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes memory value) internal pure {
        encodeType(buf, 2, value.length);
        buf.append(value);
    }

    function encodeString(Buffer.buffer memory buf, string memory value) internal pure {
        encodeType(buf, 3, bytes(value).length);
        buf.append(bytes(value));
    }
}

interface OraclizeI {

    function proofType_NONE()
    pure external returns (byte);
    function proofType_TLSNotary()
    pure external returns (byte);
    function proofType_Android()
    pure external returns (byte);
    function proofStorage_IPFS()
    pure external returns (byte);

    function query(uint _timestamp, string calldata _datasource, string calldata _arg)
    external payable returns (bytes32 _id);

} 

contract OraclizeIExtended is OraclizeI{

    event LogNewOraclizeQuery(bytes32 indexed queryId, string datasource);
    event LogNewQueryResult(bytes32 indexed queryId, string result);

    mapping(string => uint) private gasPrices;
    mapping(bytes32 => string) public queries;

    function setGasPrice(string memory datasource, uint price) public {
        gasPrices[datasource] = price;
    }

    function getGasPrice(string memory datasource) public view returns (uint) {
        return gasPrices[datasource];
    }

    function proofType_NONE()
    pure public override returns (byte) {return 0x00;}
    function proofType_TLSNotary()
    pure public override returns (byte) {return 0x10;}
    function proofType_Android()
    pure public override returns (byte) {return 0x20;}
    function proofStorage_IPFS()
    pure public override returns (byte) {return 0x01;}

    function query(uint _timestamp, string memory _datasource, string memory _arg) 
    public payable override returns (bytes32 _id) {
        Buffer.buffer memory buffer;
        Buffer.init(buffer, _arg.length + 64);
        CBOR.encodeString(buffer, _datasource);
        CBOR.encodeString(buffer, _arg);
        bytes32 queryId = keccak256(buffer.buf);
        queries[queryId] = _datasource;
        emit LogNewOraclizeQuery(queryId, _datasource);

        return queryId;
    }

    function setQueryResult(bytes32 queryId, string memory result) public {
        require(bytes(queries[queryId]).length != 0, "OraclizeIExtended: query does not exist");

        emit LogNewQueryResult(queryId, result);
    }

}