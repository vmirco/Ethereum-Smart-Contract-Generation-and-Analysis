pragma solidity ^0.8.0;

// Interfaces and Libraries

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
}

// Main Contract

contract NFTMarketplaceWithStaking {
    using SafeMath for uint256;

    struct NFT {
        address contractAddress; 
        uint256 id;
        uint256 price;
        address payable owner;
        uint256 royalties;
    }

    mapping(uint256 => NFT) public NFTs;
    uint256 public nftCount;
    
    address public tokenAddress;

    constructor (address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function mintToken(uint256 price, uint256 royalties, address contractAddress, uint256 id) external {
        require(IERC721(contractAddress).isApprovedForAll(msg.sender, address(this)), "Contract not approved");
        
        NFTs[nftCount] = NFT(contractAddress, id, price, payable(msg.sender), royalties);
        nftCount = nftCount.add(1);
    }

    function buyToken(uint256 _nftId) external {
        require(IERC20(tokenAddress).transferFrom(msg.sender, NFTs[_nftId].owner, NFTs[_nftId].price), "Transfer failed");

        uint256 royalties = NFTs[_nftId].price.mul(NFTs[_nftId].royalties).div(100);
        NFTs[_nftId].owner.transfer(royalties);
        NFTs[_nftId].owner = payable(msg.sender);
    }

    function stakeTokens(uint256 amount) external {
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        // Implement staking logic here
    }

    function unstakeTokens(uint256 amount) external {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Not enough tokens staked");
        require(IERC20(tokenAddress).transferFrom(address(this), msg.sender, amount), "Transfer failed");
        // Implement unstaking logic here
    }

    function getCurrentTokenSupply() external view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }
}