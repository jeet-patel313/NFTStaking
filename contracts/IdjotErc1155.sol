// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract IdjotErc1155 is ERC1155, Ownable, ERC1155Burnable {
    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public payable {
        require(
            msg.value / (0.001 ether) == amount,
            "Provided ether should be equal to amount * 0.001 ether"
        );
        _mint(msg.sender, id, amount, data);
    }
}
