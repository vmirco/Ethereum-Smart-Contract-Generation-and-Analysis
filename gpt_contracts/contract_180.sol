// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModularLongGame {
    struct PlayerData {
        uint256 investedAmount;
        uint256 affiliateReward;
        uint256 lastInvestmentTime;
    }

    mapping(address => PlayerData) public players;
    uint256 public totalInvested;
    uint256 public gameStartTime;

    event PlayerRegistered(address player);
    event GameTimerUpdated(uint256 newStartTime);
    event AffiliatePayout(address affiliate, uint256 payout);

    constructor() {
        gameStartTime = block.timestamp;
    }

    function register() external payable returns(bool) {
        require(msg.value > 0, "Invest at least a positive value");

        PlayerData storage player = players[msg.sender];
        player.investedAmount += msg.value;
        player.lastInvestmentTime = block.timestamp;

        totalInvested += msg.value;

        emit PlayerRegistered(msg.sender);
        return true;
    }

    function getInvestedAmount(address _player) external view returns(uint256) {
        return players[_player].investedAmount;
    }

    function getTotalInvested() external view returns(uint256) {
        return totalInvested;
    }

    function getTimeInvested(address _player) external view returns(uint256) {
        return block.timestamp - players[_player].lastInvestmentTime;
    }

    function getAllPlayerData(address _player) external view returns(uint256, uint256, uint256) {
        return (players[_player].investedAmount, players[_player].affiliateReward, players[_player].lastInvestmentTime);
    }

    function updateGameStartTime() external returns(bool) {
        gameStartTime = block.timestamp;
        emit GameTimerUpdated(gameStartTime);
        return true;
    }

    function getTimeSinceGameStarted() external view returns(uint256) {
        return block.timestamp - gameStartTime;
    }

    function payoutAffiliateReward(address payable affiliate, uint256 _payout) external returns(bool) {
        require(players[affiliate].affiliateReward >= _payout, "Not enough rewards to payout");

        players[affiliate].affiliateReward -= _payout;
        (bool success, ) = affiliate.call{value: _payout}("");
        require(success, "Transfer failed");

        emit AffiliatePayout(affiliate, _payout);
        return success;
    }

    function addAffiliateReward(address _affiliate, uint256 _reward) external returns(bool) {
        players[_affiliate].affiliateReward += _reward;
        return true;
    }
}