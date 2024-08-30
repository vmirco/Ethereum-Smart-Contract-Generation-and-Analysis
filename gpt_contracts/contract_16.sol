// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PausableTokenContract {

    mapping(address => uint) private _balances;
    mapping(address => bool) private _pausableAddresses;
    bool private _paused;

    event Transfer(address indexed from, address indexed to, uint value);
    event Pause(address indexed account);
    event Unpause(address indexed account);

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused"); 
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public whenNotPaused {
        _paused = true;
        emit Pause(msg.sender);
    }

    function unpause() public whenPaused {
        _paused = false;
        emit Unpause(msg.sender);
    }

    function pauseStatus() public view returns (bool) {
        return _paused;
    }

    function isPausable(address addr) public view returns (bool) {
        return _pausableAddresses[addr];
    }

    function setPausable(address addr) public {
        _pausableAddresses[addr] = true;
    }

    function removePausable(address addr) public {
        _pausableAddresses[addr] = false;
    }

    function transfer(address recipient, uint amount) public whenNotPaused {
        require(_pausableAddresses[msg.sender] == false, "Pausable: This address is pausable and the contract is paused."); 
        require(amount <= _balances[msg.sender], "Insufficient balance.");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }
}