const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Collectible Contract", function () {
  let Collectible;
  let collectible;
  let owner;
  let creator;
  let contributor;
  let user;
  let mintBaseFee = ethers.utils.parseEther("0.05");
  let mintRateIncrementPercentage = ethers.utils.parseEther("10");
  let creatorSignatureFee = ethers.utils.parseEther("0.05");

  beforeEach(async function () {
    [owner, creator, contributor, user] = await ethers.getSigners();
    Collectible = await ethers.getContractFactory("Collectible");
    collectible = await Collectible.deploy(
      "TestToken",
      mintBaseFee,
      mintRateIncrementPercentage,
      creatorSignatureFee
    );
    await collectible.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct admin role", async function () {
      expect(await collectible.hasRole(await collectible.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
    });

    it("Should set the correct minting base fee and rates", async function () {
      expect(await collectible.mintBaseFee()).to.equal(mintBaseFee);
      expect(await collectible.mintRateIncrementPercentage()).to.equal(mintRateIncrementPercentage);
      expect(await collectible.creatorSignatureFee()).to.equal(creatorSignatureFee);
    });
  });

  describe("Minting", function () {

    it("Should revert if not enough ETH is sent during minting", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await expect(
        collectible.connect(creator).safeMint(user.address, "https://example.com/token1", { value: ethers.utils.parseEther("0.02") })
      ).to.be.revertedWith("Not enough ETH!");
    });
  });

  describe("Donation", function () {
    it("Should allow users to donate to creators", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);

      const initialContributorBalance = await ethers.provider.getBalance(contributor.address);
      const initialCreatorBalance = await ethers.provider.getBalance(creator.address);

      await collectible.connect(contributor).donate(creator.address, { value: ethers.utils.parseEther("0.1") });

      const finalContributorBalance = await ethers.provider.getBalance(contributor.address);
      const finalCreatorBalance = await ethers.provider.getBalance(creator.address);

      // Allow some tolerance for gas costs, adjust the exact amounts as needed
      expect(finalContributorBalance).to.be.closeTo(
        initialContributorBalance.sub(ethers.utils.parseEther("0.1")),
        ethers.utils.parseEther("0.001") // Tolerance for gas fees
      );
      expect(finalCreatorBalance).to.be.closeTo(
        initialCreatorBalance.add(ethers.utils.parseEther("0.1")),
        ethers.utils.parseEther("0.001") // Tolerance for gas fees
      );
    });


    it("Should revert if a user tries to donate to themselves", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await expect(
        collectible.connect(creator).donate(creator.address, { value: ethers.utils.parseEther("0.1") })
      ).to.be.revertedWith("You can't donate to yourself!");
    });
  });

  describe("Raffles", function () {
    it("Should allow creators to create a raffle", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await collectible.connect(creator).safeMint(creator.address, "https://example.com/token1", { value: ethers.utils.parseEther("0.05")});
      
      await collectible.connect(contributor).donate(creator.address, { value: ethers.utils.parseEther("0.1") })
      await collectible.connect(user).donate(creator.address, { value: ethers.utils.parseEther("0.1") })

      
      await collectible.connect(creator).createRaffle(ethers.utils.parseEther("0"), ethers.utils.parseEther("0.5"));
      const raffle = await collectible.raffles(ethers.utils.parseEther("0"));
      expect(raffle.expectedAmount).to.equal(ethers.utils.parseEther("0.5"));
    });

    it("Should allow contributors to join a raffle", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await collectible.connect(creator).safeMint(creator.address, "https://example.com/token1", { value: ethers.utils.parseEther("0.05")});
      
      await collectible.connect(contributor).donate(creator.address, { value: ethers.utils.parseEther("0.1") })
      await collectible.connect(user).donate(creator.address, { value: ethers.utils.parseEther("0.1") })

      
      await collectible.connect(creator).createRaffle(ethers.utils.parseEther("0"), ethers.utils.parseEther("2.0"));
      await collectible.connect(contributor).joinRaffle(ethers.utils.parseEther("0"), { value: ethers.utils.parseEther("0.5") });

      const raffle = await collectible.raffles(ethers.utils.parseEther("0"));
      expect(raffle.raffleAmount).to.equal(ethers.utils.parseEther("0.5"));
    });
  });

  describe("Pausing", function () {
    it("Should allow admin to pause and unpause contract", async function () {
      await collectible.grantRole(await collectible.DEFAULT_ADMIN_ROLE(), owner.address);
      await collectible.pause();
      expect(await collectible.paused()).to.be.true;
      await collectible.unpause();
      expect(await collectible.paused()).to.be.false;
    });

    it("Should revert minting when contract is paused", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await collectible.pause();
      await expect(
        collectible.connect(creator).safeMint(user.address, "https://example.com/token1", { value: ethers.utils.parseEther("0.05") })
      ).to.be.revertedWith("Contract paused!");
    });
  });

  describe("Admin Functions", function () {
    it("Should allow admin to withdraw ETH", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await collectible.grantRole(await collectible.DEFAULT_ADMIN_ROLE(), owner.address);
      await collectible.connect(creator).safeMint(creator.address, "https://example.com/token1", { value: ethers.utils.parseEther("1.0") })
      await expect(() =>
          collectible.connect(owner).withdraw(ethers.utils.parseEther("1.0"))
      ).to.changeEtherBalances([collectible], [ethers.utils.parseEther("0.0")]);
    });

    it("Should update mint base fee", async function () {
      await collectible.grantRole(await collectible.DEFAULT_ADMIN_ROLE(), creator.address);
      await collectible.updateMintBaseFee(ethers.utils.parseEther("0.2"));
      expect(await collectible.mintBaseFee()).to.equal(ethers.utils.parseEther("0.2"));
    });
  });
});
