pragma solidity ^0.8.0;

contract Owned {
    address private owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "You are not authorized");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        if(newOwner != address(0)){
            owner = newOwner;
        }
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}

contract Pausable is Owned {
    event Paused();
    event Unpaused();
    bool private paused;
    
    constructor() {
        paused = false;
    }
    
    modifier whenNotPaused {
        require(!paused,"Smart Contract Paused");
        _;
    }

    modifier whenPaused {
        require(paused,"Smart Contract not paused");
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Paused();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpaused();
    }
}

contract AssetTransfer is Pausable {
    mapping(address => uint256) private balances;
    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function deposit() public payable whenNotPaused {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) public whenNotPaused {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    function transfer(address to, uint256 amount) public whenNotPaused {
        require(amount <= balances[msg.sender], "Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
    
    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }
}