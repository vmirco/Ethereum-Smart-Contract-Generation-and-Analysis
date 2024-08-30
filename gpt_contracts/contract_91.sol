pragma solidity ^0.8.0;

// F3Devents contract
contract F3Devents {
    event onRegisterPlayer(address indexed newAddress, bytes32 name, address indexed affiliatedAddress, uint256 ethereumUsed, uint256 timeStamp);
    event onBuyKey(address indexed playerAddress, bytes32 name, uint256 roundID, uint256 numberOfKeys, uint256 ethereumUsed, uint256 timeStamp);
    event onReloadKey(address indexed playerAddress, bytes32 name, uint256 roundID, uint256 numberOfKeys, uint256 ethereumUsed, uint256 timeStamp);
    event onWithdraw(address indexed playerAddress, bytes32 name, uint256 ethereumOut, uint256 timeStamp);
    event onAffiliatePayout(address indexed affiliateAddress, address indexed playerAddress, bytes32 name, uint256 roundID, uint256 ethereumUsed, uint256 timeStamp);
}

// F4Kings game contract
contract F4Kings is F3Devents {
    struct Player {
        uint256 id;
        bytes32 name;
        address walletAddress;
    }
    
    mapping(address => Player) public players;
    mapping(uint => address payable) public addressIndexes;
    
    uint256 public playerIndex;
    address public admin; 
    address payable public shareCom;
    
    uint256 private airdropCounter;
    uint256 public roundTimer;
    uint256 public affiliatePercentage = 10;
    
    // game settings parameters
    uint256 public initialKeyPrice;
    uint256 public roundTimeLimit;

    constructor(
        address _admin,
        address payable _shareCom,
        uint256 _initialKeyPrice,
        uint256 _roundTimeLimit
    ) {
        require(_admin != address(0) && _shareCom != address(0), "Invalid address");
        admin = _admin;
        shareCom = _shareCom;
        initialKeyPrice = _initialKeyPrice;
        roundTimeLimit = _roundTimeLimit;
    }

    function registerPlayer(bytes32 _name) public payable {
        require(players[msg.sender].walletAddress == address(0), "Player already registered");
        require(msg.value >= initialKeyPrice, "Insufficient Ethereum");
        
        Player memory newPlayer = Player(playerIndex, _name, msg.sender);
        players[msg.sender] = newPlayer;
        addressIndexes[playerIndex] = payable(msg.sender);
        playerIndex++;
        
        emit onRegisterPlayer(msg.sender, _name, address(0), msg.value, block.timestamp);
    }

    function buyKey(uint _numberOfKeys) public payable {
        require(players[msg.sender].walletAddress != address(0), "Player not registered");
        require(msg.value >= initialKeyPrice*_numberOfKeys, "Insufficient Ethereum");
        if(block.timestamp > roundTimer + roundTimeLimit) {
            roundTimer = block.timestamp;
        }
        
        emit onBuyKey(msg.sender, players[msg.sender].name, playerIndex, _numberOfKeys, msg.value, block.timestamp);
    }

    function reloadKey(uint _numberOfKeys) public payable {
        require(players[msg.sender].walletAddress != address(0), "Player not registered");
        require(msg.value >= initialKeyPrice*_numberOfKeys, "Insufficient Ethereum");   
        
        emit onReloadKey(msg.sender, players[msg.sender].name, playerIndex, _numberOfKeys, msg.value, block.timestamp);
    }

    function withdraw() public {
        require(players[msg.sender].walletAddress != address(0), "Player not registered");
        
        emit onWithdraw(msg.sender, players[msg.sender].name, address(this).balance, block.timestamp);
    }

    function affiliatePayout(address _affiliateAddress) public payable {
        require(players[msg.sender].walletAddress != address(0), "Player not registered");

        uint256 payout = msg.value * affiliatePercentage / 100;
        payable(_affiliateAddress).transfer(payout);
        
        emit onAffiliatePayout(_affiliateAddress, msg.sender, players[msg.sender].name, playerIndex, payout, block.timestamp);
    }

    // admin function to withdraw all ether from contract
    function adminWithdraw() public {
        require(msg.sender == admin, "Only admin can perform this action");
        shareCom.transfer(address(this).balance);
    }

    function addAirdrop() public payable {
        require(players[msg.sender].walletAddress != address(0), "Player not registered");
        require(msg.value >= initialKeyPrice, "Insufficient Ethereum");
        airdropCounter++;
        if(airdropCounter >= 100) {
            airdropCounter = 0;
            shareCom.transfer(address(this).balance);
        }
    }
}