// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/smartcontractkit/chainlink-brownie-contracts/blob/main/contracts/src/v0.6/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";


contract HealingRequest is VRFConsumerBase, Ownable, Initializable, Pausable {
    uint256 public healPrice;
    uint256 public tokenIndex;

    bytes32 internal keyHash;
    uint256 internal fee;

    struct HealRequest {
        address requester;
        bool isFulfilled;
        uint256 healingAmount;
        uint256 tokenID;
    }

    mapping(bytes32 => HealRequest) public healRequests;
    mapping(uint256 => bytes32) public tokenIdToRequestId;

    event ReceivedHealRequest(bytes32 indexed requestId, address indexed requester, uint256 tokenID);
    event FulfilledHealRequest(bytes32 indexed requestId, uint256 healingAmount);

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyHash) 
        VRFConsumerBase(_VRFCoordinator, _LinkToken) {
        keyHash = _keyHash;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        healPrice = 1 ether;
    }

    function initialize(address owner) public initializer {
        _transferOwnership(owner);
    }

    function requestHealing() public payable whenNotPaused {
        require(msg.value >= healPrice, 'Not enough Ether for healing request.');

        bytes32 requestId = requestRandomness(keyHash, fee);
        uint256 tokenID = tokenIndex++;

        HealRequest storage newRequest = healRequests[requestId];
        newRequest.requester = msg.sender;
        newRequest.isFulfilled = false;
        newRequest.tokenID = tokenID;

        tokenIdToRequestId[tokenID] = requestId;

        emit ReceivedHealRequest(requestId, msg.sender, tokenID);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        HealRequest storage hr = healRequests[requestId];
        hr.isFulfilled = true;
        hr.healingAmount = randomness % 100;

        emit FulfilledHealRequest(requestId, hr.healingAmount);
    }

    function getHealing(uint256 tokenId) public view returns(uint256 healingAmount) {
        bytes32 requestId = tokenIdToRequestId[tokenId];
        require(healRequests[requestId].isFulfilled, 'Healing request is not fulfilled yet.');
        
        return healRequests[requestId].healingAmount;
    }

    function setHealingPrice(uint256 _healPrice) public onlyOwner {
        healPrice = _healPrice;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, 'Balance is 0');
      
        payable(owner()).transfer(balance);
    }

    function pauseContract() public onlyOwner {
        _pause();
    }

    function unpauseContract() public onlyOwner {
        _unpause();
    }
}