// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns(bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpause();
    }
}

contract InsuranceManagement is Pausable {

    struct Insurance {
        uint id;
        string name;
        uint premium;
        uint capital;
    }

    Insurance[] public insuranceProducts;
    mapping (address => uint[]) public insuranceOwners;
    mapping (uint => uint) public insuranceStatus;

    function createInsurance(string memory name, uint premium, uint capital) public onlyOwner whenNotPaused {
        uint id = insuranceProducts.length;
        insuranceProducts.push(Insurance(id, name, premium, capital));
    }

    function purchaseInsurance(uint id) public payable whenNotPaused {
        require(msg.value == insuranceProducts[id].premium);
        insuranceOwners[msg.sender].push(id);
        insuranceStatus[id]++;
    }

    function cancelInsurance(uint id) public whenNotPaused {
        require(insuranceOwners[msg.sender][id] == id);
        delete insuranceOwners[msg.sender][id];
        insuranceStatus[id]--;
    }

    function updateInsuranceStatus(uint id, uint status) public onlyOwner whenNotPaused {
        insuranceStatus[id] = status;
    }
}