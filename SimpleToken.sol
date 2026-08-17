// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal ERC-20 Token (BSC ready)
contract SimpleToken {
    // ✅ Keep the quotation marks when replacing these values
    string public name = "YOUR_TOKEN_NAME";   // <-- Replace with your token name, e.g. "BradfordCoin"
    string public symbol = "YOUR_SYMBOL";     // <-- Replace with your token symbol, e.g. "BRC"
    uint8 public decimals = 18;               // Standard, do not change
    uint256 public totalSupply = 1000000 * 10**18; // Fixed supply: 1,000,000 tokens

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ✅ Replace "receiver" with your wallet address to receive all tokens at launch
    constructor(address receiver) {
        balanceOf[receiver] = totalSupply;
        emit Transfer(address(0), receiver, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}
