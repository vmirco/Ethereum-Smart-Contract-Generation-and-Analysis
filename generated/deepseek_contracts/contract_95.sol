// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DelegateCallProxy {
    address public implementation;
    uint256 public num;
    uint256 public value;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function setNum(uint256 _num) public {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("setNum(uint256)", _num)
        );
        require(success, "Delegate call failed");
    }

    function setValue(uint256 _value) public {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _value)
        );
        require(success, "Delegate call failed");
    }
}

contract Implementation {
    uint256 public num;
    uint256 public value;

    function setNum(uint256 _num) public {
        num = _num;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }
}