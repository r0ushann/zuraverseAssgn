const { ethers } = require("hardhat");

async function main() {
  // Deploy SeedToken contract
  const SeedToken = await ethers.getContractFactory("SeedToken");
  const seedToken = await SeedToken.deploy();
  await seedToken.deployed();
  console.log("SeedToken deployed to:", seedToken.address);

  // Deploy Tree contract with SeedToken contract address as an argument
  const Tree = await ethers.getContractFactory("Tree");
  const tree = await Tree.deploy(seedToken.address);
  await tree.deployed();
  console.log("Tree deployed to:", tree.address);

  // Set the Tree contract address in the SeedToken contract
  await seedToken.connect(tree.address).setTreeContractAddress(tree.address);
  console.log("Tree contract address set in SeedToken contract");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
