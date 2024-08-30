// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC1155 {
    function balanceOf(address _owner, uint256 _id) virtual public view returns (uint256);
    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) virtual public view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) virtual public;
    function isApprovedForAll(address _owner, address _operator) virtual public view returns (bool);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) virtual public;
    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) virtual public;
}

contract MyERC1155Token is ERC1155 {
    mapping (address => mapping(uint256 => uint256)) private balances;
    mapping (address => mapping(address => bool)) private operatorApprovals;

    function balanceOf(address _owner, uint256 _id) override public view returns (uint256) {
        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) override public view returns (uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address _operator, bool _approved) override public {
        operatorApprovals[msg.sender][_operator] = _approved;
    }

    function isApprovedForAll(address _owner, address _operator) override public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) override public {
        require(balances[_from][_id] >= _value, "Insufficient balance");
        balances[_from][_id] -= _value;
        balances[_to][_id] += _value;
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) override public {
        for(uint256 i = 0; i < _ids.length; i++) {
            require(balances[_from][_ids[i]] >= _values[i], "Insufficient balance");
            balances[_from][_ids[i]] -= _values[i];
            balances[_to][_ids[i]] += _values[i];
        }
    }
}