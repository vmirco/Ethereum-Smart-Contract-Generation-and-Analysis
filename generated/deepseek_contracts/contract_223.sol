// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governance {
    uint256 public proposalCount;
    uint256 public votingDelay;
    uint256 public votingPeriod;
    uint256 public proposalThreshold;
    uint256 public quorumVotes;

    enum ProposalState { Pending, Active, Defeated, Succeeded, Executed }

    struct Proposal {
        uint256 id;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, string description);
    event VoteCast(uint256 proposalId, address voter, bool support, uint256 votes);
    event ProposalExecuted(uint256 id);

    constructor(uint256 _votingDelay, uint256 _votingPeriod, uint256 _proposalThreshold, uint256 _quorumVotes) {
        votingDelay = _votingDelay;
        votingPeriod = _votingPeriod;
        proposalThreshold = _proposalThreshold;
        quorumVotes = _quorumVotes;
    }

    function createProposal(string memory description) public {
        require(msg.sender == address(this), "Only contract can create proposals");
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = description;
        newProposal.startBlock = block.number + votingDelay;
        newProposal.endBlock = newProposal.startBlock + votingPeriod;
        newProposal.executed = false;

        emit ProposalCreated(proposalCount, description);
    }

    function castVote(uint256 proposalId, bool support) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.number >= proposal.startBlock && block.number <= proposal.endBlock, "Voting is not active");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        if (support) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }

        proposal.hasVoted[msg.sender] = true;

        emit VoteCast(proposalId, msg.sender, support, 1);
    }

    function executeProposal(uint256 proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(state(proposalId) == ProposalState.Succeeded, "Proposal must be succeeded");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotes) {
            return ProposalState.Defeated;
        } else {
            return ProposalState.Succeeded;
        }
    }
}