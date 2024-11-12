// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;


/// @title ICollectible
/// @author gfLobo
/// @dev An interface to create and manage collectibles in guilds.
interface ICollectible {
    
    // Events
    event MintTaxesUpdated(uint256 mintBaseFee, uint256 mintRateIncrementPercentage);
    event CreatorTermsUpdated(uint256 creatorSignatureFee);
    event RaffleUpdated(
        uint256 indexed tokenId, 
        string status,
        uint256 expectedAmount, 
        uint256 raffleAmount,
        uint256 numParticipants);


    // Function to get minter creator signature
    function getCreatorSignature() external payable;

    // Allow users to donate ETH to a specific creator in the system.
    function donate(address creator) external payable;

    // Allows creators to create token raffles for their contributors
    function createRaffle(uint256 tokenId, uint256 expectedAmount) external;

    // Allows users to join token raffles for their contributors
    function joinRaffle(uint256 tokenId) external payable;

    // Function to update the base mint fee
    function updateMintBaseFee(uint256 _mintBaseFee) external;

    // Function to update the mint rate increment percentage
    function updateMintRateIncrementPercentage(uint256 _mintRateIncrementPercentage) external;

    // Function to update the minter Creator signature fee
    function updateCreatorSignaturePrice(uint256 _creatorSignatureFee) external;

    // Function to withdraw funds from the contract
    function withdraw(uint256 amount) external;

}