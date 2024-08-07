// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC1155 {
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from account to token IDs to balances
    mapping(address => mapping(uint256 => uint256)) private _balances;

    // Event emitted when tokens are transferred
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // Event emitted when a batch of tokens are transferred
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    // Event emitted when an operator is approved or disapproved
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Returns the balance of a specific token ID for a given account.
     * @param account The address of the account to query.
     * @param id The token ID to query.
     * @return The balance of the specified token ID for the account.
     */
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[account][id];
    }

    /**
     * @dev Returns the balances of multiple token IDs for a given account.
     * @param accounts The addresses of the accounts to query.
     * @param ids The token IDs to query.
     * @return A list of balances corresponding to the input accounts and token IDs.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and IDs length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev Approves or disapproves an operator for all tokens of a specific account.
     * @param operator The address of the operator.
     * @param approved True if the operator is approved, false to revoke approval.
     */
    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Returns whether an operator is approved for all tokens of a specific account.
     * @param account The address of the account.
     * @param operator The address of the operator.
     * @return True if the operator is approved, false otherwise.
     */
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev Safely transfers tokens from one address to another.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param id The token ID to transfer.
     * @param value The amount of tokens to transfer.
     * @param data Additional data with no specified format.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not owner nor approved");
        require(to != address(0), "ERC1155: transfer to the zero address");

        _balances[from][id] -= value;
        _balances[to][id] += value;

        emit TransferSingle(msg.sender, from, to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
    }

    /**
     * @dev Safely transfers a batch of tokens from one address to another.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param ids The token IDs to transfer.
     * @param values The amounts of tokens to transfer.
     * @param data Additional data with no specified format.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data) public {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not owner nor approved");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(ids.length == values.length, "ERC1155: ids and values length mismatch");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[from][id] -= value;
            _balances[to][id] += value;
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
    }

    /**
     * @dev Internal function to perform safe transfer acceptance check.
     * @param operator The address of the operator.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param id The token ID to transfer.
     * @param value The amount of tokens to transfer.
     * @param data Additional data with no specified format.
     */
    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 value, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @dev Internal function to perform safe batch transfer acceptance check.
     * @param operator The address of the operator.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param ids The token IDs to transfer.
     * @param values The amounts of tokens to transfer.
     * @param data Additional data with no specified format.
     */
    function _doSafeBatchTransferAcceptanceCheck(address operator, address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }
}

interface IERC1155Receiver {
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns (bytes4);
}