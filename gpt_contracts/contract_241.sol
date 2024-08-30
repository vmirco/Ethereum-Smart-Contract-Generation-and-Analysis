// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAnyswapV3ERC20 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MyToken is IAnyswapV3ERC20 {
  string public constant name = 'MyToken';
  string public constant symbol = 'MTK';
  uint8 public constant decimals = 18;
  uint  public totalSupply = 10000 * (10 ** uint(decimals));
  
  // Create a mapping to hold the balance of each owner account, accessible by address.
  mapping (address => uint256) private _balances;
  // Create a mapping from an owner to an operator, to indicate that the operator has been approved to manage the owner's tokens.
  mapping (address => mapping (address => uint256)) private _allowances;

  bytes32 public override constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  bytes32 public override DOMAIN_SEPARATOR;
  mapping (address => uint256) public override nonces;

  constructor() {
      DOMAIN_SEPARATOR = keccak256(
          abi.encode(
              keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
              keccak256(bytes(name)),
              keccak256(bytes("1")),
              block.chainid,
              address(this)
          )
      );
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), 'ERC20: mint to the zero address');

    totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(currentAllowance >= amount, 'ERC20: transfer amount exceeds allowance');
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, 'ERC20: transfer amount exceeds balance');
    _balances[sender] = senderBalance - amount;
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
    require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

    bytes32 structHash = keccak256(
        abi.encode(
            PERMIT_TYPEHASH,
            owner,
            spender,
            value,
            nonces[owner]++,
            deadline
        )
    );

    bytes32 hash = keccak256(
        abi.encodePacked(
            '\x19\x01',
            DOMAIN_SEPARATOR,
            structHash
        )
    );

    address signer = ecrecover(hash, v, r, s);
    require(signer == owner, "ERC20Permit: invalid signature");

    _approve(owner, spender, value);
  }
}