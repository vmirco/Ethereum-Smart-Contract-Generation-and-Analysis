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
```

The second piece is `IStakingThales` interface, that handles stakes.

```
interface IStakingThales {
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function stakeForOther(address other, uint256 amount) external;
    function getStakingAmount(address account) external view returns (uint256);
}
```

Now, let's create our main contract.

```
contract SportsAMM {
    IERC20Upgradeable public token;
    IStakingThales public staking;

    struct Bet {
        address bettor;
        uint256 amount;
        bool outcome;
    }

    struct Game {
        string name;
        mapping(bool => Bet[]) bets; // mapping outcome to bets
        bool outcome;
        bool finished;
    }

    uint256 public gameId = 0;
    mapping(uint256 => Game) public games;

    constructor(address _token, address _staking) {
        token = IERC20Upgradeable(_token);
        staking = IStakingThales(_staking);
    }

    function createGame(string memory _name) public {
        games[gameId] = Game(_name, false, false);
        gameId += 1;
    }

    function placeBet(uint256 _gameId, bool _outcome, uint256 _amount) public {
        require(games[_gameId].finished == false, "Game finished");
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

        token.transferFrom(msg.sender, address(this), _amount);
        staking.stakeForOther(msg.sender, _amount);
        
        games[_gameId].bets[_outcome].push(Bet(msg.sender, _amount, _outcome));
    }

    function settleBet(uint256 _gameId, bool _outcome) public {
        require(games[_gameId].finished == false, "Game finished");
        games[_gameId].outcome = _outcome;
        games[_gameId].finished = true;

        for(uint256 i=0; i<games[_gameId].bets[_outcome].length; i++) {
            staking.withdraw(games[_gameId].bets[_outcome][i].amount);
            if(token.balanceOf(address(this)) >= games[_gameId].bets[_outcome][i].amount) {
                token.transfer(games[_gameId].bets[_outcome][i].bettor, games[_gameId].bets[_outcome][i].amount);
            }
        }
    }
}