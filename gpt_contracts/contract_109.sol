// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Epoch {
    uint256 public epochPrice;
}

contract CoverPool {
    mapping(address => uint256) public providers;
    uint256 public cumulativeProfit;
    uint256 public totalShare;
    uint256 public unwithdrawnCoverTokens;
    Epoch public currentEpoch;

    event NewEpoch(address epoch, uint256 price);
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 share);
    event Claim(address indexed from, uint256 profit);

    function startNewEpoch(uint256 price) external {
        Epoch newEpoch = new Epoch();
        newEpoch.epochPrice = price;
        currentEpoch = newEpoch;
        emit NewEpoch(address(newEpoch), price);
    }

    function deposit(uint256 amount) external {
        providers[msg.sender] += amount;
        totalShare += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 share) external {
        require(providers[msg.sender] >= share, "Not enough shares to withdraw");
        providers[msg.sender] -= share;
        totalShare -= share;
        emit Withdraw(msg.sender, share);
    }

    function claim() external {
        uint256 share = providers[msg.sender];
        require(share > 0, "No shares to claim");
        uint256 profit = (cumulativeProfit * share) / totalShare;
        require(profit <= unwithdrawnCoverTokens, "Not enough unwithdrawn tokens");
        unwithdrawnCoverTokens -= profit;
        cumulativeProfit -= profit;
        providers[msg.sender] -= share;
        totalShare -= share;
        emit Claim(msg.sender, profit);
    }
}