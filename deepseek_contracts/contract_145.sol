// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IStakingThales {
    function stake(uint amount) external;
    function unstake(uint amount) external;
    function getStakedAmount(address account) external view returns (uint);
}

contract SportsAMM {
    struct Bet {
        address creator;
        address collateralToken;
        uint256 amount;
        uint256 outcome;
        bool settled;
    }

    mapping(uint256 => Bet) public bets;
    mapping(address => uint256) public userBalances;
    uint256 public betCounter;

    function createBet(address _collateralToken, uint256 _amount, uint256 _outcome) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(IERC20Upgradeable(_collateralToken).transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        bets[betCounter] = Bet({
            creator: msg.sender,
            collateralToken: _collateralToken,
            amount: _amount,
            outcome: _outcome,
            settled: false
        });

        betCounter++;
    }

    function settleBet(uint256 _betId, uint256 _result) external {
        Bet storage bet = bets[_betId];
        require(!bet.settled, "Bet already settled");
        require(bet.creator != address(0), "Bet does not exist");

        if (bet.outcome == _result) {
            userBalances[bet.creator] += bet.amount;
        }

        bet.settled = true;
    }

    function withdraw(address _collateralToken, uint256 _amount) external {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        require(IERC20Upgradeable(_collateralToken).transfer(msg.sender, _amount), "Transfer failed");

        userBalances[msg.sender] -= _amount;
    }

    function calculateOdds(uint256 _betId) public view returns (uint256) {
        // Simplified odds calculation
        Bet storage bet = bets[_betId];
        require(bet.creator != address(0), "Bet does not exist");

        // Placeholder logic for odds calculation
        return 2; // 2:1 odds
    }
}