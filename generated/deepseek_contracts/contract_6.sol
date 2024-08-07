// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenVesting {
    // Token contract
    IERC20 public token;
    // Merkle root for proof of ownership
    bytes32 public merkleRoot;
    // TGE timestamp
    uint256 public tgeTimestamp;
    // Vesting steps
    uint256[] public vestingSteps;
    // Token distribution per step
    uint256[] public tokensPerStep;

    // Mapping from address to claimed status
    mapping(address => bool) public hasClaimed;
    // Mapping from address to claimed amounts per step
    mapping(address => uint256[]) public claimedAmounts;

    // Events
    event TokensClaimed(address indexed user, uint256 amount);
    event TGEOccurred(uint256 timestamp);
    event StepClaimed(address indexed user, uint256 step, uint256 amount);

    constructor(
        address _token,
        bytes32 _merkleRoot,
        uint256 _tgeTimestamp,
        uint256[] memory _vestingSteps,
        uint256[] memory _tokensPerStep
    ) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        tgeTimestamp = _tgeTimestamp;
        vestingSteps = _vestingSteps;
        tokensPerStep = _tokensPerStep;
    }

    function claimTokens(
        address user,
        uint256 totalAmount,
        bytes32[] calldata merkleProof
    ) external {
        require(!hasClaimed[user], "Tokens already claimed");
        require(verifyProof(user, totalAmount, merkleProof), "Invalid proof");

        hasClaimed[user] = true;
        distributeTokens(user, totalAmount);
        emit TokensClaimed(user, totalAmount);
    }

    function claimStep(
        address user,
        uint256 step,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        require(step < vestingSteps.length, "Invalid step");
        require(block.timestamp >= vestingSteps[step], "Step not yet available");
        require(verifyProof(user, amount, merkleProof), "Invalid proof");

        claimedAmounts[user][step] += amount;
        token.transfer(user, amount);
        emit StepClaimed(user, step, amount);
    }

    function verifyProof(
        address user,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) internal view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(user, amount));
        for (uint256 i = 0; i < merkleProof.length; i++) {
            node = parentHash(node, merkleProof[i]);
        }
        return node == merkleRoot;
    }

    function parentHash(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    function distributeTokens(address user, uint256 totalAmount) internal {
        for (uint256 i = 0; i < vestingSteps.length; i++) {
            claimedAmounts[user].push(0);
        }
        token.transfer(user, totalAmount);
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}