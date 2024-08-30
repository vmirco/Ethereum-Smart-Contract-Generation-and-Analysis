// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Pausable
 * @dev The Pausable contract allows the owner to pause and unpause the contract.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by the owner to pause, triggers stopped state.
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by the owner to unpause, returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title PaymentWithdrawable
 * @dev The PaymentWithdrawable contract allows the owner to withdraw payments to a payee address.
 */
contract PaymentWithdrawable is Ownable {
    mapping(address => uint256) private _balances;

    event PaymentWithdrawn(address indexed payee, uint256 amount);

    /**
     * @dev Withdraws the specified amount of wei to the payee address.
     * Can only be called by the owner.
     */
    function withdraw(address payable payee, uint256 amount) public onlyOwner {
        require(payee != address(0), "PaymentWithdrawable: payee is the zero address");
        require(_balances[payee] >= amount, "PaymentWithdrawable: insufficient balance");

        _balances[payee] -= amount;
        (bool success, ) = payee.call{value: amount}("");
        require(success, "PaymentWithdrawable: withdraw failed");

        emit PaymentWithdrawn(payee, amount);
    }

    /**
     * @dev Fallback function to receive payments.
     */
    receive() external payable {
        _balances[msg.sender] += msg.value;
    }
}

/**
 * @title FullContract
 * @dev The FullContract combines Ownable, Pausable, and PaymentWithdrawable functionalities.
 */
contract FullContract is Ownable, Pausable, PaymentWithdrawable {
    // This contract inherits from Ownable, Pausable, and PaymentWithdrawable,
    // providing ownership transfer, paused state management, and payment withdrawal capabilities.
}