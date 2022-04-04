// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const [signer] = await ethers.getSigners();
  const ScopeTixToken = "0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8"
  const MockAggregator = "0xc6e7DF5E7b4f2A278906862b61205850344D4e7d"
  const ScopeTixTokenInteract = await ethers.getContractAt("ScopeTix",ScopeTixToken)
  const Thetix = await ethers.getContractFactory("Thetix");
  const deployThetix = await Thetix.deploy(ScopeTixToken);

  await deployThetix.deployed();

  console.log("Thetix deployed to:", deployThetix.address);

 await deployThetix.addAsset("Demo asset",MockAggregator);

 await ScopeTixTokenInteract.connect(signer).approve(
     deployThetix.address,
     "100000000000000"
 )

 console.log("view allowance:", await ScopeTixTokenInteract.allowance(signer.address, deployThetix.address));
 

 await deployThetix.speculate("Demo asset", "100");

 console.log("Balance:", await ScopeTixTokenInteract.balanceOf(signer.address));
 

 console.log("Get latest Price:",await deployThetix.getLatestPrice("Demo asset"));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
