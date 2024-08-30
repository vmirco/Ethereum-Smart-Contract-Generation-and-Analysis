// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeclarationOfDecentralization {
    address public owner;
    address public debotAddress;
    string public declarationText;
    mapping(address => bool) public signers;
    address[] public signatures;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == debotAddress, "Not authorized to modify the contract");
        _;
    }

    constructor(address _debotAddress, string memory _declarationText) {
        owner = msg.sender;
        debotAddress = _debotAddress;
        declarationText = _declarationText;
    }

    function updateDeclaration(string memory _newDeclarationText) public onlyAuthorized {
        declarationText = _newDeclarationText;
    }

    function addSigner(address _signer) public onlyOwner {
        signers[_signer] = true;
    }

    function removeSigner(address _signer) public onlyOwner {
        signers[_signer] = false;
    }

    function signDeclaration() public {
        require(signers[msg.sender], "Not authorized to sign the declaration");
        signatures.push(msg.sender);
    }

    function getSignatures() public view returns (address[] memory) {
        return signatures;
    }
}