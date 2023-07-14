const { ethers } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

async function runTest(){
  let seedToken;
  let tree;


  before(async function () {
    // Deploy SeedToken contract
    const SeedToken = await ethers.getContractFactory("SeedToken");
    seedToken = await SeedToken.deploy();
    await seedToken.deployed();

    // Deploy Tree contract
    const Tree = await ethers.getContractFactory("Tree");
    tree = await Tree.deploy(seedToken.address());
    await tree.deployed();

  });

  /* it("should mint seed tokens and plant seeds", async function () {
    // Mint seed tokens
    await seedToken.mintSeed();
    await seedToken.mintSeed();

    // Check seed balance
    const seedBalance = await seedToken.balanceOf(await ethers.getSigners()[0].address);
    console.log("Seed Balance:", seedBalance.toString());

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
  }); */
};
