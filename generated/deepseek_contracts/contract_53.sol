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

contract ERC20TokenInteraction {
    IERC20 public token;

    struct Module {
        bool isActive;
        address moduleAddress;
    }

    Module[] public modules;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function addModule(address _moduleAddress) external {
        modules.push(Module({
            isActive: true,
            moduleAddress: _moduleAddress
        }));
    }

    function removeModule(uint256 _index) external {
        require(_index < modules.length, "Module index out of range");
        modules[_index].isActive = false;
    }

    function transferTokens(address _recipient, uint256 _amount) external {
        require(token.transfer(_recipient, _amount), "Token transfer failed");
    }

    function approveTokens(address _spender, uint256 _amount) external {
        require(token.approve(_spender, _amount), "Token approval failed");
    }

    function transferFromTokens(address _sender, address _recipient, uint256 _amount) external {
        require(token.transferFrom(_sender, _recipient, _amount), "Token transferFrom failed");
    }

    function getTotalSupply() external view returns (uint256) {
        return token.totalSupply();
    }

    function getBalanceOf(address _account) external view returns (uint256) {
        return token.balanceOf(_account);
    }

    function staticCall(address _target, bytes memory _data) external view returns (bytes memory) {
        (bool success, bytes memory result) = _target.staticcall(_data);
        require(success, "Static call failed");
        return result;
    }
}