// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SetManager {
    struct Set {
        bytes32[] values;
        mapping(bytes32 => bool) isMember;
    }

    mapping(address => Set) private sets;

    function add(bytes32 value) public {
        Set storage set = sets[msg.sender];
        if (!set.isMember[value]) {
            set.values.push(value);
            set.isMember[value] = true;
        }
    }

    function remove(bytes32 value) public {
        Set storage set = sets[msg.sender];
        if (set.isMember[value]) {
            for (uint256 i = 0; i < set.values.length; i++) {
                if (set.values[i] == value) {
                    set.values[i] = set.values[set.values.length - 1];
                    set.values.pop();
                    set.isMember[value] = false;
                    break;
                }
            }
        }
    }

    function isMember(bytes32 value) public view returns (bool) {
        return sets[msg.sender].isMember[value];
    }

    function getLength() public view returns (uint256) {
        return sets[msg.sender].values.length;
    }

    function getValues() public view returns (bytes32[] memory) {
        return sets[msg.sender].values;
    }

    function insertSorted(bytes32 value) public {
        Set storage set = sets[msg.sender];
        if (!set.isMember[value]) {
            uint256 i = 0;
            while (i < set.values.length && set.values[i] < value) {
                i++;
            }
            set.values.push(bytes32(0)); // Temporary placeholder
            for (uint256 j = set.values.length - 1; j > i; j--) {
                set.values[j] = set.values[j - 1];
            }
            set.values[i] = value;
            set.isMember[value] = true;
        }
    }
}