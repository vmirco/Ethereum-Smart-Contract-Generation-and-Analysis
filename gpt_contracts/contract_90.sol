// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a, "SafeMath: subtraction overflow");
      uint256 c = a - b;

      return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
        return 0;
      }

      uint256 c = a * b;
      require(c / a == b, "SafeMath: multiplication overflow");

      return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b > 0, "SafeMath: division by zero");
      uint256 c = a / b;

      return c;
    }
}

contract Auth {
  address public owner;
  
  constructor(address _owner) {
    owner = _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can execute this");
    _;
  }

  function changeOwner(address newOwner) public onlyOwner {
   owner = newOwner;
  }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}


contract IntegrationContract is Auth {
  using SafeMath for uint256;
  IDEXRouter public idexRouter;
  IDEXFactory public idexFactory;

  constructor(address _router, address _factory, address _owner) Auth(_owner) {
    idexRouter = IDEXRouter(_router);
    idexFactory = IDEXFactory(_factory);
  }

  function addLiquidity(
      address tokenA,
      address tokenB,
      uint256 amountADesired,
      uint256 amountBDesired,
      uint256 amountAMin,
      uint256 amountBMin,
      address to,
      uint256 deadline
  ) public onlyOwner returns(uint256 amountA, uint256 amountB, uint256 liquidity) {
    return idexRouter.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
  } 
}