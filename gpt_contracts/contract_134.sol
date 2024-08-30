pragma solidity ^0.8.0;

contract AssertTest {
    event Log(string message);
    event Error(string message);

    // A function to be tested
    function add(uint a, uint b) public pure returns (uint) {
        uint c = a + b;
        assert(c >= a); // Test case for successful assertion
        return c;
    }
    
    // A function for testing failed assertion
    function testFailAdd(uint a, uint b) public {
        try add(a, b) {
            emit Log("Passed");
        } catch Error(string memory reason) {
            emit Error(reason);
        } catch (bytes memory /*lowLevelData*/) {
            emit Error("Failed: Fallback errored");
        }
    }

    // A function for testing successful assertion
    function testPassAdd(uint a, uint b) public {
        try add(a, b) {
            emit Log("Passed");
        } catch Error(string memory reason) {
            emit Error(reason);
        } catch (bytes memory /*lowLevelData*/) {
            emit Error("Passed: Fallback errored");
        }
    }

    // A function for testing error handling
    function testErrorHandling(uint a, uint b) public {
        try add(a, b) {
            emit Log("Passed");
        } catch Error(string memory reason) {
            emit Error(reason);
        } catch (bytes memory /*lowLevelData*/) {
            emit Error("Passed: Fallback errored");
        }
    }
}