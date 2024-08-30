// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MolochTokenSystem {
    struct Proposal {
        address proposer;
        uint256 id;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public delegates;
    mapping(address => bool) public members;
    uint256 public proposalCount;

    event ProposalSubmitted(uint256 indexed id, address indexed proposer);
    event VoteCasted(uint256 indexed id, address indexed voter, bool inSupport);
    event ProposalExecuted(uint256 indexed id);

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    function submitProposal() external onlyMember {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.proposer = msg.sender;
        p.id = proposalCount;
        p.executed = false;

        emit ProposalSubmitted(proposalCount, msg.sender);
    }

    function castVote(uint256 proposalId, bool inSupport) external onlyMember {
        Proposal storage p = proposals[proposalId];
        require(!p.voted[msg.sender], "Already voted");
        p.voted[msg.sender] = true;

        if (inSupport) {
            p.votesFor++;
        } else {
            p.votesAgainst++;
        }

        emit VoteCasted(proposalId, msg.sender, inSupport);
    }

    function executeProposal(uint256 proposalId) external onlyMember {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(p.votesFor > p.votesAgainst, "Majority not in support");

        p.executed = true;

        emit ProposalExecuted(proposalId);
    }

    function setDelegate(address delegate) external onlyMember {
        delegates[msg.sender] = delegate;
    }

    function addMember(address member) external onlyMember {
        members[member] = true;
    }

    function removeMember(address member) external onlyMember {
        members[member] = false;
    }
}