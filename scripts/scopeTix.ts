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
  const [signer,signer2] = await ethers.getSigners();
  
  const scopeTix = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
  const ScopeTix = await ethers.getContractAt("ScopeToken",scopeTix);
  // const deployScopeTix = await ScopeTix.deploy();

  // await deployScopeTix.deployed();

  console.log("ScopeTix token deployed to:", ScopeTix.address);


  await ScopeTix.mint(signer2.address,"1000000000000000000000");
  await ScopeTix.mint(signer.address,"1000000000000000000000");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
