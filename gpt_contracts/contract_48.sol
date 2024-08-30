// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IERC20 is a contract interface for ERC20 standard
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Rewards contract
contract StakingRewards {

    // Token details
    struct Token {
        IERC20 token;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    // Reward Details
    struct Reward {
        uint256 userRewardPerTokenPaid;
        uint256 rewards;
    }

    // Staked tokens by users
    mapping (address => mapping (IERC20 => uint256)) public userStakes;

    // Rewards by tokens and users
    mapping (IERC20 => mapping (address => Reward)) public userRewards;

    // Mapping of token addresses to their details
    mapping(IERC20 => Token) public tokens;

    //Reward tokens
    IERC20 rewardToken;

    // Total stakes of a token
    mapping(IERC20 => uint256) public totalStakes;

    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
    }

    // Add a new token to track
    function addToken(IERC20 _token, uint256 _rewardRate) public {
        require(address(_token) != address(0), "zero address");
        Token storage token = tokens[_token];
        require(address(token.token) == address(0), "token already added");

        tokens[_token] = Token({
            token: _token,
            rewardRate: _rewardRate,
            lastUpdateTime: block.timestamp,
            rewardPerTokenStored: 0
        });
    }

    // Return earned rewards of a user for a specific token
    function earned(IERC20 _token, address _account) public view returns (uint256) {
        Token storage token = tokens[_token];
        uint256 rewardPerToken = rewardPerToken(_token);
        uint256 stake = userStakes[_account][_token];
        Reward storage reward = userRewards[_token][_account];
        return (stake * (rewardPerToken-reward.userRewardPerTokenPaid)/1e18) + reward.rewards;
    }

    // Return reward per token for a specific token
    function rewardPerToken(IERC20 _token) public view returns (uint256) {
        Token storage token = tokens[_token];
        if (totalStakes[_token] == 0) {
            return token.rewardPerTokenStored;
        }
        return token.rewardPerTokenStored + ((block.timestamp - token.lastUpdateTime) * token.rewardRate * 1e18 / totalStakes[_token]);
    }

    // Stake a certain "_amount" of a specific "_token"
    function stake(IERC20 _token, uint256 _amount) public {
        updateReward(_token, msg.sender);  // Update user reward
        totalStakes[_token] += _amount;
        userStakes[msg.sender][_token] += _amount;
        require(_token.transferFrom(msg.sender, address(this), _amount), "transfer failed");  // Transfer tokens to this contract
    }

    // Withdraw a certain "_amount" of a specific "_token"
    function withdraw(IERC20 _token, uint256 _amount) public {
        updateReward(_token, msg.sender);  // Update user reward
        totalStakes[_token] -= _amount;
        userStakes[msg.sender][_token] -= _amount;
        require(_token.transfer(msg.sender, _amount), "transfer failed");  // Transfer tokens back to user
    }

    // Claim rewards of a specific token
    function getReward(IERC20 _token) public {
        updateReward(_token, msg.sender); // Update user reward
        uint256 reward = userRewards[_token][msg.sender].rewards;
        if (reward > 0) {
            userRewards[_token][msg.sender].rewards = 0;
            require(rewardToken.transfer(msg.sender, reward), "transfer failed");  // Transfer reward tokens to user
        }
    }

    // Update reward for a specific token and user
    function updateReward(IERC20 _token, address _account) internal {
        Token storage token = tokens[_token];
        token.rewardPerTokenStored = rewardPerToken(_token);
        token.lastUpdateTime = block.timestamp;
        if (_account != address(0)) {
            userRewards[_token][_account].rewards = earned(_token, _account);
            userRewards[_token][_account].userRewardPerTokenPaid = token.rewardPerTokenStored;
        }
    }
}