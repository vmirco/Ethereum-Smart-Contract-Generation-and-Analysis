// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAO {
    struct DAOInfo {
        address owner;
        string name;
        bool active;
    }

    struct EVMScriptRegistry {
        address owner;
        string description;
        bytes script;
    }

    mapping(address => DAOInfo) public daos;
    mapping(address => EVMScriptRegistry) public evmScriptRegistries;
    mapping(address => mapping(address => bool)) public daoPermissions;
    mapping(address => mapping(address => bool)) public registryPermissions;

    event DAOCreated(address indexed daoAddress, string name);
    event DAOActivated(address indexed daoAddress);
    event DAODeactivated(address indexed daoAddress);
    event EVMScriptRegistered(address indexed registryAddress, string description);
    event PermissionGranted(address indexed grantor, address indexed grantee, bool isDAO);
    event PermissionRevoked(address indexed revoker, address indexed revokee, bool isDAO);

    modifier onlyDAOOwner(address daoAddress) {
        require(daos[daoAddress].owner == msg.sender, "Not the DAO owner");
        _;
    }

    modifier onlyRegistryOwner(address registryAddress) {
        require(evmScriptRegistries[registryAddress].owner == msg.sender, "Not the registry owner");
        _;
    }

    function createDAO(string memory name) public {
        address daoAddress = address(new DAOInstance(name));
        daos[daoAddress] = DAOInfo({owner: msg.sender, name: name, active: true});
        emit DAOCreated(daoAddress, name);
    }

    function activateDAO(address daoAddress) public onlyDAOOwner(daoAddress) {
        daos[daoAddress].active = true;
        emit DAOActivated(daoAddress);
    }

    function deactivateDAO(address daoAddress) public onlyDAOOwner(daoAddress) {
        daos[daoAddress].active = false;
        emit DAODeactivated(daoAddress);
    }

    function registerEVMScript(string memory description, bytes memory script) public {
        address registryAddress = address(new EVMScriptRegistryInstance(description, script));
        evmScriptRegistries[registryAddress] = EVMScriptRegistry({owner: msg.sender, description: description, script: script});
        emit EVMScriptRegistered(registryAddress, description);
    }

    function grantPermission(address grantee, bool isDAO) public {
        if (isDAO) {
            daoPermissions[msg.sender][grantee] = true;
        } else {
            registryPermissions[msg.sender][grantee] = true;
        }
        emit PermissionGranted(msg.sender, grantee, isDAO);
    }

    function revokePermission(address revokee, bool isDAO) public {
        if (isDAO) {
            daoPermissions[msg.sender][revokee] = false;
        } else {
            registryPermissions[msg.sender][revokee] = false;
        }
        emit PermissionRevoked(msg.sender, revokee, isDAO);
    }
}

contract DAOInstance {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract EVMScriptRegistryInstance {
    string public description;
    bytes public script;

    constructor(string memory _description, bytes memory _script) {
        description = _description;
        script = _script;
    }
}