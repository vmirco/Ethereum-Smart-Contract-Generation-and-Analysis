// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Basic token interface.
interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address tokenOwner) external view returns (uint256 balance);
 function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
 function transfer(address to, uint256 tokens) external returns (bool success);
 function approve(address spender, uint256 tokens) external returns (bool success);
 function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}

interface IJoeRouter {
 function swapExactTokensForTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
 ) external returns (uint[] memory amounts);
}

interface IAave {
 // Add Aave related methods here
}

interface IAaveV3 {
 // Add Aave V3 related methods here
}

contract LeverageVoting {
 address public owner;
 address public lever;
 address public joeRouter;
 address public aave;
 address public aaveV3;
 mapping (address => bool) public isApprovedToken;

 modifier onlyOwner(){
  require(msg.sender == owner);
  _;
 }

 constructor() {
  owner = msg.sender;
 }

 function setApprovers(address _token, bool _value) public onlyOwner {
  isApprovedToken[_token] = _value;
 }

 function setLever(address _lever) public onlyOwner {
  lever = _lever;
 }

 function setJoeRouter(address _joeRouter) public onlyOwner {
  joeRouter = _joeRouter;
 }

 function setAaveAddresses(address _aave, address _aaveV3) public onlyOwner {
  aave = _aave;
  aaveV3 = _aaveV3;
 }

 function deposit(address _token, uint256 _amount) public {
  require(isApprovedToken[_token],"Not an approved token");
  IERC20(_token).transferFrom(msg.sender, address(this), _amount);
 }

 function withdraw(address _token, uint256 _amount) public onlyOwner {
  IERC20(_token).transfer(msg.sender, _amount);
 }

 // Placeholder for example, implement as per the business logic.
 function testVanillaJoeSwapFork() public onlyOwner {
  //Logic for testVanillaJoeSwapFork
 }
 
 // Placeholder for example, implement as per the business logic.
 function testVanillaJLPinFork() public onlyOwner {
  //Logic for JLPinFork
 }

 // Placeholder for example, implement as per the business logic.
 function testVanillaJLPinOutFork() public onlyOwner {
  //Logic for VanillaJLPinOutFork
 }
}