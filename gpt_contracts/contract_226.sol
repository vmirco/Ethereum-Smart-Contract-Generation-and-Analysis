// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface GeneScience {
    function isGeneScience() external pure returns (bool);
    function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock) external returns (uint256);
}

interface PuppySports {
    function playGame(uint256 puppyId, uint256 betAmount) external;
}

contract PuppyAccessControl {
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    constructor() {
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
        cfoAddress = msg.sender;
    }

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }   

    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }
}

contract CryptoPuppies is PuppyAccessControl {
    struct Puppy {
        uint256 genes;
        uint64 birthTime;
    }

    Puppy[] public puppies;

    GeneScience public geneScience;
    PuppySports public puppySports;

    event NewPuppy(uint256 indexed puppyId, uint256 genes);
    event PuppyGamePlayed(uint256 indexed puppyId, uint256 betAmount);

    constructor() PuppyAccessControl() {}

    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScience candidateContract = GeneScience(_address);
        require(candidateContract.isGeneScience());
        geneScience = candidateContract;
    }

    function setPuppySportsAddress(address _address) external onlyCEO {
        PuppySports candidateContract = PuppySports(_address);
        require(candidateContract != PuppySports(address(0x0)));
        puppySports = candidateContract;
    }

    function createPuppy(uint256 _genes) external onlyCOO {
        uint256 newPuppyId = puppies.length;
        puppies.push(Puppy(_genes, uint64(block.timestamp)));
        emit NewPuppy(newPuppyId, _genes);
    }

    function mixGenes(uint256 _puppyId1, uint256 _puppyId2) external onlyCOO {
        Puppy storage puppy1 = puppies[_puppyId1];
        Puppy storage puppy2 = puppies[_puppyId2];
        uint256 newGenes = geneScience.mixGenes(puppy1.genes, puppy2.genes, block.number);
        createPuppy(newGenes);
    }

    function playGame(uint256 _puppyId, uint256 _betAmount) external onlyCOO {
        puppySports.playGame(_puppyId, _betAmount);
        emit PuppyGamePlayed(_puppyId, _betAmount);
    }
}