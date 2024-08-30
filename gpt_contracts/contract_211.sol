pragma solidity ^0.8.0;

contract NodeStaking {
    // Define
    struct NodeList {
        uint256 amount; // amount of tokens in the node
        uint256 createdAt; // creation time
    }

    struct Stake {
        uint256 amount; // amount of tokens staked
        uint256 createdAt; // stake creation time
    }

    mapping(address => NodeList) nodeList; // Nodes
    mapping(address => mapping(address => Stake)) stakeList; // User Stakes
    address[] nodes; // All our nodes
    uint256 rewardsPerSecond = 1e18; // Rewards generated per second

    // Staking Event
    event Staking(address indexed _user, address _node, uint256 _amount);

    // Rewards Claiming Event
    event ClaimRewards(address indexed _user, uint256 _reward);

    // To check whether a Node exists
    modifier nodeExists(address _node) {
        require(nodeList[_node].createdAt > 0, "Node does not exist");
        _;
    }

    // Check whether an User has staked on a Node
    modifier hasStaked(address _user, address _node) {
        require(stakeList[_user][_node].createdAt > 0, "User has not staked on this Node");
        _;
    }

    // To initialize a Node
    function initializeNode(address _node, uint256 _amount) external {
        nodeList[_node] = NodeList(_amount, block.timestamp);
        nodes.push(_node);
    }

    // To Staking
    function stakeTokens(address _node, uint256 _amount) external nodeExists(_node) {
        // Add Token Transfer Code here
        // Update Stake
        stakeList[msg.sender][_node] = Stake(_amount, block.timestamp);
        nodeList[_node].amount += _amount;

        emit Staking(msg.sender, _node, _amount);
    }

    // Calculate Rewards
    function calculateReward(address _user, address _node) public view hasStaked(_user, _node) returns (uint256) {
        uint256 timeStaked = (block.timestamp - stakeList[_user][_node].createdAt); // in seconds
        uint256 reward = (stakeList[_user][_node].amount * rewardsPerSecond * timeStaked) / nodeList[_node].amount;
        return reward;
    }

    // Claim Reward
    function claimReward(address _node) external hasStaked(msg.sender, _node) {
        uint256 reward = calculateReward(msg.sender, _node);
        // Token Transfer code
        emit ClaimRewards(msg.sender, reward);
    }

    // Get Node Data
    function getNodeData(address _node) external view nodeExists(_node) returns (uint256, uint256) {
        return (nodeList[_node].amount, nodeList[_node].createdAt);
    }
    
    // Returns node list
    function getNodeList() public view returns (address[] memory) {
      return nodes;
    }    
}