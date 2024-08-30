pragma solidity ^0.8.0;

interface Comptroller {
    function claimComp(address holder) external;
    function getCompAddress() external view returns (address);
}

contract CompoundCompClaimer {

    // Instance of the Comptroller contract
    Comptroller private comptroller;

    // To keep the address that can claim COMP
    mapping(address => bool) claimers;

    // To emit when a claimer address is added or removed
    event ClaimerAdded(address addr);
    event ClaimerRemoved(address addr);

    constructor(address _comptroller) {
        require(_comptroller != address(0), "Invalid Comptroller address");
        comptroller = Comptroller(_comptroller);
    }

    function addClaimer(address claimer) public {
        require(claimer != address(0), "Invalid claimer address");
        require(!claimers[claimer],"Address is already a claimer");
        claimers[claimer] = true;
        emit ClaimerAdded(claimer);
    }

    function removeClaimer(address claimer) public {
        require(claimers[claimer], "Address is not a claimer");
        delete claimers[claimer];
        emit ClaimerRemoved(claimer);
    }
    
    function claimCOMP() public {
        require(claimers[msg.sender], "Not authorized to claim");
        comptroller.claimComp(msg.sender);
    }
    
    function getCOMPFeeAddress() public view returns (address) {
        return comptroller.getCompAddress();
    }
}