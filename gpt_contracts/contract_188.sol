pragma solidity ^0.8.0;

contract InvestorContract {
  
  using SafeMath for uint;

  struct User {
    uint id;
    uint deposit;
    uint withdrawal;
    uint totalDeposit;
    uint referralCount;
  }

  mapping(address => User) public users;
  mapping(uint => address) public userIds;
  uint public lastUserId = 2;

  event Deposit(address indexed user, uint256 amount);
  event Withdrawal(address indexed user, uint256 amount);
  event BonusPayment(address indexed user, uint256 amount);

  constructor() {
    User storage user = users[msg.sender];
    user.id = 1;
    user.deposit = 0;
    user.withdrawal = 0;
    user.totalDeposit = 0;
    user.referralCount = 0;
  }

  function deposit() public payable {
    require(msg.value > 0);

    User storage user = users[msg.sender];
    user.deposit = msg.value;
    user.totalDeposit = user.totalDeposit.add(msg.value);

    emit Deposit(msg.sender, msg.value);
  }

  function calculateContractBalanceRate() public view returns(uint) {
    // It should be changed according to the actual calculation rules.
    // This is a simple example.
    return address(this).balance;
  }

  function calculateLeaderBonusRate(uint deposit) public view returns(uint) {
    // It should be changed according to the actual calculation rules.
    // This is a simple example.
    return deposit.div(10);
  }

  function calculateCommunityBonusRate(uint deposit) public view returns(uint) {
    // It should be changed according to the actual calculation rules.
    // This is a simple example.
    return deposit.div(20);
  }

  function withdraw(uint amount) public {
    User storage user = users[msg.sender];

    require(amount <= user.deposit, "Insufficient balance");

    user.deposit = user.deposit.sub(amount);
    user.withdrawal = user.withdrawal.add(amount);

    emit Withdrawal(msg.sender, amount);

    payable(msg.sender).transfer(amount);
  }

  function getBonus(uint amount) public {
    User storage user = users[msg.sender];

    user.deposit = user.deposit.add(amount);

    emit BonusPayment(msg.sender, amount);
  }
}

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint c = a - b;

    return c;
  }

  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }

    uint c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0, "SafeMath: division by zero");
    uint c = a / b;

    return c;
  }

  function mod(uint a, uint b) internal pure returns (uint) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}