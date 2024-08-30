// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IComptroller {
    function claimComp(address holder) external;
    function getCompAddress() external view returns (address);
}

contract CompoundInteraction {
    IComptroller public comptroller;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
        owner = msg.sender;
    }

    function claimComp() external onlyOwner {
        try comptroller.claimComp(owner) {
            // Successfully claimed COMP
        } catch {
            revert("Claiming COMP failed");
        }
    }

    function getCompAddress() external view returns (address) {
        return comptroller.getCompAddress();
    }

    function changeComptroller(address _newComptroller) external onlyOwner {
        comptroller = IComptroller(_newComptroller);
    }
}