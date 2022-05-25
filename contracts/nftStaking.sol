// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;

import "./IdjotErc20.sol";
import "./IdjotErc1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract idjotNFT is Ownable, IERC1155Receiver {
    uint256 public totalStaked;

    // struct to store a stake's token, owner, and earning values
    struct Stake {
    uint24 tokenId;
    uint48 timestamp;
    address owner;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    IdjotErc20 erc20;
    IdjotErc1155 erc1155;

    // maps tokenId to stake
    mapping(uint256 => Stake) public vault;
    
    constructor(IdjotErc20 _erc20, IdjotErc1155 _erc1155) {
        erc20 = _erc20;
        erc1155 = _erc1155;
    }

    function stake(uint256[] calldata tokenIds) external {
    uint256 tokenId;
    totalStaked += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
        tokenId = tokenIds[i];
        require(erc1155.ownerOf(tokenId) == msg.sender, "not your token");
        require(vault[tokenId].tokenId == 0, 'already staked');

        erc1155.transferFrom(msg.sender, address(this), tokenId);
        emit NFTStaked(msg.sender, tokenId, block.timestamp);

        vault[tokenId] = Stake({
        owner: msg.sender,
        tokenId: uint24(tokenId),
        timestamp: uint48(block.timestamp)
        });
    }
    }

    function _unstakeMany(address account, uint256[] calldata tokenIds) internal {
    uint256 tokenId;
    totalStaked -= tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
        tokenId = tokenIds[i];
        Stake memory staked = vault[tokenId];
        require(staked.owner == msg.sender, "not an owner");

        delete vault[tokenId];
        emit NFTUnstaked(account, tokenId, block.timestamp);
        erc1155.transferFrom(address(this), account, tokenId);
    }
    }

    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    function claimForAddress(address account, uint256[] calldata tokenIds) external {
        _claim(account, tokenIds, false);
    }

    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    function _claim(address account, uint256[] calldata tokenIds, bool _unstake) internal {
    uint256 tokenId;
    uint256 earned = 0;

    for (uint i = 0; i < tokenIds.length; i++) {
        tokenId = tokenIds[i];
        Stake memory staked = vault[tokenId];
        require(staked.owner == account, "not an owner");
        uint256 stakedAt = staked.timestamp;
        earned += 100000 ether * (block.timestamp - stakedAt) / 1 days;
        vault[tokenId] = Stake({
        owner: account,
        tokenId: uint24(tokenId),
        timestamp: uint48(block.timestamp)
        });

    }
    if (earned > 0) {
        earned = earned / 10;
        erc20.mint(account, earned);
    }
    if (_unstake) {
        _unstakeMany(account, tokenIds);
    }
    emit Claimed(account, earned);
    }

    function earningInfo(uint256[] calldata tokenIds) external view returns (uint256[2] memory info) {
        uint256 tokenId;
        uint256 totalScore = 0;
        uint256 earned = 0;
        Stake memory staked = vault[tokenId];
        uint256 stakedAt = staked.timestamp;
        earned += 100000 ether * (block.timestamp - stakedAt) / 1 days;
    uint256 earnRatePerSecond = totalScore * 1 ether / 1 days;
    earnRatePerSecond = earnRatePerSecond / 100000;
    // earned, earnRatePerSecond
    return [earned, earnRatePerSecond];
    }

    // should never be used inside of transaction because of gas fee
    function balanceOf(address account) public view returns (uint256) {
    uint256 balance = 0;
    uint256 supply = erc1155.totalSupply();
    for(uint i = 1; i <= supply; i++) {
        if (vault[i].owner == account) {
        balance += 1;
        }
    }
    return balance;
    }

    // should never be used inside of transaction because of gas fee
    function tokensOfOwner(address account) public view returns (uint256[] memory ownerTokens) {

    uint256 supply = erc1155.totalSupply();
    uint256[] memory tmp = new uint256[](supply);

    uint256 index = 0;
    for(uint tokenId = 1; tokenId <= supply; tokenId++) {
        if (vault[tokenId].owner == account) {
        tmp[index] = vault[tokenId].tokenId;
        index +=1;
        }
    }

    uint256[] memory tokens = new uint256[](index);
    for(uint i = 0; i < index; i++) {
        tokens[i] = tmp[i];
    }

    return tokens;
    }

    function onERC1155Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC1155Receiver.onERC1155Received.selector;
    }
  
}