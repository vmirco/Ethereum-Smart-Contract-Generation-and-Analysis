// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETHOmnibridgeRouter {
    address public immutable mediatorContractOnOtherSide;
    address payable public immutable wethContract;

    constructor(address _mediatorContractOnOtherSide, address payable _wethContract) {
        mediatorContractOnOtherSide = _mediatorContractOnOtherSide;
        wethContract = _wethContract;
    }

    function relayTokens(uint256 _value) public payable {
        require(msg.value > 0 && _value > 0, "Invalid values provided");
        
        wethContract.transfer(msg.value);

        bytes4 methodSelector = IERC20(wethContract).approve.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, mediatorContractOnOtherSide, _value);
        (bool success,) = wethContract.call(data);
        require(success, "Cannot approve");

        methodSelector = ITokenMediator(mediatorContractOnOtherSide).relayTokens.selector;
        data = abi.encodeWithSelector(methodSelector, wethContract, msg.sender, _value, new bytes(0));
        
        (success,) = mediatorContractOnOtherSide.call(data);
        require(success, "Relay failed");

        emit RelayTokens(msg.sender, _value);
    }

    event RelayTokens(address indexed sender, uint256 value);
}

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
}

interface ITokenMediator {
    function relayTokens(address token, address _receiver, uint256 _value, bytes calldata _data) external;
}