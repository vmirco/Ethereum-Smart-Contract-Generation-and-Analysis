pragma solidity ^0.8.0;

contract Referral {
    struct User {
        bool isRegistered;
        address referrer;
        uint balance;
    }

    mapping(address => User) public users;
    event Registered(address indexed user, address indexed referrer);
    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    
    function register(address referrer) public {
        require(!users[msg.sender].isRegistered, "User is already registered.");
        require(users[referrer].isRegistered || referrer == address(0), "Referrer not exists.");
        
        users[msg.sender] = User({
            isRegistered: true,
            referrer: referrer,
            balance: 0
        });

        emit Registered(msg.sender, referrer);
    }
    
    function deposit() public payable {
        require(users[msg.sender].isRegistered, "User is not registered.");

        users[msg.sender].balance += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(users[msg.sender].balance >= amount, "Insufficient balance.");

        users[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}