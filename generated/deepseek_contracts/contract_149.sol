// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract NFTCollection {
    struct NFT {
        uint256 id;
        uint256 timestamp;
        address owner;
    }

    NFT[] public nfts;
    mapping(uint256 => bool) public nftExists;
    mapping(address => uint256[]) public userNFTs;
    uint256 public nftCounter;
    IERC20 public token;
    uint256 public timeLimit;

    event NFTMinted(uint256 indexed id, address indexed owner);
    event NFTRerolled(uint256 indexed id);
    event TokensDeposited(address indexed user, uint256 amount);

    constructor(address _tokenAddress, uint256 _timeLimit) {
        token = IERC20(_tokenAddress);
        timeLimit = _timeLimit;
    }

    function mintNFT() external {
        nfts.push(NFT({
            id: nftCounter,
            timestamp: block.timestamp,
            owner: msg.sender
        }));
        userNFTs[msg.sender].push(nftCounter);
        nftExists[nftCounter] = true;
        emit NFTMinted(nftCounter, msg.sender);
        nftCounter++;
    }

    function rerollNFT(uint256 _id) external {
        require(nftExists[_id], "NFT does not exist");
        require(nfts[_id].owner == msg.sender, "Not the owner");
        nfts[_id].timestamp = block.timestamp;
        emit NFTRerolled(_id);
    }

    function depositTokens(uint256 _amount) external {
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        emit TokensDeposited(msg.sender, _amount);
    }

    function isTokenAccessible(uint256 _id) public view returns (bool) {
        require(nftExists[_id], "NFT does not exist");
        return (block.timestamp - nfts[_id].timestamp) <= timeLimit;
    }
}