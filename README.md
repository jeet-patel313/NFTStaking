# Staking Contract for NFTs with ERC20 Token Rewards Based on Staking Period

- This is a smart contract for staking ERC1155 NFTs and earning ERC20 tokens as rewards. <br>
  It imports two other contracts: "IdjotToken.sol" for the ERC20 token and "IdjotErc1155.sol" for the ERC1155 NFT.

- The contract defines a struct called "stakedItem" that holds the NFT id, amount, <br>
  staking time, owner address, and a boolean indicating whether the NFT is currently staked or not.

### Functions

```
function calculate(uint256 stakedTime) internal view returns(uint256) { ... }
```

- The contract has a function called "calculate" which takes in the staked time and returns the number of ERC20 tokens that should be rewarded based on the staked time. The function uses a time calculation assuming that 1 month equals 30 days.

```
function updateStakedInfo(uint256 _nftId, uint256 _nftAmount) internal { ... }
```

- The function "updateStakedInfo" updates the stakedInfo mapping with the staker's stakedItem.

```
function stakeNFT(uint256 _nftId, uint256 _nftAmount) public returns(bool) { ... }
```

- The function "stakeNFT" is the main function for staking NFTs. It first checks that the staker has the required NFT id and amount to stake. If the user has already staked the NFT id before, the stakedItem is updated with the new staked amount. If the user has not already staked the NFT id, a new stakedItem is created. The function then transfers the NFTs to the deposit address and emits the "Staked" event.

```
function unStakeNft(uint256 _nftId, uint256 _nftAmount) public returns(uint256) { ... }
```

- The function "unStakeNft" allows a user to unstake their NFTs and receive rewards. It first checks that the user has staked the specified NFT id and amount. The function then calculates the rewards based on the staked time using the "calculate" function. The function then returns the NFTs to the user and transfers the rewards from the deposit address to the user's address. The stakedInfo mapping is then updated with the new stakedItem and the "UnStaked" event is emitted.

### Events

```
event Staked(uint256 NftId, uint256 NftAmount, address stakedAddress);
```

The contract has an event called "Staked" which is emitted when a user stakes their NFTs.

```
event UnStaked(uint256 NftId, uint256 NftAmount, address stakedAddress, uint256 rewardedAmt);
```

Event named "UnStaked" is emitted when a user unstakes their NFTs and receives rewards.
