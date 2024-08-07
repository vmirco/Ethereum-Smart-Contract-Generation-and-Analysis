// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface IERC223 {
    function transfer(address to, uint256 value, bytes memory data) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
}

contract TenxAminToken is IERC20, IERC223 {
    string public name = "10xAmin Token";
    string public symbol = "10XA";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(msg.sender, to, value, "");
        return true;
    }

    function transfer(address to, uint256 value, bytes memory data) public override returns (bool) {
        _transfer(msg.sender, to, value, data);
        return true;
    }

    function _transfer(address from, address to, uint256 value, bytes memory data) internal {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[from] >= value, "Insufficient balance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value, data);
        if (isContract(to)) {
            _callTokenFallback(from, to, value, data);
        }
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(allowance[sender][msg.sender] >= amount, "Allowance too low");
        allowance[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount, "");
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function _callTokenFallback(address from, address to, uint256 value, bytes memory data) private {
        IERC223Receiver(to).tokenFallback(from, value, data);
    }
}

interface IERC223Receiver {
    function tokenFallback(address from, uint256 value, bytes memory data) external;
}