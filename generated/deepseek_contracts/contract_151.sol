// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface RegistryInterface {
    function isOwnerOf(address user, address wallet) external view returns (bool);
}

interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
}

contract DAIContract {
    IERC20 public dai;
    RegistryInterface public registry;
    CTokenInterface public cDai;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyOwner(address wallet) {
        require(registry.isOwnerOf(msg.sender, wallet), "Not the owner of the wallet");
        _;
    }

    constructor(address _dai, address _registry, address _cDai) {
        dai = IERC20(_dai);
        registry = RegistryInterface(_registry);
        cDai = CTokenInterface(_cDai);
        admin = msg.sender;
    }

    function deposit(uint256 amount) external {
        require(dai.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(cDai.mint(amount) == 0, "Mint failed");
    }

    function withdraw(uint256 amount) external {
        require(cDai.redeem(amount) == 0, "Redeem failed");
        require(dai.transfer(msg.sender, amount), "Transfer failed");
    }

    function borrow(uint256 amount) external onlyOwner(msg.sender) {
        require(dai.transfer(msg.sender, amount), "Transfer failed");
    }

    function repayBorrow(uint256 amount) external {
        require(dai.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(cDai.repayBorrow(amount) == 0, "Repay failed");
    }

    function approveDAI(address spender, uint256 amount) external onlyAdmin {
        require(dai.approve(spender, amount), "Approval failed");
    }

    function transferDAI(address recipient, uint256 amount) external onlyAdmin {
        require(dai.transfer(recipient, amount), "Transfer failed");
    }
}