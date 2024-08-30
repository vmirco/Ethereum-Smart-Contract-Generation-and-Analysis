// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NounsDAO {
    address public owner;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public balances;
    mapping(address => mapping(uint256 => bool)) public votes;
    uint256 public totalSupply;

    struct Proposal {
        uint256 id;
        string description;
        uint256 amount;
        address recipient;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) voted;
    }

    event ProposalCreated(uint256 id, string description, uint256 amount, address recipient);
    event VoteCast(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory description, uint256 amount, address recipient) public onlyOwner {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = description;
        p.amount = amount;
        p.recipient = recipient;
        p.executed = false;
        emit ProposalCreated(proposalCount, description, amount, recipient);
    }

    function vote(uint256 proposalId) public {
        require(balances[msg.sender] > 0, "No tokens to vote");
        Proposal storage p = proposals[proposalId];
        require(!p.voted[msg.sender], "Already voted");
        p.voted[msg.sender] = true;
        p.voteCount += balances[msg.sender];
        emit VoteCast(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(p.voteCount > totalSupply / 2, "Not enough votes");
        p.executed = true;
        (bool success, ) = p.recipient.call{value: p.amount}("");
        require(success, "Transfer failed");
        emit ProposalExecuted(proposalId);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        balances[to] += amount;
        totalSupply += amount;
    }

    function getRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    receive() external payable {
        // Accept ETH for treasury
    }
}