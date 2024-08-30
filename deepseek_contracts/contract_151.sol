// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface RegistryInterface {
    function isOwner(address wallet, address user) external view returns (bool);
}

interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DAIContract {
    address public admin;
    RegistryInterface public registry;
    CTokenInterface public cToken;
    IERC20 public daiToken;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyOwner(address wallet) {
        require(registry.isOwner(wallet, msg.sender), "Caller is not the owner of the wallet");
        _;
    }

    constructor(address _registryAddress, address _cTokenAddress, address _daiTokenAddress) {
        admin = msg.sender;
        registry = RegistryInterface(_registryAddress);
        cToken = CTokenInterface(_cTokenAddress);
        daiToken = IERC20(_daiTokenAddress);
    }

    function deposit(address wallet, uint256 amount) external onlyOwner(wallet) {
        require(daiToken.transferFrom(wallet, address(this), amount), "Transfer failed");
    }

    function withdraw(address wallet, uint256 amount) external onlyOwner(wallet) {
        require(daiToken.transfer(wallet, amount), "Transfer failed");
    }

    function borrowDAI(uint256 amount) external onlyOwner(msg.sender) {
        require(daiToken.transfer(msg.sender, amount), "Transfer failed");
    }

    function mintDAI(uint256 amount) external onlyOwner(msg.sender) {
        require(daiToken.approve(address(cToken), amount), "Approval failed");
        require(cToken.mint(amount) == 0, "Minting failed");
    }

    function repayDAI(uint256 amount) external onlyOwner(msg.sender) {
        require(daiToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(daiToken.approve(address(cToken), amount), "Approval failed");
        require(cToken.repayBorrow(amount) == 0, "Repayment failed");
    }

    function redeemDAI(uint256 amount) external onlyOwner(msg.sender) {
        require(cToken.redeem(amount) == 0, "Redemption failed");
    }

    function setRegistry(address _registryAddress) external onlyAdmin {
        registry = RegistryInterface(_registryAddress);
    }

    function setCToken(address _cTokenAddress) external onlyAdmin {
        cToken = CTokenInterface(_cTokenAddress);
    }

    function setDAIToken(address _daiTokenAddress) external onlyAdmin {
        daiToken = IERC20(_daiTokenAddress);
    }
}