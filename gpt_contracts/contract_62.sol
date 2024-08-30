// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath library to perform safe arithmetic operations
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
}

// Enumerating for the enumerable set
enum Set {NONE, FIRST_VALUE, SECOND_VALUE, THIRD_VALUE} 

// Main contract
contract Counter {
    using SafeMath for uint256;

    uint256 private _counter;
    Set[] private _enumSet;
    mapping(uint256 => Set) private _enumMapping;

    function increment() public {
        _counter = _counter.add(1);
    }

    function decrement() public {
        require(_counter > 0, "Counter: decrement overflow");
        _counter = _counter.sub(1);
    }

    function reset() public {
        _counter = 0;
    }

    function getCounter() public view returns (uint256) {
        return _counter;
    }

    function addToSet(Set _set) public {
        _enumSet.push(_set);
        _enumMapping[_enumSet.length - 1] = _set;
    }

    function getFromSet(uint256 _index) public view returns (Set) {
        require(_index < _enumSet.length, "Counter: index out of bounds");
        return _enumMapping[_index];
    }

    function sizeOfSet() public view returns (uint256) {
        return _enumSet.length;
    }
}