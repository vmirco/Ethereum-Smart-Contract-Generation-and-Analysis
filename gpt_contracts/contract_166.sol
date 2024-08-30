pragma solidity ^0.8.0;

// Mock token contract to be used in the money market
contract Token {
    mapping(address => uint256) private balances;
    
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balances[sender] >= amount, "Not enough balance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        return true;
    }
}

contract MoneyMarket {
    struct Loan {
        address borrower;
        Token token;
        uint256 amountBorrowed;
        uint256 interest;
        bool isRepaid;
    }

    Loan[] public loans;

    function borrow(Token token, uint256 amountToBorrow) public {
        Loan memory newLoan;
        newLoan.borrower = msg.sender;
        newLoan.token = token;
        newLoan.amountBorrowed = amountToBorrow;
        newLoan.interest = calculateInterest(amountToBorrow);
        newLoan.isRepaid = false;

        loans.push(newLoan);
        token.transferFrom(msg.sender, address(this), amountToBorrow);
    }

    function repay(Loan loan, uint256 amountToRepay) public {
        require(!loan.isRepaid, "Loan already repaid");
        require(amountToRepay >= (loan.amountBorrowed + loan.interest), "Amount is not enough to repay the loan");

        loan.token.transferFrom(msg.sender, address(this), amountToRepay);
        loan.isRepaid = true;
    }

    function liquidate(Loan loan) public {
        require(!loan.isRepaid, "Loan already repaid");

        uint256 amountToLiquidate = loan.amountBorrowed + loan.interest;
        loan.token.transferFrom(address(this), msg.sender, amountToLiquidate);
        loan.isRepaid = true;
    }

    function calculateInterest(uint256 amount) private pure returns (uint256) {
        return (amount * 10) / 100;
    }
}