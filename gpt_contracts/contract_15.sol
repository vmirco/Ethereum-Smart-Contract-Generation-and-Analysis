pragma solidity ^0.8.0;

contract IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    function balanceOf(address account) public view virtual returns (uint256);
}

contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner.");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address.");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KaijuKingzNFT is Ownable {
    struct Kaiju {
        string name;
        string bio;
        bool revealed;
    }

    uint public totalKaijus;
    mapping(uint => Kaiju) public kaijus;
    mapping(uint => address) public kaijuOwner;

    function createKaiju(string memory name, string memory bio) public onlyOwner {
        kaijus[totalKaijus] = Kaiju(name, bio, false);
        kaijuOwner[totalKaijus] = msg.sender;
        totalKaijus++;
    }

    function revealKaiju(uint id) public {
        require(msg.sender == kaijuOwner[id], 'not the owner');
        kaijus[id].revealed = true;
    }

    function updateKaiju(uint id, string memory name, string memory bio) public {
        require(msg.sender == kaijuOwner[id], 'not the owner');
        kaijus[id].name = name;
        kaijus[id].bio = bio;
    }

    function fuseKaijus(uint id1, uint id2, string memory fusedName, string memory fusedBio) public {
        require(msg.sender == kaijuOwner[id1] && msg.sender == kaijuOwner[id2], 'not the owner');
        
        delete kaijus[id1];
        delete kaijus[id2];
        delete kaijuOwner[id1];
        delete kaijuOwner[id2];
        
        kaijus[totalKaijus] = Kaiju(fusedName, fusedBio, true);
        kaijuOwner[totalKaijus] = msg.sender;
        totalKaijus++;
    }
}