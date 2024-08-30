pragma solidity ^0.8.0;

contract DepositAndInvestmentSystem {
    struct User {
        string name;
        address userAddress;
        uint256 balance;
    }

    mapping(address => User) public users;
    address public owner;

    uint256 public minDeposit;
    uint256 public returnRate;
    event LogDeposit(address indexed user, uint256 amount);
    event LogInvestment(address indexed user, uint256 amount);
    event LogWithdrawal(address indexed user, uint256 amount);
    event LogProductPurchase(address indexed user, address indexed product, uint256 amount);

    constructor(uint256 _minDeposit, uint256 _returnRate) {
        owner = msg.sender;
        minDeposit = _minDeposit;
        returnRate = _returnRate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    modifier isRegistered() {
        require(bytes(users[msg.sender].name).length != 0, "User not registered");
        _;
    }

    modifier hasMinimumBalance() {
        require(users[msg.sender].balance >= minDeposit, "Not enough balance to perform this operation");
        _;
    }

    function registerUser(string memory _name) public {
        require(bytes(_name).length != 0, "Invalid user name");
        require(bytes(users[msg.sender].name).length == 0, "User already registered");

        users[msg.sender] = User({
            name: _name,
            userAddress: msg.sender,
            balance: 0
        });
    }

    function deposit() public payable isRegistered {
        require(msg.value >= minDeposit, "Deposited amount is less than the minimum deposit requirement");

        users[msg.sender].balance += msg.value;

        emit LogDeposit(msg.sender, msg.value);
    }

    function invest(uint256 _amount) public isRegistered hasMinimumBalance {
        require(_amount <= users[msg.sender].balance, "Not enough balance to invest this amount");

        users[msg.sender].balance -= _amount;

        emit LogInvestment(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public isRegistered hasMinimumBalance {
        require(_amount <= users[msg.sender].balance, "Not enough balance to withdraw this amount");

        users[msg.sender].balance -= _amount;

        payable(msg.sender).transfer(_amount);

        emit LogWithdrawal(msg.sender, _amount);
    }

    function purchaseProduct(address _product, uint256 _amount) public isRegistered hasMinimumBalance {
        require(_amount <= users[msg.sender].balance, "Not enough balance to purchase this product");

        users[msg.sender].balance -= _amount;

        emit LogProductPurchase(msg.sender, _product, _amount);
    }

    function setMinDeposit(uint256 _minDeposit) public onlyOwner {
        minDeposit = _minDeposit;
    }

    function setReturnRate(uint256 _returnRate) public onlyOwner {
        returnRate = _returnRate;
    }
}