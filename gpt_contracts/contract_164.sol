pragma solidity ^0.8.0;

contract InvestmentContract {
    struct Investor {
        uint256 balance;
        address referral;
        uint256 lastDividendPoints;
    }

    uint256 private totalInvestments;
    uint256 private totalDividendPoints;
    uint256 private unclaimedDividends;

    mapping(address => Investor) public investors;
    address[] public investorIndex;

    event Invest(address indexed investor, uint256 amount);
    event PayDividend(address indexed investor, uint256 dividend);

    modifier onlyInvestor() {
        require(investors[msg.sender].balance > 0, "You are not an investor");
        _;
    }

    function invest(address referral) public payable {
        require(msg.value > 0, "Investment must be greater than 0");
        if(investors[msg.sender].balance == 0) {
            investorIndex.push(msg.sender);
        }
        investors[msg.sender].balance += msg.value;
        totalInvestments += msg.value;
        investors[msg.sender].referral = referral;

        emit Invest(msg.sender, msg.value);
    }

    function disburseDividends() public {
        uint256 unallocatedPoints = totalDividendPoints - unclaimedDividends;
        uint256 totalUnallocated = address(this).balance - totalInvestments;
        uint256 dividendPerInvestment = unallocatedPoints.div(totalUnallocated);
        totalDividendPoints = dividendPerInvestment.mul(totalInvestments);
        unclaimedDividends = totalDividendPoints;
    }

    function withdrawDividend() public onlyInvestor {
        uint256 newDividendPoints = totalDividendPoints - investors[msg.sender].lastDividendPoints;
        uint256 toBePaid = investors[msg.sender].balance.mul(newDividendPoints);

        unclaimedDividends -= toBePaid;
        investors[msg.sender].lastDividendPoints = totalDividendPoints;

        payable(msg.sender).transfer(toBePaid);

        emit PayDividend(msg.sender, toBePaid);
    }

    function balanceOf(address investor) public view returns(uint256) {
        return investors[investor].balance;
    }

    function dividendOf(address investor) public view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints - investors[investor].lastDividendPoints;
        return investors[investor].balance.mul(newDividendPoints);
    }

    function distributeReferralRewards() public readOnly {
        for (uint256 s=0; s<investorIndex.length; s+=1){
            address investorAddress = investorIndex[s];
            payReferral(investorAddress);
        }
    }

    function payReferral(address investor) private {
        address referral = investors[investor].referral;
        if(referral != address(0)) {
            uint256 reward = investors[investor].balance / 10;
            investors[referral].balance += reward;
        }
    }
}