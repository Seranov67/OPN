// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("OPN Infra Token", "OPIT") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}
