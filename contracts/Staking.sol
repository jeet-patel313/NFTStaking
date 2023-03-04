// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IdjotToken.sol";
import "./IdjotErc1155.sol";
import "hardhat/console.sol";

contract stakingContract is IdjotErc20, IdjotErc1155 {
    address payable depositAddress;

    constructor(address payable _depositAddress) {
        depositAddress = _depositAddress;
    }

    struct stakedItem {
        uint256 nftAmount; // nft amount
        uint256 nftId; // nft Id
        uint256 stakeAtTime; // timestamp at which nft was staked
        address payable owner; // address of the owner
        bool isStaked; // staked or not
    }

    mapping(address => stakedItem) private stakedInfo;

    event Staked(uint256 NftId, uint256 NftAmount, address stakedAddress);

    event UnStaked(
        uint256 NftId,
        uint256 NftAmount,
        address stakedAddress,
        uint256 rewardedAmt
    );

    // update deposit address
    function updateDepositAddress(address payable _newDepositAddress)
        public
        onlyOwner
    {
        depositAddress = _newDepositAddress;
    }

    // calculate the erc20 tokens rewarded
    function calculate(uint256 stakedTime) internal view returns (uint256) {
        uint256 calulationTime = block.timestamp - stakedTime;
        // calulation assumes that the 1 month = 30 days
        if ((calulationTime / 2628288) <= 1) {
            return 500;
        } else if ((calulationTime / 2628288) <= 6) {
            return 1000;
        } else if ((calulationTime / 2628288) <= 12) {
            return 1500;
        } else {
            return 2000;
        }
    }

    function stakeNFT(uint256 _nftId, uint256 _nftAmount)
        public
        returns (bool)
    {
        // staker should have the required _nftId and _nftAmount to stake
        require(
            balanceOf(msg.sender, _nftId) >= _nftAmount,
            "You don't have required amount of the specified NFT ID"
        );

        // nftId must not be already staked
        require(
            stakedInfo[msg.sender].isStaked == false,
            "NFT is already staked!"
        );

        // transfer the amount of nfts to the deposit address
        safeTransferFrom(msg.sender, depositAddress, _nftId, _nftAmount, "");

        // update stakedItem
        stakedInfo[msg.sender] = stakedItem(
            _nftAmount,
            _nftId,
            block.timestamp,
            payable(msg.sender),
            true
        );

        emit Staked(_nftId, _nftAmount, msg.sender);

        return true;
    }

    function unStakeNft(uint256 _nftId, uint256 _nftAmount)
        public
        returns (uint256)
    {
        // require the user has staked the specified nft id
        require(
            stakedInfo[msg.sender].nftId == _nftId,
            "You don't have any staked item under this id"
        );

        // require the user has staked the specified amount or less
        require(
            stakedInfo[msg.sender].nftAmount >= _nftAmount,
            "You have staked lesser value of this id"
        );

        // calculate rewards
        uint256 rewards = calculate(stakedInfo[msg.sender].stakeAtTime);

        // return the nft from the deposit address to the original address
        // safeTransferFrom(depositAddress, msg.sender, _nftId, _nftAmount, "");

        // transfer the rewards
        // approve(msg.sender, rewards);
        // transferFrom(address(this), msg.sender, rewards);

        // update the stakeInfo
        stakedInfo[msg.sender] = stakedItem(
            0,
            0,
            block.timestamp,
            payable(msg.sender),
            false
        );

        emit UnStaked(_nftId, _nftAmount, msg.sender, rewards);

        return rewards;
    }
}
