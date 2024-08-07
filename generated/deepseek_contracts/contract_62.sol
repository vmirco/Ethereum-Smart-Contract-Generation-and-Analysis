// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _counter;
    mapping(uint256 => uint256) private _values;
    EnumerableSet.UintSet private _keys;

    function increment() public {
        _counter = _counter.add(1);
    }

    function decrement() public {
        _counter = _counter.sub(1);
    }

    function reset() public {
        _counter = 0;
    }

    function setValue(uint256 key, uint256 value) public {
        _values[key] = value;
        _keys.add(key);
    }

    function getValue(uint256 key) public view returns (uint256) {
        require(_keys.contains(key), "Key not found");
        return _values[key];
    }

    function getCounter() public view returns (uint256) {
        return _counter;
    }

    function getKeys() public view returns (uint256[] memory) {
        return _keys.values();
    }
}

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

library EnumerableSet {
    struct UintSet {
        uint256[] _values;
        mapping(uint256 => uint256) _indexes;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            uint256 lastValue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastValue;
            set._indexes[lastValue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        return set._values;
    }
}