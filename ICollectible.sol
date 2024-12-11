// SPDX-License-Identifier: Apache-2.0
// Compatible with OpenZeppelin Contracts ^5.0.0

/*
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
*/

pragma solidity ^0.8.20;


/// @title ICollectible
/// @author gfLobo
/// @dev An interface to create and manage collectibles in guilds.
interface ICollectible {
    
    // Events
    event CreatorTermsUpdated(uint256 mintBaseFee, uint256 mintRateIncrementPercentage, uint256 creatorSignatureFee);

    // Function to get minter creator signature
    function getCreatorSignature() external payable;

    // Allow users to donate ETH to a specific creator in the system.
    function donate(address creator) external payable;

    // Function to update the base mint fee
    function updateMintBaseFee(uint256 _mintBaseFee) external;

    // Function to update the mint rate increment percentage
    function updateMintRateIncrementPercentage(uint256 _mintRateIncrementPercentage) external;

    // Function to update the minter Creator signature fee
    function updateCreatorSignaturePrice(uint256 _creatorSignatureFee) external;

    // Function to withdraw funds from the contract
    function withdraw(uint256 amount) external;

}