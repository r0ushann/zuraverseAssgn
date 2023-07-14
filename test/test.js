const { ethers } = require("hardhat");
const { expect } = require("chai");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");


async function runTests() {
  let seedToken;

  before(async function () {
    // Deploy SeedToken contract
    const SeedToken = await ethers.getContractFactory("SeedToken");
    seedToken = await SeedToken.deploy();
    await seedToken.deployed();
  });

  it("should deploy SeedToken", async function () {
    console.log("SeedToken deployed successfully: ", seedToken.address);
  });

  it("should mint seed tokens and plant seeds", async function () {
    // Mint seed tokens
    await seedToken.mintSeed();
    await seedToken.mintSeed();

    // Check seed balance
    const seedBalance = await seedToken.balanceOf(await ethers.getSigners()[0].address);
    expect(seedBalance).to.equal(2);

    // Plant seeds
    await seedToken.plantSeed(1, 1);
    await seedToken.plantSeed(2, 2);
  });

  it("should add water and generate Tree NFT", async function () {
    // Add water to seeds
    await seedToken.addWater(await ethers.getSigners()[0].address, 1, 1);
    await seedToken.addWater(await ethers.getSigners()[0].address, 2, 2);

    // Generate Tree NFT
    await seedToken.generateTreeNFT(1, 1);
    await seedToken.generateTreeNFT(2, 2);
  });
}

runTests()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
