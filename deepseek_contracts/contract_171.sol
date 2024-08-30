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

    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IAccounting {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

interface IHedgingReactor {
    function hedgeDelta(int256 delta) external;
    function withdraw(uint256 amount) external;
}

contract DeltaHedgingContract is Pausable {
    IAccounting public accounting;
    AggregatorV3Interface public priceFeed;
    IHedgingReactor public hedgingReactor;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event DeltaHedged(int256 delta);

    constructor(address _accounting, address _priceFeed, address _hedgingReactor) {
        accounting = IAccounting(_accounting);
        priceFeed = AggregatorV3Interface(_priceFeed);
        hedgingReactor = IHedgingReactor(_hedgingReactor);
    }

    function deposit() external payable whenNotPaused {
        accounting.deposit{value: msg.value}();
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused {
        accounting.withdraw(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function hedgeDelta() external whenNotPaused {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        int256 delta = calculateDelta(price);
        hedgingReactor.hedgeDelta(delta);
        emit DeltaHedged(delta);
    }

    function calculateDelta(int256 price) internal pure returns (int256) {
        // Placeholder for actual delta calculation logic
        return price / 100;
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }
}