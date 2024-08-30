// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IERC20 {
    function totalSupply() public view virtual returns (uint256) {}
    function balanceOf(address account) public view virtual returns (uint256) {}
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {}
    function allowance(address owner, address spender) public view virtual returns (uint256) {}
    function approve(address spender, uint256 amount) public virtual returns (bool) {}
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {}

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ERC20 is Context, IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }
}

contract YearnVault is ERC20 {
    IERC20 public token;
    uint256 public pricePerShare;

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        
        _mint(msg.sender, _amount);
        
        // assuming price per share increases after every deposit
        pricePerShare += _amount;
    }

    function withdraw(uint256 _shares) external {
        uint256 r = (pricePerShare * _shares) / 1e18;
        
        _burn(msg.sender, _shares);

        token.transfer(msg.sender, r);
        
        // assuming price per share decreases after every withdrawal
        if (_shares < pricePerShare) {
            pricePerShare -= _shares;
        } else {
            pricePerShare = 0;
        }
    }

    function getPricePerShare() external view returns (uint256) {
        return pricePerShare;
    }

    function getToken() external view returns (IERC20) {
        return token;
    }
}