pragma solidity ^0.8.0;
    
contract DividendBank {
    struct Investor {
        uint balance;
        uint lastDividends;
    }

    mapping(address => Investor) public investors;
    uint public totalInvestors;
    uint public totalInvested;
    uint public totalDividends;
    uint public fees;
        
    event Withdrawn(address indexed user, uint amount);
        
    function deposit() public payable {
        require(msg.value > 0, "Deposit value must be higher than zero");
        
        if (investors[msg.sender].balance == 0) {
            totalInvestors += 1;
        }
        
        investors[msg.sender].balance += msg.value;
        totalInvested += msg.value;
    }
        
    function withdraw(uint amount) public {
        require(investors[msg.sender].balance >= amount, "Insufficient balance.");
        
        investors[msg.sender].balance -= amount;
        totalInvested -= amount;
        
        payable(msg.sender).transfer(amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address receiver, uint amount) public {
        require(investors[msg.sender].balance >= amount, "Insufficient balance.");
        
        investors[msg.sender].balance -= amount;
        investors[receiver].balance += amount;
    }

    function calculateDividends() public {
        uint dividends = address(this).balance - totalInvested - fees;
        
        totalDividends = dividends;

        if (totalInvestors > 0) {
            uint dividendPerInvestor = dividends / totalInvestors;

            for (uint i=0; i<totalInvestors; i++) {
                investors[msg.sender].lastDividends = dividendPerInvestor;
                investors[msg.sender].balance += dividendPerInvestor;
                totalInvested += dividendPerInvestor;
            }
        }
    }

    function balanceOf() public view returns (uint) {
        return investors[msg.sender].balance;
    }
    
    function dividendsOf() public view returns (uint) {
        return investors[msg.sender].lastDividends;
    }
}