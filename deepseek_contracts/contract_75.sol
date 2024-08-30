// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FactoryManager {
    struct Factory {
        address owner;
        string name;
        bool isActive;
    }

    struct Instance {
        address factoryAddress;
        address instanceAddress;
        string name;
        bool isActive;
    }

    Factory[] public factories;
    mapping(address => Instance[]) public instances;
    mapping(address => bool) public factoryExists;
    mapping(address => mapping(address => bool)) public instanceExists;

    event FactoryRegistered(address indexed owner, address indexed factoryAddress, string name);
    event InstanceRegistered(address indexed factoryAddress, address indexed instanceAddress, string name);
    event FactoryRetired(address indexed factoryAddress);
    event InstanceRetired(address indexed instanceAddress);

    function registerFactory(address _factoryAddress, string memory _name) public {
        require(!factoryExists[_factoryAddress], "Factory already registered");
        factories.push(Factory({owner: msg.sender, name: _name, isActive: true}));
        factoryExists[_factoryAddress] = true;
        emit FactoryRegistered(msg.sender, _factoryAddress, _name);
    }

    function registerInstance(address _factoryAddress, address _instanceAddress, string memory _name) public {
        require(factoryExists[_factoryAddress], "Factory not registered");
        require(!instanceExists[_factoryAddress][_instanceAddress], "Instance already registered");
        instances[_factoryAddress].push(Instance({factoryAddress: _factoryAddress, instanceAddress: _instanceAddress, name: _name, isActive: true}));
        instanceExists[_factoryAddress][_instanceAddress] = true;
        emit InstanceRegistered(_factoryAddress, _instanceAddress, _name);
    }

    function retireFactory(address _factoryAddress) public {
        require(factoryExists[_factoryAddress], "Factory not registered");
        for (uint i = 0; i < factories.length; i++) {
            if (factories[i].owner == msg.sender && factories[i].isActive) {
                factories[i].isActive = false;
                emit FactoryRetired(_factoryAddress);
                break;
            }
        }
    }

    function retireInstance(address _factoryAddress, address _instanceAddress) public {
        require(instanceExists[_factoryAddress][_instanceAddress], "Instance not registered");
        for (uint i = 0; i < instances[_factoryAddress].length; i++) {
            if (instances[_factoryAddress][i].instanceAddress == _instanceAddress && instances[_factoryAddress][i].isActive) {
                instances[_factoryAddress][i].isActive = false;
                emit InstanceRetired(_instanceAddress);
                break;
            }
        }
    }

    function getFactories(uint _start, uint _count) public view returns (Factory[] memory) {
        uint end = _start + _count;
        if (end > factories.length) {
            end = factories.length;
        }
        Factory[] memory result = new Factory[](end - _start);
        for (uint i = _start; i < end; i++) {
            result[i - _start] = factories[i];
        }
        return result;
    }

    function getInstances(address _factoryAddress, uint _start, uint _count) public view returns (Instance[] memory) {
        uint end = _start + _count;
        if (end > instances[_factoryAddress].length) {
            end = instances[_factoryAddress].length;
        }
        Instance[] memory result = new Instance[](end - _start);
        for (uint i = _start; i < end; i++) {
            result[i - _start] = instances[_factoryAddress][i];
        }
        return result;
    }
}