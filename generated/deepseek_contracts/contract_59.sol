// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeesAndReservesAdaptor {
    function feesAndReserves() virtual external view returns (uint, uint) {
        return (0, 0);
    }
}

contract MyFeesAndReservesAdaptor is FeesAndReservesAdaptor {
    struct FeesAndReserves {
        uint fees;
        uint reserves;
    }

    FeesAndReserves private _feesAndReserves;

    constructor(uint fees, uint reserves) {
        _feesAndReserves = FeesAndReserves({
            fees: fees,
            reserves: reserves
        });
    }

    function feesAndReserves() override external view returns (uint, uint) {
        return (_feesAndReserves.fees, _feesAndReserves.reserves);
    }
}