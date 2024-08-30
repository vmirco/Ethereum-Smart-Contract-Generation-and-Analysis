// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IGovernor is IERC165 {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 votes, string reason);

    function name() external view returns (string memory);
    function version() external view returns (string memory);
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) external pure returns (uint256);
    function state(uint256 proposalId) external view returns (ProposalState);
    function proposalSnapshot(uint256 proposalId) external view returns (uint256);
    function proposalDeadline(uint256 proposalId) external view returns (uint256);
    function proposalVotes(uint256 proposalId) external view returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes);
    function quorum(uint256 blockNumber) external view returns (uint256);
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);
    function castVote(uint256 proposalId, uint8 support) external returns (uint256 balance);
    function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) external returns (uint256 balance);
    function castVoteBySig(uint256 proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) external returns (uint256 balance);
}

abstract contract Governor is IGovernor, ERC165, Context, Ownable {
    using Counters for Counters.Counter;

    struct ProposalCore {
        uint256 voteStart;
        uint256 voteEnd;
        bool executed;
        bool canceled;
    }

    string private _name;
    string private _version;

    mapping(uint256 => ProposalCore) private _proposals;
    Counters.Counter private _proposalCounter;

    constructor(string memory name_, string memory version_) {
        _name = name_;
        _version = version_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function version() public view virtual override returns (string memory) {
        return _version;
    }

    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual override returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    function state(uint256 proposalId) public view virtual override returns (ProposalState) {
        require(_proposals[proposalId].voteStart != 0, "Governor: unknown proposal id");

        if (_proposals[proposalId].canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= _proposals[proposalId].voteStart) {
            return ProposalState.Pending;
        } else if (block.number <= _proposals[proposalId].voteEnd) {
            return ProposalState.Active;
        } else if (!_proposals[proposalId].executed) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Executed;
        }
    }

    function proposalSnapshot(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteStart;
    }

    function proposalDeadline(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteEnd;
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual override returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        require(_proposals[proposalId].voteStart == 0, "Governor: proposal already exists");

        uint256 currentBlock = block.number;
        uint256 startBlock = currentBlock + votingDelay();
        uint256 endBlock = startBlock + votingPeriod();

        _proposals[proposalId] = ProposalCore({
            voteStart: startBlock,
            voteEnd: endBlock,
            executed: false,
            canceled: false
        });

        emit ProposalCreated(
            proposalId,
            _msgSender(),
            targets,
            values,
            new string[](targets.length),
            calldatas,
            startBlock,
            endBlock,
            description
        );

        return proposalId;
    }

    function votingDelay() public view virtual returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public view virtual returns (uint256) {
        return 5; // 5 blocks
    }

    function quorum(uint256 blockNumber) public view virtual override returns (uint256) {
        return 1; // 1 vote
    }

    function getVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {
        return 1; // 1 vote per account
    }

    function castVote(uint256 proposalId, uint8 support) public virtual override returns (uint256) {
        return _castVote(proposalId, _msgSender(), support, "");
    }

    function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) public virtual override returns (uint256) {
        return _castVote(proposalId, _msgSender(), support, reason);
    }

    function _castVote(uint256 proposalId, address account, uint8 support, string memory reason) internal virtual returns (uint256) {
        require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        uint256 votes = getVotes(account, proposalSnapshot(proposalId));

        emit VoteCast(account, proposalId, support, votes, reason);

        return votes;
    }
}

contract MyGovernor is Governor {
    constructor() Governor("MyGovernor", "1") {}
}