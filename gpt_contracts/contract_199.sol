// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    );
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract YourContract {
    using SafeERC20 for IERC20;

    mapping(address => uint) nonces;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    address public immutable owner;
    AggregatorV3Interface internal priceFeed;

    constructor (address aggregator_) {
        owner = msg.sender;
        
        priceFeed = AggregatorV3Interface(aggregator_);
    }

    function latestPrice() public view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                block.chainid,
                blockhash(block.number - 1),
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "YourContract::permit: signature does not match");
        _approve(owner, spender, value);
    }
   
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "YourContract: approve from the zero address");
        require(spender != address(0), "YourContract: approve to the zero address");

        IERC20(owner).approve(spender, amount);
        emit Approval(owner, spender, amount);
    }

    event Approval(address indexed owner, address indexed spender, uint value);
}