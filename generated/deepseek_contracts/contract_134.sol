// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AssertionContract {
    event AssertionResult(bool success, string message);

    function assertSuccess() public {
        bool condition = true;
        assert(condition);
        emit AssertionResult(true, "Assertion passed successfully.");
    }

    function assertFailure() public {
        bool condition = false;
        try this.customAssert(condition) {
            emit AssertionResult(true, "Unexpected success in assertFailure.");
        } catch Error(string memory reason) {
            emit AssertionResult(false, reason);
        } catch {
            emit AssertionResult(false, "An unknown error occurred.");
        }
    }

    function assertErrorHandling() public {
        bool condition = false;
        try this.customAssert(condition) {
            emit AssertionResult(true, "Unexpected success in assertErrorHandling.");
        } catch Error(string memory reason) {
            emit AssertionResult(false, reason);
        } catch {
            emit AssertionResult(false, "An unknown error occurred.");
        }
    }

    function customAssert(bool condition) public pure {
        if (!condition) {
            revert("Assertion failed.");
        }
    }
}