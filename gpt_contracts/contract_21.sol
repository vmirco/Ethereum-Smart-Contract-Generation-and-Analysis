pragma solidity ^0.8.0;

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract Logarithm {
    using SafeMath for uint256;

    uint256 private constant LOG_BASE = 10000;

    function logarithm(uint256 value) public pure returns (uint256) {
        require(value > 0, "Logarithm: invalid input");

        uint256 log;
        while (value >= LOG_BASE) {
            value = value.div(LOG_BASE);
            log = log.add(LOG_BASE);
        }

        for (uint256 i = LOG_BASE.div(2); i > 0; i = i.div(2)) {
            if (value >= LOG_BASE.add(i)) {
                value = value.mul(LOG_BASE).div(LOG_BASE.add(i));
                log = log.add(i);
            }
        }

        return log;
    }
}