// SPDX-License-Identifier: MIT
// Для Remix IDE — копія contracts/Faucet.sol
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Faucet {
    IERC20 public immutable token;
    uint256 public constant DRIP_AMOUNT = 100 * 10 ** 18;
    uint256 public constant COOLDOWN = 24 hours;

    mapping(address => uint256) public lastAccessTime;

    event SendToken(address indexed to, uint256 amount);

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Faucet: invalid token address");
        token = IERC20(tokenAddress);
    }

    function requestTokens() external {
        require(
            block.timestamp >= lastAccessTime[msg.sender] + COOLDOWN,
            "Faucet: please wait 24 hours between requests"
        );

        uint256 balance = token.balanceOf(address(this));
        require(balance >= DRIP_AMOUNT, "Faucet: insufficient balance");

        lastAccessTime[msg.sender] = block.timestamp;

        require(
            token.transfer(msg.sender, DRIP_AMOUNT),
            "Faucet: transfer failed"
        );

        emit SendToken(msg.sender, DRIP_AMOUNT);
    }

    function getFaucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function timeUntilNextRequest(address user) external view returns (uint256) {
        uint256 nextAllowed = lastAccessTime[user] + COOLDOWN;
        if (block.timestamp >= nextAllowed) {
            return 0;
        }
        return nextAllowed - block.timestamp;
    }
}
