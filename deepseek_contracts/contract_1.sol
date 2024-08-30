// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IOmnibridge {
    function relayTokens(address token, address _receiver, uint256 _value) external;
}

contract WETHOmnibridgeRouter {
    IWETH public immutable weth;
    IOmnibridge public immutable omnibridge;

    event TokenWrapped(address indexed user, uint256 amount);
    event TokenRelayed(address indexed user, address indexed receiver, uint256 amount);

    mapping(address => bool) public registeredAccounts;

    constructor(address _weth, address _omnibridge) {
        weth = IWETH(_weth);
        omnibridge = IOmnibridge(_omnibridge);
    }

    modifier onlyRegistered() {
        require(registeredAccounts[msg.sender], "Account not registered");
        _;
    }

    function registerAccount() external {
        registeredAccounts[msg.sender] = true;
    }

    function wrapTokens() external payable onlyRegistered {
        require(msg.value > 0, "Amount must be greater than 0");
        weth.deposit{value: msg.value}();
        emit TokenWrapped(msg.sender, msg.value);
    }

    function relayTokens(address token, address receiver, uint256 amount) external onlyRegistered {
        require(amount > 0, "Amount must be greater than 0");
        require(receiver != address(0), "Invalid receiver address");

        if (token == address(weth)) {
            weth.transfer(address(this), amount);
            weth.withdraw(amount);
        }

        omnibridge.relayTokens(token, receiver, amount);
        emit TokenRelayed(msg.sender, receiver, amount);
    }

    receive() external payable {
        // Allow deposits of ETH
    }
}