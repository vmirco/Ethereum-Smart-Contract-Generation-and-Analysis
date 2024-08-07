// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeclarationOfDecentralization {
    string public declarationText;
    address public debotAddress;
    mapping(address => bool) public signers;
    address[] public signatures;

    modifier onlyDebot() {
        require(msg.sender == debotAddress, "Only the debot can call this function");
        _;
    }

    modifier onlySigner() {
        require(signers[msg.sender], "Only authorized signers can call this function");
        _;
    }

    constructor(address _debotAddress, string memory _declarationText) {
        debotAddress = _debotAddress;
        declarationText = _declarationText;
    }

    function updateDeclaration(string memory newDeclarationText) public onlyDebot {
        declarationText = newDeclarationText;
    }

    function addSigner(address newSigner) public onlyDebot {
        signers[newSigner] = true;
    }

    function removeSigner(address signer) public onlyDebot {
        signers[signer] = false;
    }

    function signDeclaration() public onlySigner {
        signatures.push(msg.sender);
    }

    function getSignatures() public view returns (address[] memory) {
        return signatures;
    }
}