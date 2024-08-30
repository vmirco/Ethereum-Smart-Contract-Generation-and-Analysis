// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoPuppies {
    struct Puppy {
        uint256 genes;
        uint256 birthTime;
    }

    Puppy[] public puppies;

    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    event PuppyCreated(uint256 puppyId, uint256 genes, uint256 birthTime);
    event GenesMixed(uint256 puppyId1, uint256 puppyId2, uint256 newGenes);
    event GamePlayed(uint256 puppyId, uint256 score);

    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "Only CEO can call this function");
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress, "Only CFO can call this function");
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress, "Only COO can call this function");
        _;
    }

    constructor(address _ceoAddress, address _cfoAddress, address _cooAddress) {
        ceoAddress = _ceoAddress;
        cfoAddress = _cfoAddress;
        cooAddress = _cooAddress;
    }

    function createPuppy(uint256 _genes) external onlyCOO {
        Puppy memory newPuppy = Puppy({
            genes: _genes,
            birthTime: block.timestamp
        });
        uint256 newPuppyId = puppies.length;
        puppies.push(newPuppy);
        emit PuppyCreated(newPuppyId, _genes, block.timestamp);
    }

    function mixGenes(uint256 _puppyId1, uint256 _puppyId2) external onlyCOO returns (uint256) {
        require(_puppyId1 < puppies.length && _puppyId2 < puppies.length, "Puppy ID out of range");
        uint256 newGenes = _mixGenes(puppies[_puppyId1].genes, puppies[_puppyId2].genes);
        emit GenesMixed(_puppyId1, _puppyId2, newGenes);
        return newGenes;
    }

    function playGame(uint256 _puppyId) external onlyCFO returns (uint256) {
        require(_puppyId < puppies.length, "Puppy ID out of range");
        uint256 score = _playGame(puppies[_puppyId].genes);
        emit GamePlayed(_puppyId, score);
        return score;
    }

    function _mixGenes(uint256 _genes1, uint256 _genes2) internal pure returns (uint256) {
        return (_genes1 + _genes2) / 2;
    }

    function _playGame(uint256 _genes) internal pure returns (uint256) {
        return _genes % 100; // Simple game logic for demonstration
    }

    function setCEO(address _newCEO) external onlyCEO {
        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) external onlyCEO {
        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO {
        cooAddress = _newCOO;
    }
}