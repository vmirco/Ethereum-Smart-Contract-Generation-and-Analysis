// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Upgradeable {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IStakingThales {
    function stake(uint256 amount) external;
    function unstake(uint256 amount) external;
}

contract SportsAMM {
    struct Bet {
        uint256 id;
        address creator;
        address collateralToken;
        uint256 amount;
        uint256 odds;
        bool settled;
        bool outcome;
    }

    Bet[] public bets;
    mapping(uint256 => address) public betToCreator;
    mapping(address => uint256[]) public creatorToBets;
    mapping(address => uint256) public userBalances;

    IERC20Upgradeable public collateralToken;
    IStakingThales public stakingContract;

    event BetCreated(uint256 betId, address creator, address collateralToken, uint256 amount, uint256 odds);
    event BetSettled(uint256 betId, bool outcome);

    constructor(address _collateralToken, address _stakingContract) {
        collateralToken = IERC20Upgradeable(_collateralToken);
        stakingContract = IStakingThales(_stakingContract);
    }

    function createBet(address _collateralToken, uint256 _amount, uint256 _odds) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_odds > 0, "Odds must be greater than 0");

        IERC20Upgradeable(_collateralToken).transferFrom(msg.sender, address(this), _amount);

        Bet memory newBet = Bet({
            id: bets.length,
            creator: msg.sender,
            collateralToken: _collateralToken,
            amount: _amount,
            odds: _odds,
            settled: false,
            outcome: false
        });

        bets.push(newBet);
        betToCreator[newBet.id] = msg.sender;
        creatorToBets[msg.sender].push(newBet.id);

        emit BetCreated(newBet.id, msg.sender, _collateralToken, _amount, _odds);
    }

    function settleBet(uint256 _betId, bool _outcome) external {
        Bet storage bet = bets[_betId];
        require(!bet.settled, "Bet already settled");

        bet.settled = true;
        bet.outcome = _outcome;

        if (_outcome) {
            uint256 winnings = bet.amount * bet.odds;
            IERC20Upgradeable(bet.collateralToken).transfer(bet.creator, winnings);
        } else {
            IERC20Upgradeable(bet.collateralToken).transfer(address(this), bet.amount);
        }

        emit BetSettled(_betId, _outcome);
    }

    function withdraw(address _token, uint256 _amount) external {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        userBalances[msg.sender] -= _amount;
        IERC20Upgradeable(_token).transfer(msg.sender, _amount);
    }

    function stake(uint256 _amount) external {
        collateralToken.transferFrom(msg.sender, address(this), _amount);
        stakingContract.stake(_amount);
    }

    function unstake(uint256 _amount) external {
        stakingContract.unstake(_amount);
        collateralToken.transfer(msg.sender, _amount);
    }
}