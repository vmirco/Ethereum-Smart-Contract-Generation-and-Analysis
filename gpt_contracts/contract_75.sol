// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FactoryInstanceManager {

  struct Factory {
    address owner;
    bool isRetired;
    string name;
  }

  struct Instance {
    address factoryOwner;
    address owner;
    bool isRetired;
    string name;
  }

  mapping (address => Factory) public factories;
  mapping (address => Instance) public instances;
  address[] public factoryList;
  address[] public instanceList;

  function registerFactory(address _factory, string memory _name) public {
    Factory storage factory = factories[_factory];
    factory.owner = msg.sender;
    factory.isRetired = false;
    factory.name = _name;
    factoryList.push(_factory);
  }

  function registerInstance(address _factory, address _instance, string memory _name) public {
    require(factories[_factory].owner == msg.sender, "Only factory owners can register instances");
    Instance storage instance = instances[_instance];
    instance.factoryOwner = msg.sender;
    instance.owner = _instance;
    instance.isRetired = false;
    instance.name = _name;
    instanceList.push(_instance);
  }

  function retireFactory(address _factory) public {
    require(factories[_factory].owner == msg.sender, "Only factory owners can retire factories");
    factories[_factory].isRetired = true;
  }

  function retireInstance(address _instance) public {
    require(instances[_instance].factoryOwner == msg.sender, "Only instance owners can retire instances");
    instances[_instance].isRetired = true;
  }

  function getFactory(address _factory) public view returns (address, bool, string memory) {
    return (factories[_factory].owner, factories[_factory].isRetired, factories[_factory].name);
  }

  function getInstance(address _instance) public view returns (address, address, bool, string memory) {
    return (instances[_instance].factoryOwner, instances[_instance].owner, instances[_instance].isRetired, instances[_instance].name);
  }

  function getFactories(uint _start, uint _length) public view returns (address[] memory) {
    require(_start + _length <= factoryList.length, "Requested index out of bounds");
    address[] memory _factories = new address[](_length);
    for (uint i = _start; i < _start + _length; i++) {
      _factories[i - _start] = factoryList[i];
    }
    return _factories;
  }

  function getInstances(uint _start, uint _length) public view returns (address[] memory) {
    require(_start + _length <= instanceList.length, "Requested index out of bounds");
    address[] memory _instances = new address[](_length);
    for (uint i = _start; i < _start + _length; i++) {
      _instances[i - _start] = instanceList[i];
    }
    return _instances;
  }
}