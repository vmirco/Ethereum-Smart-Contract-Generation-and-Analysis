pragma solidity ^0.8.0;

contract Set {
    struct set {
        mapping(bytes32 => uint) index;
        bytes32[] values;
    }
    
    set private mySet;
    
    function insert(bytes32 value) public returns (bool success) {
        if (isInSet(value)) {
            return false;
        } else {
            mySet.values.push(value);
            mySet.index[value] = mySet.values.length;
            return true;
        }
    }
    
    function remove(bytes32 value) public returns (bool success) {
        if (isInSet(value)) {
            mySet.values[mySet.index[value]-1] = mySet.values[mySet.values.length-1];
            mySet.values.pop();
            delete mySet.index[value];
            return true;
        } else {
            return false;
        }
    }
    
    function isInSet(bytes32 value) public view returns (bool success) {
        if (mySet.index[value] > 0) {
            return true;
        } else {
            return false;
        }
    }
    
    function length() public view returns (uint setLength) {
        return mySet.values.length;
    }
    
    function getValueAt(uint index) public view returns (bytes32 value) {
        return mySet.values[index];
    }
    
    function sort() public {
        uint length = mySet.values.length;
        for(uint i = 0; i < length; i++) {
            for(uint j = 0; j < length-i-1; j++) {
                if(uint(mySet.values[j]) > uint(mySet.values[j+1])) {
                    bytes32 temp = mySet.values[j];
                    mySet.values[j] = mySet.values[j+1];
                    mySet.values[j+1] = temp;
                }
            }
        }
    }
}