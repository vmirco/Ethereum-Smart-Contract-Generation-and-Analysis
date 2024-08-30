// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DelegateContract {
    address public implementation;
    uint256 public num;
    address public value;

    event ImplementationSet(address indexed newImplementation);
    event NumSet(uint256 newNum);
    event ValueSet(address newValue);

    modifier onlyImplementation() {
        require(msg.sender == implementation, "Caller is not the implementation");
        _;
    }

    function setImplementation(address _newImplementation) external {
        implementation = _newImplementation;
        emit ImplementationSet(_newImplementation);
    }

    function delegateSetNum(uint256 _newNum) external onlyImplementation {
        num = _newNum;
        emit NumSet(_newNum);
    }

    function delegateSetValue(address _newValue) external onlyImplementation {
        value = _newValue;
        emit ValueSet(_newValue);
    }
}

contract ProxyContract {
    address public implementation;
    uint256 public num;
    address public value;

    function setImplementation(address _newImplementation) external {
        implementation = _newImplementation;
    }

    function setNum(uint256 _newNum) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("delegateSetNum(uint256)", _newNum)
        );
        require(success, "Delegate call failed");
    }

    function setValue(address _newValue) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("delegateSetValue(address)", _newValue)
        );
        require(success, "Delegate call failed");
    }
}