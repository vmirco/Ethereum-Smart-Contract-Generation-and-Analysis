// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 private _counter;

    // EnumerableSet from OpenZeppelin
    struct EnumerableSet {
        uint256[] _values;
        mapping(uint256 => uint256) _indexes;
    }

    EnumerableSet private _set;

    // Events
    event CounterIncremented(uint256 value);
    event CounterDecremented(uint256 value);
    event CounterReset();

    // Constructor
    constructor() {
        _counter = 0;
    }

    // Increment the counter
    function increment() public {
        _counter += 1;
        emit CounterIncremented(_counter);
    }

    // Decrement the counter
    function decrement() public {
        require(_counter > 0, "Counter: counter underflow");
        _counter -= 1;
        emit CounterDecremented(_counter);
    }

    // Reset the counter
    function reset() public {
        _counter = 0;
        emit CounterReset();
    }

    // Get the current counter value
    function counter() public view returns (uint256) {
        return _counter;
    }

    // Add a value to the set
    function addToSet(uint256 value) public returns (bool) {
        if (!_set._indexes[value] > 0) {
            _set._values.push(value);
            _set._indexes[value] = _set._values.length;
            return true;
        } else {
            return false;
        }
    }

    // Remove a value from the set
    function removeFromSet(uint256 value) public returns (bool) {
        uint256 valueIndex = _set._indexes[value];
        if (valueIndex > 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = _set._values.length - 1;
            uint256 lastValue = _set._values[lastIndex];
            _set._values[toDeleteIndex] = lastValue;
            _set._indexes[lastValue] = valueIndex;
            _set._values.pop();
            delete _set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    // Check if a value is in the set
    function containsInSet(uint256 value) public view returns (bool) {
        return _set._indexes[value] > 0;
    }

    // Get the number of unique values in the set
    function setLength() public view returns (uint256) {
        return _set._values.length;
    }

    // Get the value at a specific index in the set
    function atInSet(uint256 index) public view returns (uint256) {
        require(index < _set._values.length, "EnumerableSet: index out of bounds");
        return _set._values[index];
    }
}