// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {

    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Pausable is Ownable {
    
    event Paused(address account);
    event Unpaused(address account);
    
    bool private _paused;

    constructor() {
        _paused = false;
    }
    
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    
    function pause() public virtual onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public virtual onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Payable is Pausable {

    mapping(address => uint256) private _balances;

    event Withdrawn(address indexed payee, uint256 weiAmount);

    function withdraw(address payee) public onlyOwner whenNotPaused {
        uint256 payment = _balances[payee];

        _balances[payee] = 0;

        (bool success, ) = payee.call{value: payment}("");
        require(success, "Payable: unable to send value, included transfer failed");
        
        emit Withdrawn(payee, payment);
    }

    function balanceOf(address payee) public view returns (uint256) {
        return _balances[payee];
    }
    
    receive () external payable {
        _balances[msg.sender] += msg.value;
    }
}