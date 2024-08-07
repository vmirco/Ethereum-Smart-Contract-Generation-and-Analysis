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

    event PuppyCreated(uint256 indexed puppyId, uint256 genes, uint256 birthTime);
    event GenesMixed(uint256 indexed puppyId1, uint256 indexed puppyId2, uint256 newGenes);
    event GamePlayed(uint256 indexed puppyId, uint256 score);

    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "Only CEO can perform this action");
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress, "Only CFO can perform this action");
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress, "Only COO can perform this action");
        _;
    }

    constructor(address _ceo, address _cfo, address _coo) {
        ceoAddress = _ceo;
        cfoAddress = _cfo;
        cooAddress = _coo;
    }

    function createPuppy(uint256 _genes) public onlyCOO {
        uint256 puppyId = puppies.length;
        puppies.push(Puppy(_genes, block.timestamp));
        emit PuppyCreated(puppyId, _genes, block.timestamp);
    }

    function mixGenes(uint256 _puppyId1, uint256 _puppyId2) public onlyCOO returns (uint256) {
        Puppy storage puppy1 = puppies[_puppyId1];
        Puppy storage puppy2 = puppies[_puppyId2];
        uint256 newGenes = puppy1.genes ^ puppy2.genes;
        uint256 newPuppyId = puppies.length;
        puppies.push(Puppy(newGenes, block.timestamp));
        emit GenesMixed(_puppyId1, _puppyId2, newGenes);
        return newGenes;
    }

    function playGame(uint256 _puppyId, uint256 _score) public onlyCFO {
        emit GamePlayed(_puppyId, _score);
    }

    function setCEO(address _newCEO) public onlyCEO {
        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) public onlyCEO {
        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) public onlyCEO {
        cooAddress = _newCOO;
    }
}