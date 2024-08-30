// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeesAndReservesAdaptor {
    struct FeesAndReserves {
        // example var, replace with your own
        uint256 variable; 
    }

    function feesAndReserves() public virtual view returns (FeesAndReserves memory) {
        // sample data, replace with your own logic
        FeesAndReserves memory data = FeesAndReserves({variable: 1});
        return data;
    }
}

contract MyContract is FeesAndReservesAdaptor {
    uint256 constant MY_FEE = 5; 
    uint256 constant MY_RESERVE = 7;

    function feesAndReserves() public override view returns (FeesAndReserves memory) {
        FeesAndReserves memory data = FeesAndReserves({variable: MY_FEE + MY_RESERVE});
        return data;
    }
}