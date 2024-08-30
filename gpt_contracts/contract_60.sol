pragma solidity ^0.8.0;
    
contract Betting {
    
    struct Bet{
        address user;
        uint256 amount;
        bool won;
    }

    mapping(address => Bet[]) public betHistory;
    mapping(address => uint256) public balances;

    uint256 public constant BET_LIMIT = 10 ether;
    uint256 public constant WITHDRAW_LIMIT = 5 ether;

    event Deposit(address indexed user, uint256 amount);
    event BetPlaced(address indexed user, uint256 amount);
    event BetResult(address indexed user, uint256 amount, bool won);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be more than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function placeBet(uint256 betAmount) public {
        require(betAmount > 0, "Bet must be more than 0");
        require(betAmount <= BET_LIMIT, "Bet amount exceeds limit");
        require(balances[msg.sender] >= betAmount, "Insufficient funds");

        balances[msg.sender] -= betAmount;

        bool won = (block.number % 2 == 0);
        if(won){
            balances[msg.sender] += betAmount * 2;
        }

        Bet memory newBet;
        newBet.user = msg.sender;
        newBet.amount = betAmount;
        newBet.won = won;
        betHistory[msg.sender].push(newBet);

        emit BetPlaced(msg.sender, betAmount);
        emit BetResult(msg.sender, betAmount, won);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal must be more than 0");
        require(amount <= WITHDRAW_LIMIT, "Withdrawal amount exceeds limit");
        require(balances[msg.sender] >= amount, "Insufficient funds");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getBetHistory(address user) public view returns (Bet[] memory){
        return betHistory[user];
    }
}