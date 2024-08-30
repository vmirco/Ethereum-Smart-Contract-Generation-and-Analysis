// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract usingOraclize {
    uint public price;
    bool public priceUpdated;
    bytes32 public oraclizeId;
    address public oraclizeAddr;
    
    event newOraclizeQuery(string description);
    event newCryptoPrice(string price);

    modifier oraclizeAPI {
        require(msg.sender == oraclizeAddr, "Only oraclize API can call this function");
        _;
    }

    function __callback(bytes32 _oraclizeId, string memory _result) public oraclizeAPI {
        require(oraclizeId == _oraclizeId, "Invalid oraclize id");
        price = parseInt(_result, 2);
        priceUpdated = true;
        emit newCryptoPrice(_result);
    }

    function updatePrice() public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclizeId = oraclize_query("URL", 
                "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price");
        }
    }

    // Query a given URL and expect a number as result
    function oraclize_query(string memory datasource, string memory arg) public payable returns (bytes32 id);

    // Query a given URL at a specific timestamp and expect a number as result
    function oraclize_query(uint timestamp, string memory datasource, string memory arg) public payable returns (bytes32 id);

    // Query a given URL at a specific timestamp and with specific gas price and gas limit, and expect a number as result
    function oraclize_query(uint timestamp, string memory datasource, string memory arg, uint gaslimit) public payable returns (bytes32 id);

    // Get the price of the specified datasource
    function oraclize_getPrice(string calldata datasource) public view returns (uint);

    // Return the address of the OraclizeAddrResolverI instance
    function oraclize_setCustomGasPrice(uint _gasPrice) external;
    
    // Parse Int Function
    function parseInt(string memory _a, uint _b) public pure returns (uint);
}