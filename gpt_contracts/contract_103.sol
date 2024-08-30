pragma solidity ^0.8.0;

contract Median {

    struct Rate {
        uint rate;
        uint lastUpdatedTime;
    }

    mapping(string => Rate) public rates;
    mapping(string => address) public signers;

    event RateUpdated(string symbol, uint rate);

    function updateRate(string calldata symbol, uint newRate, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 message = keccak256(abi.encodePacked(symbol, newRate));
        address signer = getSigner(message, v, r, s);

        require(signers[symbol] == signer, 'Invalid signer');
        rates[symbol] = Rate(newRate, block.timestamp);

        emit RateUpdated(symbol, newRate);
    }

    function setSigner(string calldata symbol, address signer) external {
        signers[symbol] = signer;
    }

    function getSigner(bytes32 message, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        bytes32 ethSignedMessage = prefixed(message);
        return ecrecover(ethSignedMessage, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}