// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract IdjotErc20 is ERC20, Ownable, ERC20Burnable {
    constructor() ERC20("Token", "TOK") {
        _mint(owner(), 100000000 * 1e18);
    }
}