// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenVesting {
    // OpenZeppelin ERC20 contract implementation
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // TokenVesting specific code
    bytes32 public merkleRoot;
    uint256 public tgeTimestamp;
    mapping(address => bool) public hasClaimed;
    mapping(address => uint256) public claimedAmount;
    mapping(uint256 => uint256) public stepTimestamps;
    mapping(uint256 => uint256) public stepAmounts;

    event TokensClaimed(address indexed user, uint256 amount);
    event TGEInitialized(uint256 timestamp);
    event StepClaimed(uint256 indexed step, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function initializeTGE(uint256 _tgeTimestamp, bytes32 _merkleRoot) public onlyOwner {
        tgeTimestamp = _tgeTimestamp;
        merkleRoot = _merkleRoot;
        emit TGEInitialized(_tgeTimestamp);
    }

    function setStep(uint256 step, uint256 timestamp, uint256 amount) public onlyOwner {
        stepTimestamps[step] = timestamp;
        stepAmounts[step] = amount;
    }

    function claimTokens(address user, uint256 amount, bytes32[] memory proof) public {
        require(!hasClaimed[user], "Tokens already claimed");
        require(verifyMerkleProof(user, amount, proof), "Invalid proof");

        hasClaimed[user] = true;
        claimedAmount[user] = amount;
        require(transfer(user, amount), "Transfer failed");

        emit TokensClaimed(user, amount);
    }

    function verifyMerkleProof(address user, uint256 amount, bytes32[] memory proof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user, amount));
        return verify(merkleRoot, leaf, proof);
    }

    function verify(bytes32 root, bytes32 leaf, bytes32[] memory proof) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }
}