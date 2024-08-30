// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILendingPool {
    function getReserveData(address asset) external view returns (uint256);
    function setReserveData(address asset, uint256 data) external;
}

contract DelayedProtocolParameters {
    struct ParameterProposal {
        address asset;
        uint256 newData;
        uint256 commitTime;
        bool committed;
    }

    ILendingPool public lendingPool;
    address public owner;
    mapping(address => ParameterProposal) public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _lendingPoolAddress) {
        lendingPool = ILendingPool(_lendingPoolAddress);
        owner = msg.sender;
    }

    function proposeParameterUpdate(address asset, uint256 newData, uint256 delay) external onlyOwner {
        require(delay > 0, "Delay must be greater than 0");
        proposals[asset] = ParameterProposal({
            asset: asset,
            newData: newData,
            commitTime: block.timestamp + delay,
            committed: false
        });
    }

    function commitParameterUpdate(address asset) external onlyOwner {
        ParameterProposal storage proposal = proposals[asset];
        require(proposal.commitTime > 0, "No proposal for this asset");
        require(block.timestamp >= proposal.commitTime, "Commit time not reached");
        require(!proposal.committed, "Already committed");

        lendingPool.setReserveData(asset, proposal.newData);
        proposal.committed = true;
    }

    function getCurrentParameter(address asset) external view returns (uint256) {
        return lendingPool.getReserveData(asset);
    }

    function getProposedParameter(address asset) external view returns (uint256) {
        return proposals[asset].newData;
    }
}