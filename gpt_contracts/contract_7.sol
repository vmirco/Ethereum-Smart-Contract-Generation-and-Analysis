// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeTransferLib { 
    function safeTransferETH(address to, uint256 value) public {
        // Transfer function here
    }
    
    function safeTransferToken(address token, address to, uint256 value) public {
        // Transfer function here
    }
}

contract StandardCReward {
    function setContributorReward(uint256 _reward) external {}
    function getReward(address _contributor) public view returns (uint256) {}
    function transferReward(address _contributor, address to, uint256 value) external {}
}

contract CAdapter {
    function getSpeeds() public view returns (uint256[] memory) {}
    function interact(address _user, bytes memory _data) external {}
}

interface IDivider {
    function divide(uint256 value, uint256 divisor) external pure returns(uint256);
}

interface IAddressBook {
    function getAddress(string memory name) external view returns (address);
}

contract CAdapters {
    CAdapter public cDAI;
    CAdapter public cETH;
    CAdapter public cUSDC;
    IDivider public divider;
    IAddressBook public addressBook;
    StandardCReward public cReward;

    constructor() {
        cDAI = new CAdapter();
        cETH = new CAdapter();
        cUSDC = new CAdapter();
        divider = IDivider(addressBook.getAddress("IDivider"));
        cReward = new StandardCReward();
    }

    function setContributorReward(uint256 _reward) external {
        cReward.setContributorReward(_reward);
    }

    function getReward(address contribAddress) public view returns(uint256) {
        return cReward.getReward(contribAddress);
    }

    function transferReward(address contribAddress, address to, uint256 value) external {
        cReward.transferReward(contribAddress, to, value);
    }

    function getSpeeds() public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        return (cDAI.getSpeeds(), cETH.getSpeeds(), cUSDC.getSpeeds());
    }

    function interact(string memory adapterName, address _user, bytes memory _data) external {
        CAdapter adapter;
        if (compare(adapterName, "cDAI")) {
            adapter = cDAI;
        } else if (compare(adapterName, "cETH")) {
            adapter = cETH;
        } else if (compare(adapterName, "cUSDC")) {
            adapter = cUSDC;
        } else {
            revert("Invalid adapter name");
        }
        adapter.interact(_user, _data);
    }

    function compare(string memory a, string memory b) private pure returns(bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}