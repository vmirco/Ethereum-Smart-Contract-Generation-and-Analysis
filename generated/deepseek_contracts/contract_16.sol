// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PausableToken {
    mapping(address => bool) public pausableAddresses;
    bool public paused;
    mapping(address => uint256) private balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event PauseStatusChanged(bool newStatus);
    event AddressSetPausable(address indexed addr, bool isPausable);

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function setPausable(address addr, bool isPausable) external {
        pausableAddresses[addr] = isPausable;
        emit AddressSetPausable(addr, isPausable);
    }

    function isPausable(address addr) external view returns (bool) {
        return pausableAddresses[addr];
    }

    function setPauseStatus(bool newStatus) external {
        paused = newStatus;
        emit PauseStatusChanged(newStatus);
    }

    function getPauseStatus() external view returns (bool) {
        return paused;
    }

    function transfer(address to, uint256 amount) external whenNotPaused {
        require(!pausableAddresses[msg.sender], "Sender address is pausable");
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function mint(address account, uint256 amount) external {
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}