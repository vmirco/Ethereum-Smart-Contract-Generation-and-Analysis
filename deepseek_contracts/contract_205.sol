// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

contract HealingRequest {
    enum Status { Pending, Fulfilled, Cancelled }

    struct Request {
        address requester;
        uint256 tokenId;
        Status status;
        uint256 randomNumber;
    }

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subId;
    uint16 private constant i_minimumRequestConfirmations = 3;
    uint32 private constant i_callbackGasLimit = 100000;
    uint32 private constant i_numWords = 1;

    Request[] public requests;
    address public owner;
    bool public paused;

    event RequestCreated(uint256 requestId, address requester, uint256 tokenId);
    event RequestFulfilled(uint256 requestId, uint256 randomNumber);
    event RequestCancelled(uint256 requestId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address vrfCoordinatorV2, bytes32 keyHash, uint64 subId) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_keyHash = keyHash;
        i_subId = subId;
        owner = msg.sender;
    }

    function createRequest(uint256 tokenId) external whenNotPaused returns (uint256) {
        uint256 requestId = requests.length;
        requests.push(Request({
            requester: msg.sender,
            tokenId: tokenId,
            status: Status.Pending,
            randomNumber: 0
        }));
        emit RequestCreated(requestId, msg.sender, tokenId);
        return requestId;
    }

    function fulfillRequest(uint256 requestId, uint256 randomNumber) external onlyOwner {
        Request storage request = requests[requestId];
        require(request.status == Status.Pending, "Request is not pending");
        request.randomNumber = randomNumber;
        request.status = Status.Fulfilled;
        emit RequestFulfilled(requestId, randomNumber);
    }

    function cancelRequest(uint256 requestId) external {
        Request storage request = requests[requestId];
        require(request.requester == msg.sender || msg.sender == owner, "Not authorized to cancel");
        require(request.status == Status.Pending, "Request is not pending");
        request.status = Status.Cancelled;
        emit RequestCancelled(requestId);
    }

    function requestRandomNumber(uint256 requestId) external onlyOwner {
        Request storage request = requests[requestId];
        require(request.status == Status.Pending, "Request is not pending");
        i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subId,
            i_minimumRequestConfirmations,
            i_callbackGasLimit,
            i_numWords
        );
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}