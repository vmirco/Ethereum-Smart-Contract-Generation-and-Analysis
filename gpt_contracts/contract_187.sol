pragma solidity ^0.8.0;

contract Moloch {
    struct Member {
        bool exists;
        uint shares;
        mapping (address => bool) delegateKeys;
    }

    struct Proposal {
        address proposer;
        uint sharesRequested;
        address recipient;
        bool executed;
        uint yesVotes;
        uint noVotes;
    }
   
    mapping (address =>  Member) public members;
    mapping (address => bool) public hasVoted;
    Proposal[] public proposals;

    function submitProposal (uint sharesRequested, address recipient) public returns(uint){
        require(members[msg.sender].exists, "Only members can submit proposals");
        Proposal memory newProposal = Proposal({
            proposer: msg.sender,
            sharesRequested: sharesRequested,
            recipient: recipient,
            executed: false,
            yesVotes: 0,
            noVotes: 0
        });
        proposals.push(newProposal);
        return proposals.length - 1;
    }

    function vote(uint proposalIndex, bool vote) public {
        require(members[msg.sender].exists, "Only members can vote");
        require(!hasVoted[msg.sender], "Member has already voted");

        Proposal storage proposal = proposals[proposalIndex];
        require(!proposal.executed, "Proposal has been executed");

        if(vote){
            proposal.yesVotes += members[msg.sender].shares;
        } else {
            proposal.noVotes += members[msg.sender].shares;
        }
        hasVoted[msg.sender] = true;
    }

    function executeProposal(uint proposalIndex) public {
        Proposal storage proposal = proposals[proposalIndex];
        require(!proposal.executed, "Proposal has been executed");
        require(proposal.yesVotes > proposal.noVotes, "Proposal did not pass");
        
        
        proposal.executed = true;
    }

    function addMember(address newMember, uint shares) public {
        require(!members[newMember].exists, "Must not be a member already");
        require(shares > 0, "Shares must be more than 0");
        members[newMember].exists = true;
        members[newMember].shares = shares;
    }
    
    
    function addDelegateKey(address member, address delegateKey) public {
        require(members[member].exists, "Member must exist");
        require(!members[member].delegateKeys[delegateKey], "Delegate key already exists");
        
        members[member].delegateKeys[delegateKey] = true;
    }

    function removeDelegateKey(address member, address delegateKey) public {
        require(members[member].exists, "Member must exist");
        require(members[member].delegateKeys[delegateKey], "Delegate key does not exist");
        
        delete members[member].delegateKeys[delegateKey];
    }
}