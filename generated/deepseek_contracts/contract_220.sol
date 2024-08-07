// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OraclizeAPI {
    address public owner;
    uint256 public queryCount;

    struct Query {
        string dataSource;
        string query;
        uint256 timestamp;
        uint256 gasLimit;
        uint256 gasPrice;
    }

    mapping(uint256 => Query) public queries;

    event QueryResult(uint256 indexed queryId, string result);
    event QueryError(uint256 indexed queryId, string error);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function queryData(
        string memory _dataSource,
        string memory _query,
        uint256 _timestamp,
        uint256 _gasLimit,
        uint256 _gasPrice
    ) public payable onlyOwner returns (uint256) {
        require(msg.value >= _gasPrice * _gasLimit, "Insufficient funds for gas");

        queryCount++;
        queries[queryCount] = Query({
            dataSource: _dataSource,
            query: _query,
            timestamp: _timestamp,
            gasLimit: _gasLimit,
            gasPrice: _gasPrice
        });

        // Simulate querying external API
        string memory result = simulateQuery(_dataSource, _query, _timestamp);

        if (bytes(result).length > 0) {
            emit QueryResult(queryCount, result);
        } else {
            emit QueryError(queryCount, "No result or error occurred");
        }

        return queryCount;
    }

    function simulateQuery(
        string memory _dataSource,
        string memory _query,
        uint256 _timestamp
    ) internal pure returns (string memory) {
        // Simulate the result of an external API query
        return "Sample API result";
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}