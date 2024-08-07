// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EfficientSet {
    struct Set {
        uint[] values;
        mapping(uint => uint) valueToIndex;
        uint size;
    }

    Set private set;

    function add(uint value) public {
        require(!contains(value), "Value already exists in the set.");
        set.values.push(value);
        set.valueToIndex[value] = set.values.length - 1;
        set.size++;
    }

    function remove(uint value) public {
        require(contains(value), "Value does not exist in the set.");
        uint index = set.valueToIndex[value];
        uint lastValue = set.values[set.values.length - 1];
        set.values[index] = lastValue;
        set.valueToIndex[lastValue] = index;
        set.values.pop();
        delete set.valueToIndex[value];
        set.size--;
    }

    function contains(uint value) public view returns (bool) {
        return set.valueToIndex[value] != 0 || value == set.values[0];
    }

    function length() public view returns (uint) {
        return set.size;
    }

    function getValue(uint index) public view returns (uint) {
        require(index < set.values.length, "Index out of bounds.");
        return set.values[index];
    }
}