pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IdjotErc20 is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("idjotErc20", "WIN") {
        _mint(owner(), 100000000 * 10 ** decimals());
    }
}