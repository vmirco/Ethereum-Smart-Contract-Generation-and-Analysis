// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract AccessControl is Context {
    mapping (bytes32 => mapping (address => bool)) private _roles;

    event RoleAssigned(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    function isAdmin(address account) public view returns (bool) {
        return _roles[keccak256("ADMIN_ROLE")][account];
    }

    function assignRole(bytes32 role, address account) public virtual {
        require(_roles[keccak256("ADMIN_ROLE")][_msgSender()], "Access Control: must have admin role to assign");
        _roles[role][account] = true;
        emit RoleAssigned(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(_roles[keccak256("ADMIN_ROLE")][_msgSender()], "Access Control: must have admin role to revoke");
        _roles[role][account] = false;
        emit RoleRevoked(role, account);
    }
}

contract Pausable is AccessControl {
    event Pause();
    event Unpause();

    bool private _paused;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    function pause() public virtual {
        require(isAdmin(_msgSender()), "Pausable: must have admin role to pause");
        _paused = true;

        emit Pause();
    }

    function unpause() public virtual {
        require(isAdmin(_msgSender()), "Pausable: must have admin role to unpause");
        _paused = false;

        emit Unpause();
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }
}

contract ReentrancyGuard {
    uint private _guardCounter = 1;

    modifier nonReentrant() {
        _guardCounter += 1;
        uint localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal virtual {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: TRANSFER_FAILED');
    }

    function safeApprove(address token, address spender, uint256 value) internal virtual {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, spender, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: APPROVE_FAILED');
    }
}

contract VaultManager is Context, Pausable, ReentrancyGuard, SafeERC20 {
    struct Vault {
        uint256 asset;
        uint256 debt;
    }

    mapping (address => Vault) private _vaults;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    function deposit(uint256 amount) public virtual nonReentrant whenNotPaused {
        _vaults[_msgSender()].asset += amount;

        emit Deposit(_msgSender(), amount);
    }

    function borrow(uint256 amount) public virtual nonReentrant whenNotPaused {
        require(_vaults[_msgSender()].asset >= amount, "VaultManager: borrow amount exceeds balance");
        _vaults[_msgSender()].debt += amount;

        emit Borrow(_msgSender(), amount);
    }

    function repay(uint256 amount) public virtual nonReentrant whenNotPaused {
        require(_vaults[_msgSender()].debt >= amount, "VaultManager: repay amount exceeds debt");
        _vaults[_msgSender()].debt -= amount;

        emit Repay(_msgSender(), amount);
    }

    function getAsset(address account) public view returns (uint256) {
        return _vaults[account].asset;
    }

    function getDebt(address account) public view returns (uint256) {
        return _vaults[account].debt;
    }

    function getEquity(address account) public view returns (uint256) {
        return _vaults[account].asset - _vaults[account].debt;
    }
}