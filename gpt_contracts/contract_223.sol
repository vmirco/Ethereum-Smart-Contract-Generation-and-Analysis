// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IGovernor {
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

    function proposalCount() public view virtual returns (uint256);
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256);
    function getVotes(address account, uint256 blockNumber) public view virtual returns (uint256 votes);
    function proposalState(uint256 proposalId) public view virtual returns (ProposalState);
    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) public virtual returns (uint256);
    function vote(uint256 proposalId, uint8 support, string memory reason) public virtual returns (uint256 votes);
    function cancel(uint256 proposalId) public virtual;
}

abstract contract IERC20 {
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address account) public view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) public virtual returns (bool);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Governor is IGovernor {
    IERC20 public votingToken;

    constructor(IERC20 _votingToken) {
        votingToken = _votingToken;
    }

    function votingDelay() public view virtual returns (uint256);
    function votingPeriod() public view virtual returns (uint256);
    function proposalThreshold() public view virtual returns (uint256) {
        return (votingToken.totalSupply() * 1) / 100;
    }

    function getVotes(address account, uint256 blockNumber) public view virtual override returns (uint256 votes) {
        return votingToken.balanceOf(account);
    }

}
  
abstract contract GovernorSettings is Governor {

    uint256 private _votingPeriod;
    uint256 private _votingDelay;
    uint256 private _proposalThreshold;

    constructor(IERC20 votingToken, uint256 votingDelay, uint256 votingPeriod, uint256 proposalThreshold) Governor(votingToken) {
        _setVotingDelay(votingDelay);
        _setVotingPeriod(votingPeriod);
        _setProposalThreshold(proposalThreshold);
    }

    function votingDelay() public view override returns (uint256) {
        return _votingDelay;
    }

    function _setVotingDelay(uint256 newVotingDelay) internal {
        _votingDelay = newVotingDelay;
    }

    function votingPeriod() public view override returns (uint256) {
        return _votingPeriod;
    }

    function _setVotingPeriod(uint256 newVotingPeriod) internal {
        _votingPeriod = newVotingPeriod;
    }

    function proposalThreshold() public view override returns (uint256) {
        return _proposalThreshold;
    }

    function _setProposalThreshold(uint256 newProposalThreshold) internal {
        _proposalThreshold = newProposalThreshold;
    }
}