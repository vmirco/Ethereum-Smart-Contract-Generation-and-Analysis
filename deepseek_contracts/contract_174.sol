// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Treasury {
    address public operator;
    uint256 public totalPiggySupply;
    uint256 public seigniorage;
    mapping(address => uint256) public bonds;
    mapping(address => bool) public isOracle;
    mapping(address => bool) public isMasonry;

    modifier onlyOperator() {
        require(msg.sender == operator, "Not the operator");
        _;
    }

    modifier onlyOracle() {
        require(isOracle[msg.sender], "Not an oracle");
        _;
    }

    modifier onlyMasonry() {
        require(isMasonry[msg.sender], "Not a masonry");
        _;
    }

    constructor(address _operator) {
        operator = _operator;
    }

    function setOperator(address _newOperator) external onlyOperator {
        operator = _newOperator;
    }

    function setOracle(address _oracle, bool _status) external onlyOperator {
        isOracle[_oracle] = _status;
    }

    function setMasonry(address _masonry, bool _status) external onlyOperator {
        isMasonry[_masonry] = _status;
    }

    function updatePiggyPrice(uint256 _newPrice) external onlyOracle {
        // Logic to update Piggy price based on Oracle's input
    }

    function delegateBond(address _to, uint256 _amount) external onlyMasonry {
        require(_amount > 0, "Amount must be greater than 0");
        bonds[_to] += _amount;
    }

    function distributeSeigniorage(uint256 _amount) external onlyOperator {
        require(_amount <= seigniorage, "Not enough seigniorage");
        seigniorage -= _amount;
        // Logic to distribute seigniorage
    }

    function mintPiggy(uint256 _amount) external onlyOperator {
        require(_amount > 0, "Amount must be greater than 0");
        totalPiggySupply += _amount;
        // Logic to mint new Piggy tokens
    }

    function burnPiggy(uint256 _amount) external onlyOperator {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= totalPiggySupply, "Not enough supply");
        totalPiggySupply -= _amount;
        // Logic to burn Piggy tokens
    }

    function addSeigniorage(uint256 _amount) external onlyOperator {
        require(_amount > 0, "Amount must be greater than 0");
        seigniorage += _amount;
    }
}