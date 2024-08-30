// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Base {
    uint public publicVar;
    uint internal internalVar;

    function publicFunction() public {
        privateFunction();
        internalFunction();
    }

    function privateFunction() private {
        // Private function logic
    }

    function internalFunction() internal virtual {
        // Internal function logic
    }
}

contract Child is Base {
    function overrideInternalFunction() public {
        internalFunction();
    }

    function internalFunction() internal virtual override {
        // Override internal function logic
    }

    function testVisibility() public {
        publicFunction(); // Call public function from Base
        overrideInternalFunction(); // Call overridden internal function
        // privateFunction(); // This line would cause an error if uncommented, as private functions are inaccessible outside the contract
    }
}