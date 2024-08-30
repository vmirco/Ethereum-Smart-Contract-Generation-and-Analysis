pragma solidity ^0.8.0;

contract ValueSet {

    struct Set {
        uint256[] list;
        mapping(uint256 => bool) map;
    }
    
    Set private valueSet;

    function addValue(uint256 _value) public {
        require(!valueSet.map[_value], "Value already present in Set");
        valueSet.map[_value] = true;
        valueSet.list.push(_value);
    }

    function removeValue(uint256 _value) public {
        require(valueSet.map[_value], "Value not present in Set");
        for (uint256 i = 0; i < valueSet.list.length; i++) {
            if (valueSet.list[i] == _value) {
                valueSet.list[i] = valueSet.list[valueSet.list.length - 1];
                valueSet.list.pop();
                break;
            }
        }
        valueSet.map[_value] = false;
    }

    function isValuePresent(uint256 _value) public view returns (bool){
        return valueSet.map[_value];
    }

    function getSetSize() public view returns (uint256) {
        return valueSet.list.length;
    }

    function getValueAt(uint256 _index) public view returns (uint256) {
        require(_index < valueSet.list.length, "Index out of bounds");
        return valueSet.list[_index];
    }
}