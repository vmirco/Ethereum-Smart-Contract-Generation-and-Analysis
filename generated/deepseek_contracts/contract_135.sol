// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bytes32Set {
    bytes32[] private items;

    function add(bytes32 item) public {
        if (!exists(item)) {
            items.push(item);
        }
    }

    function remove(bytes32 item) public {
        for (uint i = 0; i < items.length; i++) {
            if (items[i] == item) {
                items[i] = items[items.length - 1];
                items.pop();
                break;
            }
        }
    }

    function exists(bytes32 item) public view returns (bool) {
        for (uint i = 0; i < items.length; i++) {
            if (items[i] == item) {
                return true;
            }
        }
        return false;
    }

    function length() public view returns (uint) {
        return items.length;
    }

    function insert(uint index, bytes32 item) public {
        require(index <= items.length, "Index out of bounds");
        items.push(item);
        for (uint i = items.length - 1; i > index; i--) {
            items[i] = items[i - 1];
        }
        items[index] = item;
    }

    function sort() public {
        quickSort(items, int(0), int(items.length - 1));
    }

    function quickSort(bytes32[] memory arr, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        bytes32 pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }
}