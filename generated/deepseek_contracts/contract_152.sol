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

contract UpgradableToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public admin;
    address public newContractAddress;
    bool public deprecated;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
        admin = msg.sender;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (deprecated && newContractAddress != address(0)) {
            return IERC20(newContractAddress).balanceOf(account);
        }
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (deprecated && newContractAddress != address(0)) {
            return IERC20(newContractAddress).transfer(recipient, amount);
        }
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        if (deprecated && newContractAddress != address(0)) {
            return IERC20(newContractAddress).allowance(owner, spender);
        }
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        if (deprecated && newContractAddress != address(0)) {
            return IERC20(newContractAddress).approve(spender, amount);
        }
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (deprecated && newContractAddress != address(0)) {
            return IERC20(newContractAddress).transferFrom(sender, recipient, amount);
        }
        require(allowances[sender][msg.sender] >= amount, "Allowance too low");
        require(balances[sender] >= amount, "Insufficient balance");
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function deprecate(address _newContractAddress) public onlyAdmin {
        deprecated = true;
        newContractAddress = _newContractAddress;
    }

    function undeprecate() public onlyAdmin {
        deprecated = false;
        newContractAddress = address(0);
    }
}