// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTMinter {
    struct MintRequest {
        address requester;
        bytes signature;
    }

    mapping(uint256 => MintRequest) public mintRequests;
    mapping(address => uint256[]) public mintedTokens;
    uint256 public tokenCounter;

    function verifySignature(bytes32 messageHash, bytes memory signature, address signer) internal pure returns (bool) {
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function mintNFT(bytes memory signature, bytes32 messageHash) public {
        require(verifySignature(messageHash, signature, msg.sender), "Signature verification failed");

        uint256 tokenId = tokenCounter++;
        mintRequests[tokenId] = MintRequest({
            requester: msg.sender,
            signature: signature
        });
        mintedTokens[msg.sender].push(tokenId);
    }

    function getMintedTokens(address owner) public view returns (uint256[] memory) {
        return mintedTokens[owner];
    }
}