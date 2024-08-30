pragma solidity ^0.8.0;

contract MintableToken {
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _lastMove;
    
    address public owner;
    bool public isMinting;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event MintingEnabled();
    event MintingDisabled();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(){
        owner = msg.sender;
        isMinting = true;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function.");
        _;
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
        require(isMinting == true, "Minting is currently disabled.");
        _balances[to] += amount;
        _lastMove[to] = block.timestamp;
    }
    
    function enableMinting() external onlyOwner {
        require(isMinting == false, "Minting is already enabled.");
        isMinting = true;
        emit MintingEnabled();
    }
    
    function disableMinting() external onlyOwner {
        require(isMinting == true, "Minting is already disabled.");
        isMinting = false;
        emit MintingDisabled();
    }
    
    function transfer(address to, uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Insufficient balance.");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        _lastMove[to] = block.timestamp;
        _lastMove[msg.sender] = block.timestamp;
        emit Transfer(msg.sender, to, amount);
    }
    
    function getBalance(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function getLastMove(address account) external view returns (uint256) {
        return _lastMove[account];
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0x0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}