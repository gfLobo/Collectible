// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "ICollectible.sol";

/// @title Collectible Contract
/// @author gfLobo
/// @notice This contract implements a collectible system based on ERC721 with guild-based creators.
/// @dev It inherits functionalities from OpenZeppelin such as:
/// - ERC721 (Standard token),
/// - ERC721Enumerable (Token enumeration),
/// - ERC721URIStorage (URI storage),
/// - ERC721Pausable (Pausing capabilities),
/// - AccessControl (Role-based access control),
/// - ERC721Burnable (Token burning),
/// - ReentrancyGuard (Protection against reentrancy attacks).
contract Collectible is
    ICollectible,
    ERC721,
    ERC721Enumerable,
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
    
    /// @notice Incremental rate applied to minting fees based on how many tokens a user already owns.
    uint256 public mintRateIncrementPercentage;
    
    /// @notice Role identifier for creator of the system.
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    
    /// @notice Role identifier for contributors (donors) in the system.
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR_ROLE");
    

    struct Raffle{
        uint256 expectedAmount;
        uint256 raffleAmount;
    }

    /// @notice Map raffles per tokenId
    mapping(uint256 => Raffle) public raffles;

    /// @notice Map creators and their contributors
    mapping(address => address[]) public creatorToContributors;

    /// @notice Ensures the contract is not paused when executing the function.
    modifier onlyIfNotPaused() {
        require(!paused(), "Contract paused!");
        _;
    }

    /// @notice Ensures the caller is the owner of the specified token.
    /// @param tokenId The ID of the token to check ownership.
    modifier onlyTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner!");
        _;
    }

    /// @notice Ensures the donation is valid
    /// @param creator The creator address
    modifier validDonation(address creator) {
        require(hasRole(CREATOR_ROLE, creator), "Address is not a valid creator!");
        require(creator != msg.sender, "You can't donate to yourself!");
        require(msg.value > 0, "Value must be greater than zero");
        _;
    }

    /// @notice Contract constructor. Initializes the contract with the specified configuration parameters.
    /// @param _tokenName The name of the token.
    /// @param _mintBaseFee The initial base fee for minting tokens.
    /// @param _mintRateIncrementPercentage The rate at which minting fees increase.
    /// @param _creatorSignatureFee The fee required to become a member.
    constructor(
        string memory _tokenName,
        uint256 _mintBaseFee,
        uint256 _mintRateIncrementPercentage,
        uint256 _creatorSignatureFee
    )
        ERC721(_tokenName, "CERC721")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CREATOR_ROLE, msg.sender);

        updateMintBaseFee(_mintBaseFee);
        updateMintRateIncrementPercentage(_mintRateIncrementPercentage);
        updateCreatorSignaturePrice(_creatorSignatureFee);
    }

    /// @notice Safely mints a new ERC721 token and associates it with a URI.
    /// @param to The address of the token recipient.
    /// @param uri The metadata URI associated with the token.
    /// @dev Only members can mint tokens and must pay the applicable minting fee.
    function safeMint(address to, string memory uri)
        public
        payable
        onlyIfNotPaused
        nonReentrant
        onlyRole(CREATOR_ROLE)
    {
        require(msg.value >= mintFee(), "Not enough ETH!");
        uint256 tokenId = currentTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /// @notice Allow users to donate ETH to a specific creator in the system.
    /// @param creator The address of the creator receiving the donation.
    function donate(address creator) 
    public
    payable 
    override 
    validDonation(creator)
    {
        payable(creator).transfer(msg.value);
        _grantRole(CONTRIBUTOR_ROLE, msg.sender);
        creatorToContributors[creator].push(msg.sender);
    }


    // @notice Allows creators to raffle token for their contributors
    // @param tokenId
    // @param expectedAmount
    function createRaffle(uint256 tokenId, uint256 expectedAmount)
    public 
    override 
    onlyTokenOwner(tokenId)
    onlyRole(CREATOR_ROLE)
    {
        require(creatorToContributors[msg.sender].length > 1, "Number of contributors must be greater than 1");
        require(expectedAmount > 0, "Expected amount must be greater than zero");
        require(raffles[tokenId].expectedAmount == 0, "Raffle already exists");

        raffles[tokenId] = Raffle(expectedAmount, 0);
        approve(address(this), tokenId);
        emit RaffleCreated(tokenId);
    }

    // @notice Allows users to join token raffles for their contributors
    // @param tokenId
    function joinRaffle(uint256 tokenId)
    public 
    payable 
    override 
    {
        address creator = ownerOf(tokenId);
        require(raffles[tokenId].expectedAmount > 0, "No active raffle for this token");
        require(msg.value > 0, "Must send ETH to join raffle");
        require(creator != msg.sender, "You cannot join your own raffle");

        raffles[tokenId].raffleAmount += msg.value;
        donate(creator);

        if (raffles[tokenId].raffleAmount >= raffles[tokenId].expectedAmount) {
            address[] memory contributors = creatorToContributors[creator];
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao, creator))
            ) % contributors.length;
            
            this.safeTransferFrom(creator, contributors[randomIndex], tokenId);
            delete raffles[tokenId];
        }
            
    }

    /// @notice Allows a user to acquire the creator signature by paying the creator fee.
    /// @dev The creator fee is set by the admin.
    function getCreatorSignature()
        public
        payable
        override
        onlyIfNotPaused
    {
        require(msg.value >= creatorSignatureFee, "Not enough ETH!");
        _grantRole(CREATOR_ROLE, msg.sender);
    }

    /// @notice Returns the minting fee for a user, calculated based on how many tokens the user owns.
    /// @return The minting fee in ETH.
    function mintFee() public view returns (uint256) {
        if (hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) return 0;
        uint256 userTokenCount = balanceOf(msg.sender);
        return mintBaseFee * (1 + mintRateIncrementPercentage / 100) ** userTokenCount;
    }

    /// @notice Updates the base minting fee.
    /// @param _mintBaseFee The new base minting fee.
    /// @dev Only the admin can call this function.
    function updateMintBaseFee(uint256 _mintBaseFee)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        mintBaseFee = _mintBaseFee;
        emit MintTaxesUpdated(_mintBaseFee, mintRateIncrementPercentage);
    }

    /// @notice Updates the percentage rate for minting fee increments.
    /// @param _mintRateIncrementPercentage The new increment percentage.
    /// @dev Only the admin can call this function.
    function updateMintRateIncrementPercentage(uint256 _mintRateIncrementPercentage)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        mintRateIncrementPercentage = _mintRateIncrementPercentage;
        emit MintTaxesUpdated(mintBaseFee, _mintRateIncrementPercentage);
    }

    /// @notice Updates the creator signature fee.
    /// @param _creatorSignatureFee The new fee for creator signatures.
    /// @dev Only the admin can call this function.
    function updateCreatorSignaturePrice(uint256 _creatorSignatureFee)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        creatorSignatureFee = _creatorSignatureFee;
        emit CreatorTermsUpdated(_creatorSignatureFee);
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
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /// @dev Overrides `_increaseBalance` for compatibility with ERC721 and ERC721Enumerable.
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
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
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
