// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";

contract TokenAllocation is ERC20Burnable, Ownable, Pausable {
    address public treasury;
    address public devFund;

    uint256 public treasuryPercent;
    uint256 public devFundPercent;

    uint256 public rewardRate;
    uint256 public rewardInterval = 86400; // 1 day in seconds

    uint256 public lastRewardTimestamp;

    mapping(address => uint256) public lastClaim;

    event RewardClaimed(address indexed user, uint256 amount);
    event TreasurySet(address indexed newTreasury);
    event DevFundSet(address indexed newDevFund);

    constructor(
        string memory name,
        string memory symbol,
        address _treasury,
        uint256 _treasuryPercent,
        address _devFund,
        uint256 _devFundPercent,
        uint256 _rewardRate
    ) ERC20(name, symbol) {
        require(_treasuryPercent <= 100, "Invalid treasury percent");
        require(_devFundPercent <= 100, "Invalid dev fund percent");
        require((_treasuryPercent + _devFundPercent) <= 100, "Total percent more than 100");

        treasury = _treasury;
        treasuryPercent = _treasuryPercent;

        devFund = _devFund;
        devFundPercent = _devFundPercent;

        rewardRate = _rewardRate;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        lastRewardTimestamp = block.timestamp;
    }

    function setTreasury(address _treasury, uint256 _percent) external onlyOwner {
        require(_percent <= 100, "Invalid percent");
        require((_percent + devFundPercent) <= 100, "Total percent more than 100");

        treasury = _treasury;
        treasuryPercent = _percent;

        emit TreasurySet(_treasury);
    }

    function setDevFund(address _devFund, uint256 _percent) external onlyOwner {
        require(_percent <= 100, "Invalid percent");
        require((_percent + treasuryPercent) <= 100, "Total percent more than 100");

        devFund = _devFund;
        devFundPercent = _percent;

        emit DevFundSet(_devFund);
    }

    function distributeIncentives(uint256 amount) external onlyOwner {
        uint256 incentive = amount - (getTreasuryCut(amount) + getDevFundCut(amount));
        _mint(msg.sender, incentive);
    }

    function getTreasuryCut(uint256 amount) public view returns(uint256) {
        return (amount * treasuryPercent) / 100;
    }

    function getDevFundCut(uint256 amount) public view returns(uint256) {
        return (amount * devFundPercent) / 100;
    }

    function claimReward() external {
        require(block.timestamp >= lastClaim[msg.sender] + rewardInterval, "Too Early To Claim Reward");
        uint256 rewardAmount = balanceOf(msg.sender) * rewardRate / 100;

        _mint(msg.sender, rewardAmount);

        lastClaim[msg.sender] = block.timestamp;

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }
}