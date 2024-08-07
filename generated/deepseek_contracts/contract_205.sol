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
    VRFCoordinatorV2Interface immutable vrfCoordinator;
    bytes32 immutable keyHash;
    uint64 immutable subId;
    uint16 constant minimumRequestConfirmations = 3;
    uint32 constant callbackGasLimit = 100000;
    uint32 constant numWords = 1;

    enum Status { Pending, Fulfilled, Cancelled }

    struct Request {
        address requester;
        uint256 tokenId;
        Status status;
        uint256 randomResult;
    }

    Request[] public requests;
    mapping(uint256 => uint256) public requestIdToIndex;
    address public owner;
    bool public paused;

    event RequestCreated(uint256 indexed requestId, address indexed requester, uint256 tokenId);
    event RequestFulfilled(uint256 indexed requestId, uint256 randomResult);
    event RequestCancelled(uint256 indexed requestId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address _vrfCoordinator, bytes32 _keyHash, uint64 _subId) {
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subId = _subId;
        owner = msg.sender;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function createRequest(uint256 tokenId) external whenNotPaused returns (uint256) {
        uint256 requestId = requests.length;
        requests.push(Request({
            requester: msg.sender,
            tokenId: tokenId,
            status: Status.Pending,
            randomResult: 0
        }));
        requestIdToIndex[requestId] = requestId;
        emit RequestCreated(requestId, msg.sender, tokenId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal {
        require(requestId < requests.length, "Invalid request ID");
        Request storage request = requests[requestId];
        require(request.status == Status.Pending, "Request is not pending");
        request.randomResult = randomWords[0];
        request.status = Status.Fulfilled;
        emit RequestFulfilled(requestId, randomWords[0]);
    }

    function cancelRequest(uint256 requestId) external onlyOwner {
        require(requestId < requests.length, "Invalid request ID");
        Request storage request = requests[requestId];
        require(request.status == Status.Pending, "Request is not pending");
        request.status = Status.Cancelled;
        emit RequestCancelled(requestId);
    }

    function requestRandomness() external onlyOwner returns (uint256) {
        return vrfCoordinator.requestRandomWords(
            keyHash,
            subId,
            minimumRequestConfirmations,
            callbackGasLimit,
            numWords
        );
    }
}