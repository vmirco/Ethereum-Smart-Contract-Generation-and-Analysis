// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract GMTokenUnwrapper {
    IERC20 public gmToken;
    bool public unwrapEnabled;
    uint256 public unwrapInterval;

    mapping(address => uint256) public lastUnwrapTime;

    event Unwrap(address indexed user, uint256 amount);
    event UnwrapEnabled(bool enabled);
    event GMTokenAddressChanged(address newAddress);

    modifier onlyWhenUnwrapEnabled() {
        require(unwrapEnabled, "Unwrapping is not enabled");
        _;
    }

    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    bool private _locked;

    constructor(address _gmTokenAddress, uint256 _unwrapInterval) {
        gmToken = IERC20(_gmTokenAddress);
        unwrapInterval = _unwrapInterval;
        unwrapEnabled = true;
    }

    function setUnwrapEnabled(bool _enabled) external {
        unwrapEnabled = _enabled;
        emit UnwrapEnabled(_enabled);
    }

    function changeGMTokenAddress(address _newAddress) external {
        gmToken = IERC20(_newAddress);
        emit GMTokenAddressChanged(_newAddress);
    }

    function unwrap(uint256 amount) external onlyWhenUnwrapEnabled nonReentrant {
        require(block.timestamp >= lastUnwrapTime[msg.sender] + unwrapInterval, "Unwrap interval not passed");
        require(gmToken.balanceOf(msg.sender) >= amount, "Insufficient GM tokens");

        lastUnwrapTime[msg.sender] = block.timestamp;
        gmToken.transfer(msg.sender, amount);

        emit Unwrap(msg.sender, amount);
    }

    function calculateMaxUnwrapAmount(address user) public view returns (uint256) {
        if (block.timestamp < lastUnwrapTime[user] + unwrapInterval) {
            return 0;
        }
        return gmToken.balanceOf(user);
    }
}