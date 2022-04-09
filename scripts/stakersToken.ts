// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [signer] = await ethers.getSigners();
  const StakersToken = "0x5f3f1dBD7B74C6B46e8c44f98792A1dAf8d69154"
  const StakersTokens = await ethers.getContractAt("StakersToken",StakersToken);
//   const deployStakersTokens = await StakersTokens.deploy("StakersToken", "STR");

//   await deployStakersTokens.deployed();

  console.log("StakersTokens token deployed to:", StakersTokens.address);

  await StakersTokens.addPlatform(signer.address);

  await StakersTokens.mint(signer.address,"1000000000000000000000");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
