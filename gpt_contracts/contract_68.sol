// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

import "https://github.com/smartcontractkit/Chainlink-Brownie-Contracts/blob/main/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AoriToken is ERC20Burnable, Ownable {
    mapping (address => uint) private _balances;
    mapping (address => bool) private _vaultsTrusted;
    mapping (address => bool) private _oraclesTrusted;
    
    AggregatorV3Interface public priceFeed;
    
    constructor(AggregatorV3Interface _priceFeed) ERC20("Aori Token", "AORI") {
        priceFeed = _priceFeed;
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
    
    function getPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    function deposit(uint _amount) external {
        require(_vaultsTrusted[msg.sender], "Vault not trusted");
        _mint(msg.sender, _amount);
    }
    
    function withdraw(uint _amount) external {
        require(_vaultsTrusted[msg.sender], "Vault not trusted");
        _burn(msg.sender, _amount);
    }
    
    function claim(uint _amount) external {
        require(_balances[msg.sender] >= _amount, "Insufficient funds");
        _balances[msg.sender] -= _amount;
        _transfer(address(this), msg.sender, _amount);
    }
    
    function setVaultTrusted(address _vault, bool _isTrusted) external onlyOwner {
        _vaultsTrusted[_vault] = _isTrusted;
    }
    
    function setOracleTrusted(address _oracle, bool _isTrusted) external onlyOwner {
        _oraclesTrusted[_oracle] = _isTrusted;
    }
    
    function isVaultTrusted(address _vault) external view returns (bool) {
        return _vaultsTrusted[_vault];
    }
    
    function isOracleTrusted(address _oracle) external view returns (bool) {
        return _oraclesTrusted[_oracle];
    }
}