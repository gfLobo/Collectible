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
import "ICollectible.sol";


/// @title ICollectibleRaffler
/// @author gfLobo
/// @dev An interface to create and manage collectibles in guilds.
interface ICollectibleRaffler is ICollectible {
    
    // Events
    event RaffleUpdated(
        uint256 indexed tokenId, 
        string status,
        uint256 expectedAmount, 
        uint256 raffleAmount,
        uint256 numParticipants);

    // Allow users to donate ETH to a specific creator in the system.
    function donate(address creator) external payable;

    // Allows creators to create token raffles for their contributors
    function createRaffle(uint256 tokenId, uint256 expectedAmount) external;

    // Allows users to join token raffles for their contributors
    function joinRaffle(uint256 tokenId) external payable;

}