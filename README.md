# Collectible

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

### Simple Summary  

**Collectible** is an ERC721-based extension that enhances the NFT ecosystem by introducing features such as dynamic minting fees, creator donations, and transparent raffles. These improvements foster engagement between creators and contributors, ensuring a fair and sustainable system.

### Abstract  

This EIP presents a contract that expands ERC721 with additional functionalities:  
1. **Dynamic Minting Fees**: Fees calculated based on token ownership to discourage hoarding.  
2. **Donation System**: Enables direct support for creators and community engagement.  
3. **On-Chain Raffles**: Offers a transparent reward system using randomness.  
4. **Role-Based Access Control**: Ensures security and decentralization with distinct roles for creators and contributors.

### Motivation  

The aim is to overcome limitations in traditional NFT systems, such as fixed fees, lack of governance mechanisms, and exclusion of smaller participants in giveaways. The proposal promotes inclusion, engagement, and equitable distribution of digital assets.

### Specification  

The contract extends the ERC721 standard by incorporating the following modules:  
- **ERC721URIStorage**: Enables token-URI association.  
- **ERC721Pausable**: Allows pausing the contract during emergencies.  
- **AccessControl**: Defines roles like "Creator" and "Contributor."  
- **ERC721Burnable**: Allows token destruction.  
- **ReentrancyGuard**: Protects against reentrancy attacks.

**Main Functions**:  
1. `safeMint`: Allows creators to mint NFTs with unique URIs, paying dynamic fees.  
2. `donate`: Users can donate ETH to creators, obtaining contributor status.  
3. `createRaffle`: Enables creators to organize raffles for their tokens.  
4. `joinRaffle`: Allows contributors to join raffles with on-chain randomness.  
5. `getCreatorSignature`: Users can pay to become creators and mint tokens.  
6. `withdraw`: Admins can withdraw accumulated ETH from the contract.  

### Rationale  

The design decisions were guided by:  
1. **Dynamic Fees**: Prevent excessive accumulation, promoting scarcity and fairness.  
2. **Donations**: Inspired by crowdfunding models to sustain creator support.  
3. **Raffles**: Encourage engagement from smaller contributors through on-chain transparency.  
4. **Role-Based Access Control**: Leverages `AccessControl` for decentralization and trust.  
5. **Modular Compatibility**: Features can be adopted individually without breaking ERC721 interoperability.

### Backward Compatibility  

The contract is fully compatible with ERC721, ensuring seamless interoperability with marketplaces, wallets, and other systems that support the standard.

### Test Cases  

The tests verify the following functionalities:  
1. Token creation and destruction with associated URIs.  
2. Role management for creators and contributors.  
3. Donation and raffle operations.  
4. Contract pause and resume.  
5. Security against reentrancy attacks.  

### Reference Implementation  

A functional implementation has been developed using **Solidity ^0.8.20** and **OpenZeppelin Contracts ^5.0.0**.  

**References**:  
- [ERC721 - Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721)  
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)  


## Copyright

   Copyright [2024] [gfLobo]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
