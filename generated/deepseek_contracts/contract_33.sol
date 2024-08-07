// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Base {
    uint public publicVar;
    uint internal internalVar;

    function publicFunction() public virtual {
        internalFunction();
    }

    function internalFunction() internal virtual {
        internalVar = 10;
    }

    function privateFunction() private {
        publicVar = 20;
    }
}

contract Child is Base {
    function publicFunction() public override {
        internalFunction();
    }

    function internalFunction() internal override {
        internalVar = 30;
    }

    function testPublicFunction() public {
        publicFunction();
    }

    function testInternalFunction() public {
        internalFunction();
    }

    function testPrivateFunction() public {
        // This will cause a compilation error because privateFunction is private
        // privateFunction();
    }
}