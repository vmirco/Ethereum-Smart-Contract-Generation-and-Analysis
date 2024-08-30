// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address dst, uint amount) external returns (bool);
}

interface RegistryInterface {
    function wallets(address) external view returns (address);
    function isOwner(address, address) external view returns (bool);
}

interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
}

contract DAILoan {
    address public admin;
    RegistryInterface public registry;
    CTokenInterface public cToken;
    ERC20Interface public daiToken;
    
    modifier onlyAdmin {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    modifier onlyOwner(address wallet) {
        require(registry.isOwner(msg.sender, wallet), "Caller is not the wallet owner");
        _;
    }
    
    constructor(address _registry, address _cToken, address _daiToken) {
        admin = msg.sender;
        registry = RegistryInterface(_registry);
        cToken = CTokenInterface(_cToken);
        daiToken = ERC20Interface(_daiToken);
    }
    
    function deposit(address wallet, uint amount) external onlyOwner(wallet) {
        require(daiToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        daiToken.approve(address(cToken), amount);
        require(cToken.mint(amount) == 0, "Deposit failed");
    }

    function withdraw(address wallet, uint amount) external onlyOwner(wallet) {
        require(cToken.redeem(amount) == 0, "Withdraw failed");
        require(daiToken.transfer(wallet, amount), "Transfer failed");
    }
    
    function borrow(address wallet, uint amount) external onlyOwner(wallet) {
        require(cToken.borrow(amount) == 0, "Borrow failed");
        require(daiToken.transfer(wallet, amount), "Transfer failed");
    }
    
    function repay(address wallet, uint amount) external onlyOwner(wallet) {
        require(daiToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        daiToken.approve(address(cToken), amount);
        require(cToken.repayBorrow(amount) == 0, "Repayment failed");
    }

    function transferOwnership(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
}