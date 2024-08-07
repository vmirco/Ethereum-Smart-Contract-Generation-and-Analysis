// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NounsDAO {
    address public admin;
    uint public proposalCount;
    uint public voteTime = 7 days;
    uint public quorum = 50; // 50%

    struct Proposal {
        uint id;
        string description;
        uint createdAt;
        uint forVotes;
        uint againstVotes;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public balances;

    event ProposalCreated(uint id, string description);
    event Voted(uint proposalId, address voter, bool vote);
    event ProposalExecuted(uint id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createProposal(string memory _description) public onlyAdmin {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = _description;
        p.createdAt = block.timestamp;
        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint _proposalId, bool _vote) public {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp < p.createdAt + voteTime, "Voting period is over");
        require(!p.voted[msg.sender], "Already voted");
        p.voted[msg.sender] = true;
        if (_vote) {
            p.forVotes++;
        } else {
            p.againstVotes++;
        }
        emit Voted(_proposalId, msg.sender, _vote);
    }

    function executeProposal(uint _proposalId) public onlyAdmin {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp >= p.createdAt + voteTime, "Voting period is not over");
        require(!p.executed, "Proposal already executed");
        uint totalVotes = p.forVotes + p.againstVotes;
        require(totalVotes * 100 / quorum >= quorum, "Quorum not met");
        require(p.forVotes > p.againstVotes, "Majority not in favor");
        p.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    function fundTreasury() public payable {
        balances[address(this)] += msg.value;
    }

    function withdrawFromTreasury(uint amount) public onlyAdmin {
        require(balances[address(this)] >= amount, "Insufficient funds");
        balances[address(this)] -= amount;
        payable(admin).transfer(amount);
    }

    function randomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }
}