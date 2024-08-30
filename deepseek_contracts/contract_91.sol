// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract F3Devents {
    event PlayerRegistered(address indexed player);
    event PlayerBought(address indexed player, uint256 amount);
    event PlayerReloaded(address indexed player, uint256 amount);
    event PlayerWithdrew(address indexed player, uint256 amount);
    event AffiliatePaid(address indexed affiliate, uint256 amount);
}

contract F4Kings is F3Devents {
    address public admin;
    address public shareCom;
    uint256 public gameStartTime;
    uint256 public roundDuration;
    uint256 public totalPlayers;
    uint256 public totalBought;
    uint256 public totalWithdrawn;
    uint256 public totalAffiliatePaid;

    struct Player {
        bool isRegistered;
        uint256 balance;
        address affiliate;
    }

    mapping(address => Player) public players;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    constructor(address _shareCom, uint256 _roundDuration) {
        admin = msg.sender;
        shareCom = _shareCom;
        roundDuration = _roundDuration;
        gameStartTime = block.timestamp;
    }

    function registerPlayer(address _affiliate) external {
        require(!players[msg.sender].isRegistered, "Player already registered");
        players[msg.sender] = Player({isRegistered: true, balance: 0, affiliate: _affiliate});
        totalPlayers++;
        emit PlayerRegistered(msg.sender);
    }

    function buy(uint256 amount) external payable {
        require(players[msg.sender].isRegistered, "Player not registered");
        require(msg.value == amount, "Incorrect amount sent");
        players[msg.sender].balance += amount;
        totalBought += amount;
        emit PlayerBought(msg.sender, amount);
    }

    function reload(uint256 amount) external payable {
        require(players[msg.sender].isRegistered, "Player not registered");
        require(msg.value == amount, "Incorrect amount sent");
        players[msg.sender].balance += amount;
        emit PlayerReloaded(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(players[msg.sender].isRegistered, "Player not registered");
        require(players[msg.sender].balance >= amount, "Insufficient balance");
        players[msg.sender].balance -= amount;
        totalWithdrawn += amount;
        payable(msg.sender).transfer(amount);
        emit PlayerWithdrew(msg.sender, amount);
    }

    function payAffiliate(address affiliate, uint256 amount) external onlyAdmin {
        require(players[affiliate].isRegistered, "Affiliate not registered");
        require(players[affiliate].balance >= amount, "Insufficient affiliate balance");
        players[affiliate].balance -= amount;
        totalAffiliatePaid += amount;
        payable(affiliate).transfer(amount);
        emit AffiliatePaid(affiliate, amount);
    }

    function airDrop(address[] memory recipients, uint256[] memory amounts) external onlyAdmin {
        require(recipients.length == amounts.length, "Mismatched arrays");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(players[recipients[i]].isRegistered, "Recipient not registered");
            players[recipients[i]].balance += amounts[i];
        }
    }

    function setRoundDuration(uint256 _roundDuration) external onlyAdmin {
        roundDuration = _roundDuration;
    }

    function setShareCom(address _shareCom) external onlyAdmin {
        shareCom = _shareCom;
    }
}