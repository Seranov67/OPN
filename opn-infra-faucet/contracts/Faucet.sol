// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Faucet is Ownable {
    IERC20 public immutable token;
    uint256 public amountAllowed = 100 * 10 ** 18;
    uint256 public constant COOLDOWN = 24 hours;

    mapping(address => uint256) public lastAccessTime;

    event SendToken(address indexed to, uint256 amount);

    constructor(address tokenAddress) Ownable(msg.sender) {
        require(tokenAddress != address(0), "Faucet: invalid token address");
        token = IERC20(tokenAddress);
    }

    function requestTokens() external {
        require(
            block.timestamp >= lastAccessTime[msg.sender] + COOLDOWN,
            "Faucet: please wait 24 hours between requests"
        );

        uint256 balance = token.balanceOf(address(this));
        require(balance >= amountAllowed, "Faucet: insufficient balance");

        // checks-effects-interactions: update state before external call
        lastAccessTime[msg.sender] = block.timestamp;

        require(
            token.transfer(msg.sender, amountAllowed),
            "Faucet: transfer failed"
        );

        emit SendToken(msg.sender, amountAllowed);
    }

    function getFaucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function cooldownRemaining(address user) external view returns (uint256) {
        uint256 nextAllowed = lastAccessTime[user] + COOLDOWN;
        if (block.timestamp >= nextAllowed) {
            return 0;
        }
        return nextAllowed - block.timestamp;
    }

    function setAmountAllowed(uint256 newAmount) external onlyOwner {
        require(newAmount > 0, "Faucet: amount must be positive");
        amountAllowed = newAmount;
    }

    function withdrawAll(address to) external onlyOwner {
        require(to != address(0), "Faucet: invalid recipient");
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Faucet: nothing to withdraw");
        require(token.transfer(to, balance), "Faucet: withdraw failed");
    }
}
