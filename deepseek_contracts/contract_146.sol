// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFKeyStaking {
    address public nfKeyAddress;
    address public owner;

    struct Staker {
        uint256 tokenId;
        uint256 tokenIndex;
        uint256 rewardsEarned;
        uint256 rewardsReleased;
    }

    mapping(address => bool) public admins;
    mapping(address => Staker[]) public stakers;
    mapping(uint256 => uint256) public treasureUnlockTimes;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardsUpdated(address indexed user, uint256 rewardsEarned);
    event TreasureUnlockTimeUpdated(uint256 tokenId, uint256 unlockTime);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Not an admin");
        _;
    }

    constructor(address _nfKeyAddress) {
        nfKeyAddress = _nfKeyAddress;
        owner = msg.sender;
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

    function stake(uint256 _tokenId) external {
        stakers[msg.sender].push(Staker({
            tokenId: _tokenId,
            tokenIndex: stakers[msg.sender].length,
            rewardsEarned: 0,
            rewardsReleased: 0
        }));
        emit Staked(msg.sender, _tokenId);
    }

    function unstake(uint256 _tokenIndex) external {
        Staker[] storage userStakes = stakers[msg.sender];
        require(_tokenIndex < userStakes.length, "Invalid token index");
        uint256 tokenId = userStakes[_tokenIndex].tokenId;
        userStakes[_tokenIndex] = userStakes[userStakes.length - 1];
        userStakes.pop();
        emit Unstaked(msg.sender, tokenId);
    }

    function updateRewards(address _user, uint256 _rewardsEarned) external onlyAdmin {
        Staker[] storage userStakes = stakers[_user];
        for (uint256 i = 0; i < userStakes.length; i++) {
            userStakes[i].rewardsEarned += _rewardsEarned;
        }
        emit RewardsUpdated(_user, _rewardsEarned);
    }

    function updateTreasureUnlockTime(uint256 _tokenId, uint256 _unlockTime) external onlyAdmin {
        treasureUnlockTimes[_tokenId] = _unlockTime;
        emit TreasureUnlockTimeUpdated(_tokenId, _unlockTime);
    }

    function getStakedTokens(address _user) external view returns (uint256[] memory) {
        Staker[] storage userStakes = stakers[_user];
        uint256[] memory tokenIds = new uint256[](userStakes.length);
        for (uint256 i = 0; i < userStakes.length; i++) {
            tokenIds[i] = userStakes[i].tokenId;
        }
        return tokenIds;
    }

    function getRewardsCount(address _user) external view returns (uint256) {
        Staker[] storage userStakes = stakers[_user];
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < userStakes.length; i++) {
            totalRewards += userStakes[i].rewardsEarned;
        }
        return totalRewards;
    }

    function getTreasureUnlockTime(uint256 _tokenId) external view returns (uint256) {
        return treasureUnlockTimes[_tokenId];
    }
}