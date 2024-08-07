// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NFKeyStaking {
    struct Staker {
        uint256 tokenId;
        uint256 tokenIndex;
        uint256 rewardsEarned;
        uint256 rewardsReleased;
    }

    IERC721 public nfKey;
    address public admin;
    mapping(address => bool) public admins;
    mapping(address => Staker[]) public stakers;
    mapping(uint256 => uint256) public tokenIndexToStaker;
    uint256 public totalStaked;
    uint256 public rewardPerToken;
    uint256 public lastUpdateTime;
    uint256 public rewardRate;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardsPaid(address indexed user, uint256 reward);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    constructor(address _nfKey) {
        nfKey = IERC721(_nfKey);
        admin = msg.sender;
        admins[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyAdmin {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyAdmin {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function stake(uint256 tokenId) external {
        require(nfKey.ownerOf(tokenId) == msg.sender, "Not the owner");
        nfKey.transferFrom(msg.sender, address(this), tokenId);
        Staker memory newStaker = Staker({
            tokenId: tokenId,
            tokenIndex: stakers[msg.sender].length,
            rewardsEarned: 0,
            rewardsReleased: 0
        });
        stakers[msg.sender].push(newStaker);
        tokenIndexToStaker[tokenId] = stakers[msg.sender].length - 1;
        totalStaked++;
        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        uint256 index = tokenIndexToStaker[tokenId];
        require(stakers[msg.sender][index].tokenId == tokenId, "Token not staked by user");
        Staker storage staker = stakers[msg.sender][index];
        staker.rewardsEarned = earned(msg.sender);
        staker.rewardsReleased += staker.rewardsEarned;
        nfKey.transferFrom(address(this), msg.sender, tokenId);
        _removeStaker(msg.sender, index);
        totalStaked--;
        emit Unstaked(msg.sender, tokenId);
        emit RewardsPaid(msg.sender, staker.rewardsEarned);
    }

    function earned(address account) public view returns (uint256) {
        uint256 earnedRewards = 0;
        for (uint256 i = 0; i < stakers[account].length; i++) {
            Staker storage staker = stakers[account][i];
            earnedRewards += (block.timestamp - staker.rewardsReleased) * rewardRate;
        }
        return earnedRewards;
    }

    function updateRewardRate(uint256 newRate) external onlyAdmin {
        rewardRate = newRate;
    }

    function getStakedTokens(address account) external view returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](stakers[account].length);
        for (uint256 i = 0; i < stakers[account].length; i++) {
            tokens[i] = stakers[account][i].tokenId;
        }
        return tokens;
    }

    function getRewardsCount(address account) external view returns (uint256) {
        return earned(account);
    }

    function getTreasureUnlockTimes(address account) external view returns (uint256[] memory) {
        uint256[] memory unlockTimes = new uint256[](stakers[account].length);
        for (uint256 i = 0; i < stakers[account].length; i++) {
            unlockTimes[i] = stakers[account][i].rewardsReleased;
        }
        return unlockTimes;
    }

    function _removeStaker(address account, uint256 index) internal {
        stakers[account][index] = stakers[account][stakers[account].length - 1];
        stakers[account].pop();
    }
}