// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PausableToken {
    mapping(address => bool) public pausableAddresses;
    bool public isPaused;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setPausableAddress(address _address, bool _isPausable) external onlyOwner {
        pausableAddresses[_address] = _isPausable;
    }

    function checkPausableAddress(address _address) external view returns (bool) {
        return pausableAddresses[_address];
    }

    function pause() external onlyOwner {
        isPaused = true;
    }

    function resume() external onlyOwner {
        isPaused = false;
    }

    function getPauseStatus() external view returns (bool) {
        return isPaused;
    }

    function transfer(address _to, uint256 _amount) external whenNotPaused {
        require(!pausableAddresses[msg.sender], "Sender address is pausable");
        // Assuming there's a balance check and update logic here for simplicity
        // require(balanceOf[msg.sender] >= _amount, "Not enough balance");
        // balanceOf[msg.sender] -= _amount;
        // balanceOf[_to] += _amount;
        // Emit Transfer event
    }
}