// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOManagement {

    struct DAO {
        bytes32 name;
        address owner;
        address[] members;
    }

    struct Script {
        string name;
        bytes evmCode;
    }

    mapping(bytes32 => DAO) public daos;
    mapping(address => bytes32[]) public daoRegistry;
    mapping(address => Script[]) public scriptRegistry;

    event DaoDeployed(bytes32 indexed daoName, address indexed owner);
    event ScriptRegistered(string scriptName, address indexed owner);

    modifier daoOwner(bytes32 _name) {
        require(daos[_name].owner == msg.sender, "Not the DAO owner");
        _;
    }

    function deployDAO(bytes32 _name) public {
        require(daos[_name].owner == address(0), "DAO with this name already exists");
        DAO storage dao = daos[_name];
        dao.name = _name;
        dao.owner = msg.sender;

        daoRegistry[msg.sender].push(_name);

        emit DaoDeployed(_name, msg.sender);
    }

    function manageDAO(bytes32 _name, address _newMember) public daoOwner(_name) {
        daos[_name].members.push(_newMember);
    }

    function registerScript(string memory _name, bytes memory _evmCode) public {
        scriptRegistry[msg.sender].push(Script(_name, _evmCode));
        emit ScriptRegistered(_name, msg.sender);
    }

    function getDAOsByOwner() public view returns (bytes32[] memory) {
        return daoRegistry[msg.sender];
    }

    function getScriptsByOwner() public view returns (Script[] memory) {
        return scriptRegistry[msg.sender];
    }
}