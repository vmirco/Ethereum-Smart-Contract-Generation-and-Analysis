// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Basic ERC20 Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}

//Contract that interacts with ERC20 Tokens
contract TokenInteractor {
    IERC20 erc20Instance;

    //Set the token address
    function setToken(address _token) public {
        erc20Instance = IERC20(_token);
    }

    //Check balance of the contract
    function checkBalance() public view returns (uint256) {
        return erc20Instance.balanceOf(address(this));
    }

    //Check allowance
    function checkAllowance(address _owner, address _spender) public view returns (uint256) {
        return erc20Instance.allowance(_owner, _spender);
    }

    //Approve token transfer
    function approve(address _spender, uint256 _value) public returns (bool) {
        return erc20Instance.approve(_spender, _value);
    }

    //Transfer tokens from the Contract's balance
    function transfer(address _to, uint256 _value) public returns (bool) {
        return erc20Instance.transfer(_to, _value);
    }

    //Transfer tokens from one address to another
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        return erc20Instance.transferFrom(_from, _to, _value);
    }
}