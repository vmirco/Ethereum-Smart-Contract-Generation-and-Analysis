pragma solidity ^0.8.0;

contract LiquidityPool {
    
    event Deposit(address indexed sender, uint amount, uint balance, uint totalSupply);
    event Withdrawal(address indexed sender, uint amount, uint balance, uint totalSupply);
    event NewAdmin(address indexed newAdmin);
    
    mapping(address => uint) private balances; // Track user balances
    mapping(address => bool) private admins; // Track admin addresses
    uint private totalSupply; // Total token supply
    
    constructor() {
        admins[msg.sender] = true; // Owner is automatically an admin
    }
    
    // Modifier to allow only admin users to call certain functions
    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admin can perform this action");
        _;
    }
      
    // this function allows admins to add new admins
    function setAdmin(address account) public onlyAdmin {
        admins[account] = true;
        emit NewAdmin(account);
    }
    
    // this function allows users(non-admins) to deposit into the smart contract
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        totalSupply += msg.value;

        emit Deposit(msg.sender, msg.value, balances[msg.sender], totalSupply);
    }
    
    // this function allows users (non-admins) to withdraw from the smart contract
    function withdraw(uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
        
        emit Withdrawal(msg.sender, amount, balances[msg.sender], totalSupply);
    }
    
    // this function allows fetching the balance of a user
    function getBalance(address account) public view returns (uint) {
        return balances[account];
    }
    
    // this function allows fetching the total supply of the tokens
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    // this function allows checking if an account is an admin
    function isAdmin(address account) public view returns (bool) {
        return admins[account];
    }
}