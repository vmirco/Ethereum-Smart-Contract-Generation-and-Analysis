// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeclarationOfDecentralization {
    address public admin;
    string public declaration;
    mapping(address => bool) public signatories;
    uint256 public signatoryCount;

    constructor(address _admin, string memory _declaration) {
        require(_admin != address(0), "Invalid address");
        admin = _admin;
        declaration = _declaration;
    }

    function addSignatory(address _signatory) public {
        require(msg.sender == admin, "Only admin can add signatories");
        require(_signatory != address(0), "Invalid address");
        require(!signatories[_signatory], "Signatory already added");

        signatories[_signatory] = true;
        signatoryCount += 1;
    }

    function sign() public {
        require(signatories[msg.sender], "Only authorized signatories can sign");
        
        signatories[msg.sender] = false;
        signatoryCount -= 1;
    }

    function modifyDeclaration(string memory _declaration) public {
        require(msg.sender == admin, "Only admin can modify declaration");
        declaration = _declaration;
    }
}