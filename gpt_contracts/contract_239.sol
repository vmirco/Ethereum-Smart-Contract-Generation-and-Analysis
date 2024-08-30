pragma solidity ^0.8.0;

contract NounsDAO {
    struct Proposal {
        address proposer;
        string description;
        uint256 amount;
        bool executed;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => bool)) public votes;
    mapping(uint256 => uint256) public totalVotes;

    function propose(string memory description, uint256 amount) public {
        Proposal memory newProposal = Proposal({
            proposer: msg.sender,
            description: description,
            amount: amount,
            executed: false
        });

        proposals[proposalCount] = newProposal;
        proposalCount += 1;
    }

    function vote(uint256 proposalId) public {
        require(proposalId < proposalCount, "Invalid proposalId");
        Proposal storage proposal = proposals[proposalId];
        require(proposal.executed == false, "Proposal already executed");

        require(!votes[proposalId][msg.sender], "You already voted for this proposal");
        votes[proposalId][msg.sender] = true;
        totalVotes[proposalId] += balances[msg.sender];
    }

    function execute(uint256 proposalId) public {
        require(proposalId < proposalCount, "Invalid proposalId");
        Proposal storage proposal = proposals[proposalId];
        require(proposal.executed == false, "Proposal already executed");

        proposal.executed = true;

        payable(proposal.proposer).transfer(proposal.amount);
    }

    function depositEther() public payable {
        require(msg.value > 0, "Please send some ether");
        balances[msg.sender] += msg.value;
    }

    function randomNumberGenerator() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }
}