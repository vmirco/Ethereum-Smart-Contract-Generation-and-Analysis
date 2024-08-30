pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MembershipNFT is ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct SubscriptionPlan {
        uint256 duration; // in days
        uint256 price; // in wei
    }

    struct UserSubscription {
        uint256 expirationDate;
        uint256 planId;
    }

    uint256 private _currentTokenId = 0; // Current Token ID
    
    uint256 private _currentPlanId = 0; // Current Plan ID

    mapping(uint256 => SubscriptionPlan) private _subscriptionPlans; // Plan ID => Plan Details
    mapping(address => UserSubscription) private _userSubscriptions; // User Address => Subscription Details
    mapping(uint256 => address) private _tokenOwners; // Token ID => Owner Address

    constructor() ERC721("Membership NFT", "MNFT") {}

    /**
     * @dev Create a new subscription plan.
     */
    function createSubscriptionPlan(uint256 duration, uint256 price)
        public
        onlyOwner
    {
        _subscriptionPlans[_currentPlanId] = SubscriptionPlan(duration, price);
        _currentPlanId++;
    }

    /**
     * @dev Subscribe the sender to a plan.
     */
    function subscribeToPlan(uint256 planId) public payable nonReentrant {
        require(
            msg.value >= _subscriptionPlans[planId].price,
            "Insufficient funds sent"
        );
        require(
            _userSubscriptions[msg.sender].expirationDate <= block.timestamp,
            "Existing subscription must have expired"
        );

        _userSubscriptions[msg.sender] = UserSubscription(
            block.timestamp.add(_subscriptionPlans[planId].duration * 1 days),
            planId
        );
    }

    /**
     * @dev Mint a new token to the sender.
     */
    function mintToken() public {
        require(
            _userSubscriptions[msg.sender].expirationDate >= block.timestamp,
            "Subscription must be active"
        );

        _mint(msg.sender, _currentTokenId);
        _tokenOwners[_currentTokenId] = msg.sender;
        _currentTokenId++;
    }

    /**
     * @dev Get the details of the sender's subscription.
     */
    function getUserSubscriptionDetails(address userAddress)
        public
        view
        returns (UserSubscription memory)
    {
        return _userSubscriptions[userAddress];
    }

    /**
     * @dev Return the owner of a token.
     */
    function ownerOf(uint256 tokenId) public view 
        override returns (address) 
    {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "Nonexistent token");

        return owner;
    }
}