// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

interface IOmnibridge {
    function relayTokens(address token, address _receiver, uint256 _value) external;
}

contract WETHOmnibridgeRouter {
    IWETH public immutable weth;
    IOmnibridge public immutable omnibridge;

    mapping(address => bool) public registeredAccounts;

    event AccountRegistered(address indexed account);
    event TokensWrapped(address indexed account, uint256 amount);
    event TokensRelayed(address indexed sender, address indexed receiver, uint256 amount);

    constructor(address _weth, address _omnibridge) {
        weth = IWETH(_weth);
        omnibridge = IOmnibridge(_omnibridge);
    }

    modifier onlyRegistered() {
        require(registeredAccounts[msg.sender], "Account not registered");
        _;
    }

    function registerAccount() external {
        require(!registeredAccounts[msg.sender], "Account already registered");
        registeredAccounts[msg.sender] = true;
        emit AccountRegistered(msg.sender);
    }

    receive() external payable {
        wrapTokens();
    }

    function wrapTokens() public payable onlyRegistered {
        require(msg.value > 0, "No ETH sent");
        weth.deposit{value: msg.value}();
        emit TokensWrapped(msg.sender, msg.value);
    }

    function relayTokens(address _receiver, uint256 _amount) external onlyRegistered {
        require(_amount > 0, "Amount must be greater than zero");
        require(weth.balanceOf(address(this)) >= _amount, "Insufficient WETH balance");

        weth.transfer(_receiver, _amount);
        omnibridge.relayTokens(address(weth), _receiver, _amount);
        emit TokensRelayed(msg.sender, _receiver, _amount);
    }
}