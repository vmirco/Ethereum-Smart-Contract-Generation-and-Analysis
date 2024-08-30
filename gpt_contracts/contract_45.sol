pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}

contract TokenMarket {

    struct Trade {
        address trader;
        address token;
        uint256 amount;
        uint256 price;
    }

    Trade[] public trades;

    function addTrade(address _token, uint256 _amount, uint256 _price) external {
        trades.push(Trade(msg.sender, _token, _amount, _price));
    }

    function removeTrade(uint256 _tradeId) external {
        require(msg.sender == trades[_tradeId].trader, "Only the trader can remove this trade");
        delete trades[_tradeId];
    }

    function modifyTrade(uint256 _tradeId, uint256 _amount, uint256 _price) external {
        require(msg.sender == trades[_tradeId].trader, "Only the trader can modify this trade");
        trades[_tradeId].amount = _amount;
        trades[_tradeId].price = _price;
    }

    function executeTrade(uint256 _tradeId) external {
        Trade memory trade = trades[_tradeId];
        require(IERC20(trade.token).transferFrom(trade.trader, msg.sender, trade.amount), "Token transfer failed");
        require(payable(trade.trader).send(trade.price * trade.amount), "Eth transfer failed");
        removeTrade(_tradeId);
    }
}