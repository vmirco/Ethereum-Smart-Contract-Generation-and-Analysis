// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeesAndReservesAdaptor {
    function feesAndReserves() public virtual returns (FeesAndReserves memory) {}
}

struct FeesAndReserves {
    uint256 fee;
    uint256 reserve;
}

contract MyFeesAndReserves is FeesAndReservesAdaptor {
    FeesAndReserves private myFeesAndReserves;

    constructor(uint256 _fee, uint256 _reserve) {
        myFeesAndReserves = FeesAndReserves({
            fee: _fee,
            reserve: _reserve
        });
    }

    function feesAndReserves() public override view returns (FeesAndReserves memory) {
        return myFeesAndReserves;
    }
}