// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ValueSet {
    struct Set {
        uint256[] values;
        mapping(uint256 => uint256) valueToIndex;
        mapping(uint256 => bool) isValueInSet;
    }

    Set private valueSet;

    function addValue(uint256 _value) public {
        require(!valueSet.isValueInSet[_value], "Value already in set");
        valueSet.values.push(_value);
        valueSet.valueToIndex[_value] = valueSet.values.length - 1;
        valueSet.isValueInSet[_value] = true;
    }

    function removeValue(uint256 _value) public {
        require(valueSet.isValueInSet[_value], "Value not in set");
        uint256 indexToRemove = valueSet.valueToIndex[_value];
        uint256 lastIndex = valueSet.values.length - 1;
        uint256 lastValue = valueSet.values[lastIndex];

        // Swap the value to remove with the last value and update the index
        valueSet.values[indexToRemove] = lastValue;
        valueSet.valueToIndex[lastValue] = indexToRemove;

        // Remove the last element
        valueSet.values.pop();
        valueSet.isValueInSet[_value] = false;
    }

    function containsValue(uint256 _value) public view returns (bool) {
        return valueSet.isValueInSet[_value];
    }

    function getValueAtIndex(uint256 _index) public view returns (uint256) {
        require(_index < valueSet.values.length, "Index out of bounds");
        return valueSet.values[_index];
    }

    function getSetLength() public view returns (uint256) {
        return valueSet.values.length;
    }

    function getAllValues() public view returns (uint256[] memory) {
        return valueSet.values;
    }
}