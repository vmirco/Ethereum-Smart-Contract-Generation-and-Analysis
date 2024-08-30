// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Pausable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function pause() public virtual {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public virtual {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
}

interface IAccounting {
    function transferToContract(address asset, uint256 amount) external;
    function transferFromContract(address asset, uint256 amount) external;
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint256, int256, uint256, uint256, uint80);
}

interface IHedgingReactor {
    function deltaHedge() external;
}

contract hedgingContract is Pausable {
    IAccounting public accounting;
    AggregatorV3Interface public priceFeed;
    IHedgingReactor public hedgingReactor;
  
    event DeltaHedged(address indexed _sender);
    event AssetWithdrawn(address indexed _receiver, uint256 _amount);
    event AssetReceived(address indexed _sender, uint256 _amount);

    constructor(address _accounting, address _priceFeed, address _hedgingReactor) {
        accounting = IAccounting(_accounting);
        priceFeed = AggregatorV3Interface(_priceFeed);
        hedgingReactor = IHedgingReactor(_hedgingReactor);
    }
    
    function receiveAsset(address asset, uint256 amount) external whenNotPaused {
        accounting.transferToContract(asset, amount);
        emit AssetReceived(msg.sender, amount);
    }

    function withdrawAsset(address asset, uint256 amount) external whenPaused {
        accounting.transferFromContract(asset, amount);
        emit AssetWithdrawn(msg.sender, amount);
    }

    function deltaHedge() external whenNotPaused {
        hedgingReactor.deltaHedge();
        emit DeltaHedged(msg.sender);
    }
}