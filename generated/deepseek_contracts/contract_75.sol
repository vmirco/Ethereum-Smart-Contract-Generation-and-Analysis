// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Registry {
    struct Factory {
        uint256 id;
        string name;
        bool isActive;
    }

    struct Instance {
        uint256 id;
        uint256 factoryId;
        string name;
        bool isActive;
    }

    Factory[] public factories;
    Instance[] public instances;
    mapping(uint256 => uint256[]) public factoryInstances;

    event FactoryRegistered(uint256 indexed id, string name);
    event InstanceRegistered(uint256 indexed id, uint256 factoryId, string name);
    event FactoryRetired(uint256 indexed id);
    event InstanceRetired(uint256 indexed id);

    function registerFactory(string memory _name) public {
        uint256 id = factories.length;
        factories.push(Factory(id, _name, true));
        emit FactoryRegistered(id, _name);
    }

    function registerInstance(uint256 _factoryId, string memory _name) public {
        require(_factoryId < factories.length, "Invalid factory ID");
        require(factories[_factoryId].isActive, "Factory is retired");
        uint256 id = instances.length;
        instances.push(Instance(id, _factoryId, _name, true));
        factoryInstances[_factoryId].push(id);
        emit InstanceRegistered(id, _factoryId, _name);
    }

    function retireFactory(uint256 _id) public {
        require(_id < factories.length, "Invalid factory ID");
        factories[_id].isActive = false;
        emit FactoryRetired(_id);
    }

    function retireInstance(uint256 _id) public {
        require(_id < instances.length, "Invalid instance ID");
        instances[_id].isActive = false;
        emit InstanceRetired(_id);
    }

    function getFactory(uint256 _id) public view returns (uint256, string memory, bool) {
        require(_id < factories.length, "Invalid factory ID");
        Factory memory factory = factories[_id];
        return (factory.id, factory.name, factory.isActive);
    }

    function getInstance(uint256 _id) public view returns (uint256, uint256, string memory, bool) {
        require(_id < instances.length, "Invalid instance ID");
        Instance memory instance = instances[_id];
        return (instance.id, instance.factoryId, instance.name, instance.isActive);
    }

    function getFactories(uint256 _start, uint256 _count) public view returns (Factory[] memory) {
        uint256 end = _start + _count;
        if (end > factories.length) {
            end = factories.length;
        }
        Factory[] memory result = new Factory[](end - _start);
        for (uint256 i = _start; i < end; i++) {
            result[i - _start] = factories[i];
        }
        return result;
    }

    function getInstances(uint256 _start, uint256 _count) public view returns (Instance[] memory) {
        uint256 end = _start + _count;
        if (end > instances.length) {
            end = instances.length;
        }
        Instance[] memory result = new Instance[](end - _start);
        for (uint256 i = _start; i < end; i++) {
            result[i - _start] = instances[i];
        }
        return result;
    }
}