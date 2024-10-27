// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TetherUSD is ERC20 {
    constructor() ERC20("Tether USD", "USDT") {
        _mint(msg.sender, 500_000_000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

contract BinanceUSD is ERC20 {
    constructor() ERC20("Binance USD", "BUSD") {
        _mint(msg.sender, 500_000_000 * 10 ** decimals());
    }
}