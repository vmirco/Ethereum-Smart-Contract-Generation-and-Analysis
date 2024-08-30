// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// IERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GMTokenUnwrapper {
    mapping(address => uint256) public unwrapTimestamp;
    address public gmTokenAddress;
    bool public isUnwrapEnabled;

    // Implementing reentrancy guards
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'GMTokenUnwrapper: REENTRANCY_LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function unwrap(uint256 _amount) external lock {
        require(isUnwrapEnabled, "GMTokenUnwrapper: The unwrap functionality is currently disabled");
        require(IERC20(gmTokenAddress).balanceOf(msg.sender) >= _amount, "GMTokenUnwrapper: You don't have enough tokens to unwrap");
        require(block.timestamp > calculateMaxUnwrappedAmount(msg.sender), "GMTokenUnwrapper: Your tokens are still locked");
        
        IERC20(gmTokenAddress).transfer(msg.sender, _amount);
        unwrapTimestamp[msg.sender] = block.timestamp;
    }

    function toggleUnwrap(bool _value) external {
        isUnwrapEnabled = _value;
    }

    function updateGMTokenAddress(address _newAddress) external {
        gmTokenAddress = _newAddress;
    }

    function calculateMaxUnwrappedAmount(address _user) public view returns (uint256) {
        return unwrapTimestamp[_user] + 1 days;
    }
}