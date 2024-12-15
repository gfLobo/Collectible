const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Collectible Contract", function () {
  let Collectible;
  let collectible;
  let owner;
  let creator;
  let contributor;
  let mintBaseFee = ethers.utils.parseEther("1");
  let creatorSignatureFee = ethers.utils.parseEther("1");
  let maxMintsPerUserInCycle = 10;

  beforeEach(async function () {
    [owner, creator, contributor] = await ethers.getSigners();
    Collectible = await ethers.getContractFactory("Collectible");
    collectible = await Collectible.deploy(
      "TestToken",
      "TTK",
      mintBaseFee,
      creatorSignatureFee,
      maxMintsPerUserInCycle
    );
    await collectible.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct admin role", async function () {
      expect(await collectible.hasRole(await collectible.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
    });

    it("Should set the correct terms", async function () {
      expect(await collectible.mintBaseFee()).to.equal(mintBaseFee);
      expect(await collectible.creatorSignatureFee()).to.equal(creatorSignatureFee);
      expect(await collectible.maxMintsPerUserInCycle()).to.equal(maxMintsPerUserInCycle);
    });
  });

  describe("Minting", function () {
    it("Should revert if not enough ETH is sent during minting", async function () {
      await collectible.connect(creator).getCreatorSignature({ value: creatorSignatureFee });
      await expect(
      collectible.connect(creator).safeMint("https://example.com/token1", { value: ethers.utils.parseEther("0.02") })
      ).to.be.revertedWith("Not enough ETH!");

    });

    it("Should revert mintFee to the mintBaseFee value after maxMintsPerUserInCycle exceeded", async function () {
        await collectible.connect(creator).getCreatorSignature({ value: creatorSignatureFee });

        for (let i = 0; i < maxMintsPerUserInCycle; i++) {
            const currentMintFee = await collectible.connect(creator).mintFee();
            console.log(`CURRENT MINT FEE = ${currentMintFee}`)
            await collectible.connect(creator).safeMint(`https://example.com/token${i + 1}`, {
                value: currentMintFee,
            });
        }

        await collectible.connect(creator).safeMint("https://example.com/token4", {
            value: mintBaseFee,
        });

        const userMints = await collectible.mintsPerUserInCycle(creator.address);
        expect(userMints).to.equal(1);
    });

    it("Should allow minting with enough ETH", async function () {
      await collectible.connect(creator).getCreatorSignature({ value: creatorSignatureFee });
      const initialTokenId = await collectible.currentTokenId();
      await collectible.connect(creator).safeMint("https://example.com/token1", { value: mintBaseFee });
      const finalTokenId = await collectible.currentTokenId();
      expect(finalTokenId).to.equal(initialTokenId.add(1));
    });


    it("Should get minting discount while minting more tokens", async function () {
        await collectible.connect(creator).getCreatorSignature({ value: creatorSignatureFee });

        const initialMintFee = await collectible.connect(creator).mintFee();

        // 1st token
        await collectible.connect(creator).safeMint("https://example.com/token1", {
            value: initialMintFee,
        });

        // 2nd token
        await collectible.connect(creator).safeMint("https://example.com/token2", {
            value: initialMintFee,
        });

        const discountedMintFee = await collectible.connect(creator).mintFee();
        
        const initialMintFeeNumber = parseFloat(ethers.utils.formatEther(initialMintFee));
        const discountedMintFeeNumber = parseFloat(ethers.utils.formatEther(discountedMintFee));

        expect(discountedMintFeeNumber).to.be.lessThan(initialMintFeeNumber);
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

  describe("Creator Signature", function () {
    it("Should allow users to acquire creator signature", async function () {
      await collectible.connect(contributor).getCreatorSignature({ value: creatorSignatureFee });
      expect(await collectible.hasRole(await collectible.CREATOR_ROLE(), contributor.address)).to.be.true;
    });

    it("Should revert if not enough ETH is sent for creator signature", async function () {
      await expect(
        collectible.connect(contributor).getCreatorSignature({ value: ethers.utils.parseEther("0.01") })
      ).to.be.revertedWith("Not enough ETH!");
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
        collectible.connect(creator).safeMint("https://example.com/token1", { value: mintBaseFee })
      ).to.be.revertedWith("Contract paused!");
    });
  });

  describe("Admin Functions", function () {
    it("Should allow admin to withdraw ETH", async function () {
      await collectible.grantRole(await collectible.CREATOR_ROLE(), creator.address);
      await collectible.grantRole(await collectible.DEFAULT_ADMIN_ROLE(), owner.address);
      await collectible.connect(creator).safeMint("https://example.com/token1", { value: ethers.utils.parseEther("1.0") });
      await collectible.connect(owner).withdraw(ethers.utils.parseEther("1.0"));
      const contractBalance = await ethers.provider.getBalance(collectible.address);
      expect(contractBalance).to.equal(ethers.utils.parseEther("0.0"));
    });

    it("Should update terms", async function () {
      // Advance time by the decay period
      await ethers.provider.send("evm_increaseTime", [30 * 24 * 60 * 60]);
      await ethers.provider.send('evm_mine');

      const newMintBaseFee = ethers.utils.parseEther("0.1");
      const newCreatorSignatureFee = ethers.utils.parseEther("0.15");
      const newMaxMintsPerUser = 10;

      await collectible.updateTerms(newMintBaseFee, newCreatorSignatureFee, newMaxMintsPerUser);

      expect(await collectible.mintBaseFee()).to.equal(newMintBaseFee);
      expect(await collectible.creatorSignatureFee()).to.equal(newCreatorSignatureFee);
      expect(await collectible.maxMintsPerUserInCycle()).to.equal(newMaxMintsPerUser);
    });

  });
});
