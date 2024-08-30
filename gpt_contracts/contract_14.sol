// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AccessControl is Context, ERC165 {

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    
    mapping (bytes32 => mapping (address => bool)) private _roles;
    
    mapping (bytes32 => bytes32) private _roleAdmins;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, _msgSender()), "AccessControl: account does not have permission");
        _;
    }
    
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }
    
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roleAdmins[role] = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        _roles[role][account] = true;
        emit RoleGranted(role, account, _msgSender());
    }
    
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roleAdmins[role];
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(AccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
}

abstract contract ERC721Burnable is AccessControl  {
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_msgSender() == tokenOwner || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role or token owner can burn");
        _burn(tokenId);
    }

    function _burn(uint256 tokenId) internal virtual;
}

abstract contract ERC721 is AccessControl, ERC721Burnable {
    using Strings for uint256;

    string private _baseURI;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _tokenOwner;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return _baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        return bytes(base).length > 0 ? string(abi.encodePacked(base, _tokenURI)) : "";
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwner[tokenId] != address(0);
    }

    function _burn(uint256 tokenId) internal virtual override {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        delete _tokenOwner[tokenId];
    }
}

contract RandomApeNFT is ERC721 {

    constructor() ERC721("RandomApeNFT", "APE"){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function mint(address to) public virtual onlyRole(MINTER_ROLE) {
        _mint(to, totalSupply() + 1);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        _tokenOwner[tokenId] = to;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setBaseURI(string memory baseURI_) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to change base URI");
        _baseURI = baseURI_;
    }
}