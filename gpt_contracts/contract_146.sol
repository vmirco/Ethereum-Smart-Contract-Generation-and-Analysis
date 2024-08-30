// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    
contract NFKeyStaking {
    address public NFKeyAddress;
    mapping(address => bool) public admins;
    
    struct staker {
        uint256 tokenId;
        uint256 tokenIndex;
        uint256 rewardsEarned;
        uint256 rewardsReleased;
        uint256 treasureUnlockTime;
    }

    IERC721 public nft;
    mapping (address => staker) public stakers;
    mapping (uint256 => address) public tokenStakedBy;

    event Emission(address indexed staker, uint256 rewardAmount);
    event ChestTierUpdated(uint256 tokenId, uint256 oldTier, uint256 newTier);
    event TokenStaked(address indexed staker, uint256 tokenId);
    event TokenUnstaked(address indexed staker, uint256 tokenId);

    constructor(address _NFKeyAddress) {
        NFKeyAddress = _NFKeyAddress;
        nft = IERC721(_NFKeyAddress);
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "only admin");
        _;
    }

    function addAdmin(address admin) public onlyAdmin {
        admins[admin] = true;
    }

    function removeAdmin(address admin) public onlyAdmin {
        admins[admin] = false;
    }

    function stake(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender, "not token owner");
        nft.transferFrom(msg.sender, address(this), tokenId);
       
        stakers[msg.sender].tokenId = tokenId;
        stakers[msg.sender].tokenIndex = nft.tokenByIndex(tokenId);
        
        emit TokenStaked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        require(stakers[msg.sender].tokenId == tokenId, "not staker of token");
        nft.transferFrom(address(this), msg.sender, tokenId);

        stakers[msg.sender].tokenId = 0;
        stakers[msg.sender].tokenIndex = 0;
        
        emit TokenUnstaked(msg.sender, tokenId);
    }

    function getTreasureUnlockTime(uint256 tokenId) public view returns(uint256) {
        return stakers[tokenStakedBy[tokenId]].treasureUnlockTime;
    }

    function updateTreasureUnlockTime(uint256 tokenId, uint256 newTreasureUnlockTime) external onlyAdmin {
        require(stakers[tokenStakedBy[tokenId]].tokenId == tokenId, "token not staked");
        stakers[tokenStakedBy[tokenId]].treasureUnlockTime = newTreasureUnlockTime;
    }

    function getRewards(address stakerAddress) public view returns(uint256, uint256) {
        return (stakers[stakerAddress].rewardsEarned, stakers[stakerAddress].rewardsReleased);
    }

    function updateRewards(address stakerAddress, uint256 rewardsEarned, uint256 rewardsReleased) external onlyAdmin {
        stakers[stakerAddress].rewardsEarned = rewardsEarned;
        stakers[stakerAddress].rewardsReleased = rewardsReleased;
        
        emit Emission(stakerAddress, rewardsEarned);
    }

    function getStakedTokens() public view returns(uint256[] memory) {
        uint256 counter = 0;
        for (uint256 i = 0; i < nft.totalSupply(); i++) {
            if (tokenStakedBy[nft.tokenByIndex(i)] != address(0)) {
                counter++;
            }
        }
        
        uint256[] memory tokenIds = new uint256[](counter);
        counter = 0;
        for (uint256 i = 0; i < nft.totalSupply(); i++) {
            uint256 tokenId = nft.tokenByIndex(i);
            if (tokenStakedBy[tokenId] != address(0)) {
                tokenIds[counter] = tokenId;
                counter++;
            }
        }
        
        return tokenIds;
    }
}