// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IAccounting {
    function collateralize() external;
    function withdraw(uint256 amount) external;
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

interface IHedgingReactor {
    function deltaHedge() external;
}

contract HedgingContract is Pausable {
    IAccounting public accounting;
    AggregatorV3Interface public priceFeed;
    IHedgingReactor public hedgingReactor;

    event Collateralized(uint256 amount);
    event Withdrawn(uint256 amount);
    event Hedged();

    constructor(address _accounting, address _priceFeed, address _hedgingReactor) {
        accounting = IAccounting(_accounting);
        priceFeed = AggregatorV3Interface(_priceFeed);
        hedgingReactor = IHedgingReactor(_hedgingReactor);
    }

    function pause() public whenNotPaused {
        _pause();
    }

    function unpause() public whenPaused {
        _unpause();
    }

    function collateralize() public whenNotPaused {
        accounting.collateralize();
        emit Collateralized(1); // Assuming collateralize function does not return amount
    }

    function withdraw(uint256 amount) public whenNotPaused {
        accounting.withdraw(amount);
        emit Withdrawn(amount);
    }

    function deltaHedge() public whenNotPaused {
        hedgingReactor.deltaHedge();
        emit Hedged();
    }

    function getLatestPrice() public view returns (int256) {
        (
            uint80 roundID, 
            int256 price, 
            uint256 startedAt, 
            uint256 timeStamp, 
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}