// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract F3Devents {
    event onPlayerRegistered(address playerAddress);
    event onPlayerBuy(address playerAddress, uint256 amount);
    event onPlayerReload(address playerAddress, uint256 amount);
    event onWithdraw(address playerAddress, uint256 amount);
    event onAffiliatePayout(address affiliateAddress, uint256 amount);
}

contract F4Kings is F3Devents {
    address public admin;
    address public shareCom;

    struct GameSettings {
        uint256 registrationFee;
        uint256 buyFee;
        uint256 reloadFee;
        uint256 withdrawFee;
        uint256 affiliatePercentage;
    }

    struct GameStatistics {
        uint256 totalPlayers;
        uint256 totalBuys;
        uint256 totalReloads;
        uint256 totalWithdrawals;
        uint256 totalAffiliatePayouts;
    }

    GameSettings public settings;
    GameStatistics public statistics;

    mapping(address => bool) public players;
    mapping(address => address) public affiliates;
    mapping(address => uint256) public balances;

    uint256 public roundStartTime;
    uint256 public roundDuration;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _admin, address _shareCom, uint256 _roundDuration) {
        admin = _admin;
        shareCom = _shareCom;
        roundDuration = _roundDuration;
        roundStartTime = block.timestamp;
    }

    function registerPlayer(address _affiliate) public payable {
        require(msg.value == settings.registrationFee, "Incorrect registration fee");
        require(!players[msg.sender], "Player already registered");

        players[msg.sender] = true;
        affiliates[msg.sender] = _affiliate;
        statistics.totalPlayers++;

        emit onPlayerRegistered(msg.sender);
    }

    function buy(uint256 amount) public payable {
        require(msg.value == amount + settings.buyFee, "Incorrect buy fee");
        require(players[msg.sender], "Player not registered");

        balances[msg.sender] += amount;
        statistics.totalBuys += amount;

        emit onPlayerBuy(msg.sender, amount);
    }

    function reload(uint256 amount) public payable {
        require(msg.value == amount + settings.reloadFee, "Incorrect reload fee");
        require(players[msg.sender], "Player not registered");

        balances[msg.sender] += amount;
        statistics.totalReloads += amount;

        emit onPlayerReload(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > settings.withdrawFee, "Amount must be greater than withdraw fee");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount - settings.withdrawFee);
        statistics.totalWithdrawals += amount;

        emit onWithdraw(msg.sender, amount);
    }

    function affiliatePayout(address affiliate, uint256 amount) internal {
        require(amount > 0, "Amount must be greater than zero");

        payable(affiliate).transfer(amount);
        statistics.totalAffiliatePayouts += amount;

        emit onAffiliatePayout(affiliate, amount);
    }

    function airDrop(address[] memory recipients, uint256[] memory amounts) public onlyAdmin {
        require(recipients.length == amounts.length, "Mismatched arrays");

        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amounts[i];
        }
    }

    function setRoundDuration(uint256 _roundDuration) public onlyAdmin {
        roundDuration = _roundDuration;
        roundStartTime = block.timestamp;
    }

    function setSettings(uint256 _registrationFee, uint256 _buyFee, uint256 _reloadFee, uint256 _withdrawFee, uint256 _affiliatePercentage) public onlyAdmin {
        settings = GameSettings({
            registrationFee: _registrationFee,
            buyFee: _buyFee,
            reloadFee: _reloadFee,
            withdrawFee: _withdrawFee,
            affiliatePercentage: _affiliatePercentage
        });
    }
}