// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EtherFleet is ERC20 {

    constructor() ERC20("Ether Fleet", "ETHFL") {
        _mint(msg.sender, 200_000_000 * 10 ** decimals());
    }
}