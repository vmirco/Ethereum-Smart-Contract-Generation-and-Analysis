// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOFactory {
    struct DAO {
        address daoAddress;
        string name;
        bool active;
    }

    struct EVMScriptRegistry {
        address registryAddress;
        string description;
        bool active;
    }

    DAO[] public daos;
    EVMScriptRegistry[] public registries;
    mapping(address => bool) public isDAOAdmin;
    mapping(address => bool) public isRegistryAdmin;

    event DAOCreated(address indexed daoAddress, string name);
    event DAOActivated(address indexed daoAddress);
    event DAODeactivated(address indexed daoAddress);
    event EVMScriptRegistryCreated(address indexed registryAddress, string description);
    event EVMScriptRegistryActivated(address indexed registryAddress);
    event EVMScriptRegistryDeactivated(address indexed registryAddress);

    modifier onlyDAOAdmin() {
        require(isDAOAdmin[msg.sender], "Not a DAO admin");
        _;
    }

    modifier onlyRegistryAdmin() {
        require(isRegistryAdmin[msg.sender], "Not a Registry admin");
        _;
    }

    constructor() {
        isDAOAdmin[msg.sender] = true;
        isRegistryAdmin[msg.sender] = true;
    }

    function createDAO(address _daoAddress, string memory _name) public onlyDAOAdmin {
        daos.push(DAO(_daoAddress, _name, true));
        emit DAOCreated(_daoAddress, _name);
    }

    function activateDAO(address _daoAddress) public onlyDAOAdmin {
        for (uint i = 0; i < daos.length; i++) {
            if (daos[i].daoAddress == _daoAddress) {
                daos[i].active = true;
                emit DAOActivated(_daoAddress);
                break;
            }
        }
    }

    function deactivateDAO(address _daoAddress) public onlyDAOAdmin {
        for (uint i = 0; i < daos.length; i++) {
            if (daos[i].daoAddress == _daoAddress) {
                daos[i].active = false;
                emit DAODeactivated(_daoAddress);
                break;
            }
        }
    }

    function createEVMScriptRegistry(address _registryAddress, string memory _description) public onlyRegistryAdmin {
        registries.push(EVMScriptRegistry(_registryAddress, _description, true));
        emit EVMScriptRegistryCreated(_registryAddress, _description);
    }

    function activateEVMScriptRegistry(address _registryAddress) public onlyRegistryAdmin {
        for (uint i = 0; i < registries.length; i++) {
            if (registries[i].registryAddress == _registryAddress) {
                registries[i].active = true;
                emit EVMScriptRegistryActivated(_registryAddress);
                break;
            }
        }
    }

    function deactivateEVMScriptRegistry(address _registryAddress) public onlyRegistryAdmin {
        for (uint i = 0; i < registries.length; i++) {
            if (registries[i].registryAddress == _registryAddress) {
                registries[i].active = false;
                emit EVMScriptRegistryDeactivated(_registryAddress);
                break;
            }
        }
    }

    function addDAOAdmin(address _admin) public onlyDAOAdmin {
        isDAOAdmin[_admin] = true;
    }

    function removeDAOAdmin(address _admin) public onlyDAOAdmin {
        isDAOAdmin[_admin] = false;
    }

    function addRegistryAdmin(address _admin) public onlyRegistryAdmin {
        isRegistryAdmin[_admin] = true;
    }

    function removeRegistryAdmin(address _admin) public onlyRegistryAdmin {
        isRegistryAdmin[_admin] = false;
    }
}