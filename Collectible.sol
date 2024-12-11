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

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "ICollectible.sol";

/// @title Collectible
/// @author gfLobo
/// @notice This contract implements a collectible system based on ERC721 with guild-based creators.
/// @dev It inherits functionalities from OpenZeppelin such as:
/// - ERC721 (Standard token),
/// - ERC721URIStorage (URI storage),
/// - ERC721Pausable (Pausing capabilities),
/// - AccessControl (Role-based access control),
/// - ERC721Burnable (Token burning),
/// - ReentrancyGuard (Protection against reentrancy attacks).
contract Collectible is
    ICollectible,
    ERC721,
    ERC721URIStorage,
    ERC721Pausable,
    AccessControl,
    ERC721Burnable,
    ReentrancyGuard
{
    /// @notice Tracks the current token ID, incremented for each new mint.
    uint256 public currentTokenId;

    /// @notice Base minting fee for creating new tokens, in ETH.
    uint256 public mintBaseFee;
    
    /// @notice Fee required for obtaining a creator signature, in ETH.
    uint256 public creatorSignatureFee;
    
    /// @notice Maximum of mints a user can perform
    uint256 public maxMintsPerUserInCycle; 

    /// @notice Last update timestamp
    uint256 public lastUpdateTimestamp;

    /// @notice Update Cycle
    uint256 public constant UPDATE_INTERVAL = 30 days;
    
    /// @notice Role identifier for creator of the system.
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    
    /// @notice Role identifier for contributors (donors) in the system.
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR_ROLE");
    
    /// @notice Tracks the number of mints a user has performed in cycle
    mapping(address => uint256) public mintsPerUserInCycle;

    /// @notice Ensures the contract is not paused when executing the function.
    modifier onlyIfNotPaused() {
        require(!paused(), "Contract paused!");
        _;
    }

    /// @notice Ensures the caller is the owner of the specified token
    /// @param tokenId The ID of the token to check ownership.
    modifier onlyTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner.");
        _;
    }

   /// @notice Ensures updates last the same time as cycles
    modifier updateCooldown() {
        require(
            block.timestamp >= lastUpdateTimestamp + UPDATE_INTERVAL, 
            "Updates not available. Try it before your first mint of the next cycle."
        );
        _;
    }

   
    /// @notice Contract constructor
    /// @param _tokenName The name of the token.
    /// @param _tokenSymbol The symbol of the token.
    /// @param _mintBaseFee The initial base fee for minting tokens.
    /// @param _creatorSignatureFee The fee required to become a member.
    /// @param _maxMintsPerUserInCycle Maximum of mints per user in cycle
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _mintBaseFee,
        uint256 _creatorSignatureFee,
        uint256 _maxMintsPerUserInCycle
    )
        ERC721(_tokenName, _tokenSymbol)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CREATOR_ROLE, msg.sender);
        _grantRole(CONTRIBUTOR_ROLE, msg.sender);

        updateTerms(
            _mintBaseFee,
            _creatorSignatureFee,
            _maxMintsPerUserInCycle
        );
    }

    /// @notice Safely mints a new ERC721 token and associates it with a URI.
    /// @param uri The metadata URI associated with the token.
    /// @dev Only members can mint tokens and must pay the applicable minting fee.
    function safeMint(string memory uri)
        public
        payable
        override 
        onlyIfNotPaused
        nonReentrant
        onlyRole(CREATOR_ROLE)
    {
        bool userMintsExceeded = mintsPerUserInCycle[msg.sender] + 1 > maxMintsPerUserInCycle;

        require(msg.value >= mintFee(), "Not enough ETH!");

        uint256 tokenId = currentTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        if(userMintsExceeded){
            mintsPerUserInCycle[msg.sender] = 0;
        }
        mintsPerUserInCycle[msg.sender]++;
    }

    /// @notice Calculates and returns the current minting fee for a user 
    /// @dev Uses a logarithmic function to smooth the reduction in fees as the number of mints increases.
    /// @return The minting fee in ETH.
    function mintFee() public view returns (uint256) {
        if (hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) return 0;
        uint256 userMints = mintsPerUserInCycle[msg.sender];
        uint256 divisor = userMints == 0 ? 1 : Math.log2(userMints + 2);
        return mintBaseFee / divisor;
    }



    /// @notice Allow users to donate ETH to a specific creator in the system.
    /// @param creator The address of the creator receiving the donation.
    function donate(address creator) 
    public
    payable 
    override 
    {
        require(hasRole(CREATOR_ROLE, creator), "Address is not a valid creator!");
        require(creator != msg.sender, "You can't donate to yourself!");
        require(msg.value > 0, "Value must be greater than zero");

        payable(creator).transfer(msg.value);
        _grantRole(CONTRIBUTOR_ROLE, msg.sender);
        emit DonationReceived(msg.sender, creator, msg.value);
    }


    /// @notice Allows a user to acquire the creator signature by paying the creator fee.
    /// @dev The creator fee is set by the admin.
    function getCreatorSignature()
        public
        payable
        override
        onlyIfNotPaused
    {
        uint256 signatureFee = creatorSignatureFee;
        require(msg.value >= signatureFee, "Not enough ETH!");
        _grantRole(CREATOR_ROLE, msg.sender);
    }

    /// @notice Allows the admin to update contract terms
    /// @param _mintBaseFee The initial base fee for minting tokens.
    /// @param _creatorSignatureFee The fee required to become a member.
    /// @param _maxMintsPerUserInCycle Maximum of mints per user in cycle
    function updateTerms(uint256 _mintBaseFee, uint256 _creatorSignatureFee, uint256 _maxMintsPerUserInCycle) 
        public 
        override 
        onlyRole(DEFAULT_ADMIN_ROLE)
        updateCooldown
    {
        require(_mintBaseFee > 0, "The base fee must be greater than zero.");
        mintBaseFee = _mintBaseFee;

        require(_creatorSignatureFee > 0, "Creator signature fee must be greater than zero.");
        creatorSignatureFee = _creatorSignatureFee;

        require(_maxMintsPerUserInCycle > 0 && _maxMintsPerUserInCycle <= 30, "Maximum mints per user in cycle must be between 0 and 30.");
        maxMintsPerUserInCycle = _maxMintsPerUserInCycle;

        lastUpdateTimestamp = block.timestamp; 

        emit CreatorTermsUpdated(
             mintBaseFee,
             creatorSignatureFee,
             maxMintsPerUserInCycle);
    }



    /// @notice Allows the admin to withdraw ETH from the contract.
    /// @param _amount The amount of ETH to withdraw.
    /// @dev This function is protected by `nonReentrant` to prevent reentrancy attacks.
    function withdraw(uint256 _amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {
        payable(msg.sender).transfer(_amount);
    }

    /// @notice Allows a token owner to burn (destroy) their token.
    /// @param tokenId The ID of the token to burn.
    /// @dev Only the token owner can burn the token.
    function burn(uint256 tokenId)
        public
        virtual
        override
        onlyTokenOwner(tokenId)
    {
        super._burn(tokenId);
    }

    /// @notice Pauses all contract functions.
    /// @dev Only the admin can pause the contract.
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @notice Unpauses the contract and resumes functionality.
    /// @dev Only the admin can unpause the contract.
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // --- Overridden functions for compatibility with multiple inheritance ---

    /// @dev Overrides the `_update` method to ensure compatibility between inherited contracts.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /// @dev Overrides `_increaseBalance` for compatibility with ERC721.
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721)
    {
        super._increaseBalance(account, value);
    }

    /// @notice Returns the URI associated with a specific token.
    /// @dev Overrides `tokenURI` to ensure compatibility with ERC721 and ERC721URIStorage.
    /// @param tokenId The ID of the token.
    /// @return The token's URI.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /// @notice Checks whether the contract supports a specific interface.
    /// @param interfaceId The interface ID to check.
    /// @return True if the interface is supported.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
