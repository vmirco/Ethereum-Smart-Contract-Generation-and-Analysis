// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Delegator {

    uint256 public num;
    address public addr;

    event UpdatedNum(address indexed _from, uint256 _num);
    event UpdatedAddr(address indexed _from, address _addr);

    function setNum(address _delegate, uint256 _num) public {

        (bool success,) = _delegate.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));

        require(success, "delegatecall failed");

        emit UpdatedNum(msg.sender, _num);
    }

    function setAddr(address _delegate, address _addr) public {

        (bool success,) = _delegate.delegatecall(abi.encodeWithSignature("setAddr(address)", _addr));

        require(success, "delegatecall failed");

        emit UpdatedAddr(msg.sender, _addr);
    }
}


contract Delegate {

    uint256 public num;
    address public addr;

    function setNum(uint256 _num) public {
        num = _num;
    }

    function setAddr(address _addr) public {
        addr = _addr;
    }
}