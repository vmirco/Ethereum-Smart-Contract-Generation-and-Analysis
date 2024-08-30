// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoneyMarket {
    struct Facet {
        address facetAddress;
        string facetName;
    }

    Facet[] public facets;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public borrows;
    uint256 public totalSupply;
    uint256 public totalBorrow;

    event Lend(address indexed lender, uint256 amount);
    event Borrow(address indexed borrower, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed borrower, uint256 amount);

    function addFacet(address _facetAddress, string memory _facetName) external {
        facets.push(Facet(_facetAddress, _facetName));
    }

    function getFacetAddresses() external view returns (Facet[] memory) {
        return facets;
    }

    function lend(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        balances[msg.sender] += _amount;
        totalSupply += _amount;
        emit Lend(msg.sender, _amount);
    }

    function borrow(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(totalSupply >= totalBorrow + _amount, "Not enough liquidity");
        borrows[msg.sender] += _amount;
        totalBorrow += _amount;
        emit Borrow(msg.sender, _amount);
    }

    function liquidate(address _borrower, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(borrows[_borrower] >= _amount, "Borrower does not have enough debt");
        borrows[_borrower] -= _amount;
        totalBorrow -= _amount;
        emit Liquidate(msg.sender, _borrower, _amount);
    }

    function serializeFacetAddresses() external view returns (string memory) {
        string memory json = "[";
        for (uint256 i = 0; i < facets.length; i++) {
            json = string(abi.encodePacked(
                json,
                '{"facetAddress":"',
                toHexString(facets[i].facetAddress),
                '","facetName":"',
                facets[i].facetName,
                '"}'
            ));
            if (i < facets.length - 1) {
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