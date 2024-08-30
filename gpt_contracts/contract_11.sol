// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IOptionMarket {
    function mintOptions(address receiver, uint256 amount) external returns (bool);
    function burnOptions(address from, uint256 amount) external returns (bool);
}

interface IOptionToken {
    function mint(address receiver, uint256 amount) external returns (bool);
    function burn(address from, uint256 amount) external returns (bool);
}

interface ISynthetixAdapter {
    function getCollateral(address account) external view returns (uint256);
}

contract OptionCollateralManager {
    address public quoteCollateral;
    address public baseCollateral;
    ISynthetixAdapter public synthetixAdapter;
    IOptionMarket public optionMarket;
    IOptionToken public optionToken;

    constructor(address _quoteCollateral, address _baseCollateral, ISynthetixAdapter _synthetixAdapter, IOptionMarket _optionMarket, IOptionToken _optionToken) {
        require(_quoteCollateral != address(0), "_quoteCollateral address cannot be 0");
        require(_baseCollateral != address(0), "_baseCollateral address cannot be 0");
        quoteCollateral = _quoteCollateral;
        baseCollateral = _baseCollateral;
        synthetixAdapter = _synthetixAdapter;
        optionMarket = _optionMarket;
        optionToken = _optionToken;
    }

    function sendBaseCollateral(address _to, uint256 _amount) public {
        IERC20(baseCollateral).transfer(_to, _amount);
    }

    function sendQuoteCollateral(address _to, uint256 _amount) public {
        IERC20(quoteCollateral).transfer(_to, _amount);
    }

    function liquidatePosition(address account) public {
        uint256 amountToLiquidate = ISynthetixAdapter(synthetixAdapter).getCollateral(account);
        if (amountToLiquidate > 0) {
            IOptionMarket(optionMarket).burnOptions(account, amountToLiquidate);
            IOptionToken(optionToken).burn(account, amountToLiquidate);
        }
    }

    function settleOptions(address account, uint256 amount) public {
        IOptionMarket(optionMarket).mintOptions(account, amount);
        IOptionToken(optionToken).mint(account, amount);
    }
}