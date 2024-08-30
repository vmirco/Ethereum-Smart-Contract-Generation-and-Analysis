// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Start of ERC721DAOToken contract
contract ERC721DAOToken is ERC721, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function mint(address to, uint256 tokenId) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721DAOToken: must have admin role to mint");
        _mint(to, tokenId);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721DAOToken: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721DAOToken: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721DAOToken: token transfer while paused");
    }
}
// End of ERC721DAOToken contract

// Start of ERC721Timelock contract
contract ERC721Timelock {
    uint256 public lockTime;
    ERC721DAOToken public token;

    constructor (ERC721DAOToken _token, uint256 _lockTime) {
        token = _token;
        lockTime = _lockTime;
    }

    function lockToken(uint256 _tokenId) public {
        require(token.ownerOf(_tokenId) == msg.sender, "Not token owner");

        // Transfer token to this contract
        token.safeTransferFrom(msg.sender, address(this), _tokenId);

        //set locked till timestamp for this token
        lockTime = block.timestamp + lockTime;
    }

    function unlockToken(uint256 _tokenId) public {
        require(token.ownerOf(_tokenId) == msg.sender, "Not token owner");
        require(block.timestamp > lockTime, "Token is still locked");

        // Transfer token back to owner
        token.safeTransferFrom(address(this), msg.sender, _tokenId);
    }
}
// End of ERC721Timelock contract

// Start of ERC721Governor contract
contract ERC721Governor {
    ERC721DAOToken public token;
    mapping(address => uint) public governors;

    constructor (ERC721DAOToken _token) {
        token = _token;
    }

    function addGovernor(address _newGovernor) public {
        governors[_newGovernor] = 1;
    }

    function removeGovernor(address _governor) public {
        governors[_governor] = 0;
    }

    function mintToken(address _to, uint256 _tokenId) public {
        require(governors[msg.sender] == 1, "Not a governor");
        token.mint(_to, _tokenId);
    }
}