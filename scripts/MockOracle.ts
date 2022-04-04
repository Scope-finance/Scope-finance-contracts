// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const MockOracle = await ethers.getContractFactory("MockOracle");
  const deployedLinkAddress = "0x610178dA211FEF7D417bC0e6FeD39F05609AD788"
  const deployMockOracle = await MockOracle.deploy(deployedLinkAddress);

  await deployMockOracle.deployed();

  const [addr1,addr2,addr3,addr4,addr5] =await ethers.getSigners();

  console.log("MockOracle deployed to:", deployMockOracle.address);

  
 console.log("Get address" ,await deployMockOracle.getChainlinkToken());
  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
