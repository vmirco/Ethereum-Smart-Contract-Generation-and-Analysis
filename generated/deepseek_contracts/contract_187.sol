// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MolochTokenSystem {
    struct Proposal {
        address proposer;
        uint256 startingPeriod;
        uint256 yesVotes;
        uint256 noVotes;
        bool processed;
        bool didPass;
    }

    struct Member {
        address delegateKey;
        uint256 shares;
        bool exists;
    }

    address public summoner;
    uint256 public proposalCount;
    uint256 public votingPeriodLength;
    uint256 public gracePeriodLength;
    uint256 public proposalDeposit;
    uint256 public processingReward;
    uint256 public periodDuration;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => Member) public members;
    mapping(address => bool) public isMember;
    mapping(address => uint256) public memberIndexes;

    event SubmitProposal(uint256 proposalId, address proposer);
    event Vote(uint256 proposalId, address voter, bool approve);
    event ProcessProposal(uint256 proposalId, bool didPass);

    modifier onlyMember() {
        require(isMember[msg.sender], "not a member");
        _;
    }

    constructor(
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _proposalDeposit,
        uint256 _processingReward,
        uint256 _periodDuration
    ) {
        summoner = msg.sender;
        votingPeriodLength = _votingPeriodLength;
        gracePeriodLength = _gracePeriodLength;
        proposalDeposit = _proposalDeposit;
        processingReward = _processingReward;
        periodDuration = _periodDuration;

        members[summoner] = Member({
            delegateKey: summoner,
            shares: 1,
            exists: true
        });
        isMember[summoner] = true;
        memberIndexes[summoner] = 0;
    }

    function submitProposal(address proposer) external onlyMember {
        proposalCount++;
        uint256 startingPeriod = block.number / periodDuration;

        proposals[proposalCount] = Proposal({
            proposer: proposer,
            startingPeriod: startingPeriod,
            yesVotes: 0,
            noVotes: 0,
            processed: false,
            didPass: false
        });

        emit SubmitProposal(proposalCount, proposer);
    }

    function vote(uint256 proposalId, bool approve) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.startingPeriod > 0, "proposal does not exist");
        require(block.number / periodDuration < proposal.startingPeriod + votingPeriodLength, "voting period is over");

        Member storage member = members[msg.sender];
        require(member.delegateKey == msg.sender, "not delegated");

        if (approve) {
            proposal.yesVotes += member.shares;
        } else {
            proposal.noVotes += member.shares;
        }

        emit Vote(proposalId, msg.sender, approve);
    }

    function processProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.processed, "proposal already processed");
        require(block.number / periodDuration >= proposal.startingPeriod + votingPeriodLength + gracePeriodLength, "grace period not over");

        proposal.processed = true;
        proposal.didPass = proposal.yesVotes > proposal.noVotes;

        emit ProcessProposal(proposalId, proposal.didPass);
    }
}