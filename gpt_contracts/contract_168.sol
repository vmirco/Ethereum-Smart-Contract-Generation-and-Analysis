pragma solidity ^0.8.0;

contract InvestmentPortfolio{

    struct Investor{
        uint time;
        uint balance;
    }

    uint public interestRate = 5;
    mapping(address => Investor) investors;

    function deposit() public payable {
        require(msg.value > 0, "Invalid amount");

        // If this is the first time the investor has invested, then initialize them
        if(investors[msg.sender].time == 0){
            investors[msg.sender].time = block.timestamp;
        }

        investors[msg.sender].balance += msg.value;
    }
    
    function estimateReturn() public view returns(uint){
        if(investors[msg.sender].time == 0) return 0;

        uint timeElapsed = block.timestamp - investors[msg.sender].time;

        // Assume interest compounds every second. A more realistic scenario would be to compound annually or monthly
        return investors[msg.sender].balance * (1 + interestRate/100)**timeElapsed - investors[msg.sender].balance;
    }

    function withdraw() public {
        uint amount = investors[msg.sender].balance * (1 + interestRate/100)**(block.timestamp - investors[msg.sender].time);
        require(amount <= address(this).balance, "Not enough balance in contract");
        
        investors[msg.sender].time = 0;
        investors[msg.sender].balance = 0;

        payable(msg.sender).transfer(amount);
    }

}