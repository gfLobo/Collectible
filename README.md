# Collectible - CERC721

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

## Simple Summary

The **Collectible** is an implementation of a collectible system based on the ERC721 standard for non-fungible tokens (NFTs). It provides features such as token creation, donations to creators, raffles, and dynamic minting fees, all managed by roles like "Creator" and "Contributor."

## Abstract

This contract allows creators to mint ERC721 tokens with associated URIs, and establishes a donation and raffle system to engage the community. Creators can host raffles where contributors can participate, with the contract ensuring transparent and random token distribution. Additionally, it includes the ability to pause the contract and dynamic minting fees based on the number of tokens a user owns.

## Motivation

The motivation behind this contract is to provide a flexible and secure platform for creating and managing non-fungible tokens (NFTs) beyond simple collections. The donation and raffle features are designed to foster interaction between creators and contributors, offering incentives to engage with the ecosystem. Dynamic minting fees make the system fair by considering users’ contributions and participation.

## Specification

This contract implements the **ERC721** standard with the following extensions:

- **ERC721URIStorage**: Allows associating URIs with tokens.
- **ERC721Pausable**: Enables pausing of the contract in emergencies.
- **AccessControl**: Defines roles for "Creator" and "Contributor."
- **ERC721Burnable**: Allows burning (destroying) tokens.
- **ReentrancyGuard**: Protects against reentrancy attacks.

### Main Functions:

1. **safeMint**: Allows creators to mint tokens, requiring a minting fee.
2. **donate**: Users can donate ETH to creators, becoming contributors.
3. **createRaffle**: Creators can set up raffles for their tokens.
4. **joinRaffle**: Contributors can join token raffles.
5. **getCreatorSignature**: Users can pay to become a creator and mint tokens.
6. **withdraw**: Allows the admin to withdraw ETH accumulated in the contract.

## Caveats

- The contract requires that the creator role be acquired via the `getCreatorSignature` function, and the token owner must be the creator of the raffle to manage participants.
- The raffle function (`joinRaffle`) ensures that raffles only occur when the expected amount is met and when enough contributors are present.

## Rationale

The choice to integrate **ERC721**, **ERC721URIStorage**, **ERC721Pausable**, **AccessControl**, and **ReentrancyGuard** was driven by the need for a robust and flexible system to support collectible creation with participation roles and access control. The donation and raffle system was inspired by crowdfunding models to increase community involvement.

## Backwards Compatibility

This contract is fully compatible with ERC721 contracts and adheres to the standard, ensuring interoperability with other non-fungible token solutions and marketplaces.

## Test Cases

Functionality tests have been conducted to verify the following features:

- Token creation and URI association.
- Donations and assignment of creator and contributor roles.
- Raffle operations with dynamic amounts and participants.
- Pausing and unpausing of the contract.
- Collection administrator functions such as updating fees and redeeming money.


## Implementations

The contract was developed and tested in environments compatible with **Solidity ^0.8.20** and utilizing **OpenZeppelin Contracts ^5.0.0**.

## References

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
