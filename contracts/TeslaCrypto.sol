// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TeslaCrypto is ERC20, Ownable, ReentrancyGuard, Pausable {
    mapping(address => bool) private blacklisted;

    constructor(address initialOwner) 
        ERC20("Tesla Crypto", "TSL") 
        Ownable(initialOwner) 
    {
        _mint(initialOwner, 1_000_000_000 * 10**18); // total supply: 1 billion TSL tokens
    }

    // Burn tokens (onlyOwner)
    function burn(uint256 amount) public onlyOwner nonReentrant {
        _burn(msg.sender, amount);
    }

    // Recover mistakenly sent tokens
    function recoverTokens(address tokenAddress, uint256 amount) external onlyOwner nonReentrant {
        IERC20(tokenAddress).transfer(owner(), amount);
    }

    // Pause all transfers
    function pause() external onlyOwner {
        _pause();
    }

    // Unpause all transfers
    function unpause() external onlyOwner {
        _unpause();
    }

    // Blacklist functions
    function addToBlacklist(address account) external onlyOwner {
        blacklisted[account] = true;
    }

    function removeFromBlacklist(address account) external onlyOwner {
        blacklisted[account] = false;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return blacklisted[account];
    }

    // Override _beforeTokenTransfer to check blacklist and pause
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(!blacklisted[from] && !blacklisted[to], "TeslaCrypto: blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }
}
