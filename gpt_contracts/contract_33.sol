// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Base {
    
    string internal internalStateVariable = "Internal State Variable";
    string public publicStateVariable = "Public State Variable";

    function privateFunction() private pure returns(string memory) {
        return "Private Function Executed";
    }

    function internalFunction() internal pure returns(string memory) {
        return "Internal Function Executed";
    }
    
    function publicFunction() public pure returns(string memory) {
        return "Public Function Executed";
    }

    function testPrivateFunction() public pure returns(string memory) {
        //uncommenting this would result in an error, as private functions can't be accessed outside the contract
        //return privateFunction();
    }

    function testInternalFunction() public pure returns(string memory) {
        //uncommenting this would work, as this function exists inside the same contract
        //return internalFunction();
    }

    function testPublicFunction() public pure returns(string memory) {
        return publicFunction();
    }
}

contract Child is Base {

    function overrideInternalFunction() internal pure override returns(string memory) {
        return "Overridden Internal Function Executed";
    }
    
    function testOverriddenInternalFunction() public pure returns(string memory) {
        //uncommenting this would work, as this function is callable in this contract
        //return overrideInternalFunction();
    }

    function testInheritedPublicFunction() public pure returns(string memory) {
        return publicFunction();
    }
}