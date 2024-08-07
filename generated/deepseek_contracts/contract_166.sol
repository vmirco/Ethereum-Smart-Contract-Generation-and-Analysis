// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoneyMarket {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    Facet[] public facets;
    mapping(address => bool) public lenders;
    mapping(address => bool) public borrowers;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public debts;
    uint256 public totalLent;
    uint256 public totalBorrowed;

    event Lend(address indexed lender, uint256 amount);
    event Borrow(address indexed borrower, uint256 amount);
    event Liquidate(address indexed borrower, uint256 amount);

    function addFacet(address _facetAddress, bytes4[] memory _functionSelectors) external {
        facets.push(Facet(_facetAddress, _functionSelectors));
    }

    function getFacetAddresses() external view returns (address[] memory) {
        address[] memory facetAddresses = new address[](facets.length);
        for (uint256 i = 0; i < facets.length; i++) {
            facetAddresses[i] = facets[i].facetAddress;
        }
        return facetAddresses;
    }

    function lend(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        balances[msg.sender] += amount;
        totalLent += amount;
        lenders[msg.sender] = true;
        emit Lend(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalLent >= totalBorrowed + amount, "Not enough liquidity");
        debts[msg.sender] += amount;
        totalBorrowed += amount;
        borrowers[msg.sender] = true;
        emit Borrow(msg.sender, amount);
    }

    function liquidate(address borrower, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(debts[borrower] >= amount, "Insufficient debt");
        debts[borrower] -= amount;
        totalBorrowed -= amount;
        emit Liquidate(borrower, amount);
    }

    function serializeFacetAddresses() external view returns (string memory) {
        address[] memory addresses = getFacetAddresses();
        string memory json = "[";
        for (uint256 i = 0; i < addresses.length; i++) {
            json = string(abi.encodePacked(json, "\"", toHexString(addresses[i]), "\""));
            if (i < addresses.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "]"));
        return json;
    }

    function toHexString(address addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}