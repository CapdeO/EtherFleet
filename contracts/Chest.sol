// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Chest is Ownable {
    uint256 unlockTimestamp;

    constructor(uint256 _unlockTimestamp) {
        unlockTimestamp = _unlockTimestamp;
    }

    function withdrawTokens(address _tokenAddress) external onlyOwner {
        require(block.timestamp >= unlockTimestamp, "Still in lock period.");

        uint256 _tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));

        require(_tokenBalance > 0, "Contract without token balance.");

        require(
            IERC20(_tokenAddress).transfer(_msgSender(), _tokenBalance),
            "Token transfer error."
        );
    }
}