// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignedMintableToken is ERC721 {
    using ECDSA for bytes32;
    
    mapping(uint256 => address) public tokenRequester;
    mapping(uint256 => bytes) public tokenSignature;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {
        
    }

    function mintWithSignature(uint256 tokenId, bytes memory signature) public {
        // This will reconstruct the signer's address based on the `tokenId` and `signature`
        // This assumes that the signed message was the `tokenId` (converted to bytes)
        bytes32 messageHash = keccak256(abi.encodePacked(tokenId));
        address signer = messageHash.recover(signature);

        // Check that the signer is not the zero address
        require(signer != address(0), "SignedMintableToken: invalid signature");

        // Record requester address and signature
        tokenRequester[tokenId] = msg.sender;
        tokenSignature[tokenId] = signature;

        // Mint the token
        _mint(msg.sender, tokenId);
    }

    function verifySignature(uint256 tokenId, bytes memory signature) public view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(tokenId));
        address signer = messageHash.recover(signature);
        return tokenRequester[tokenId] == signer;
    }
}