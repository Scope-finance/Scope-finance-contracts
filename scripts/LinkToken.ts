import { log } from "console";
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const LinkToken = await ethers.getContractFactory("LinkToken");
  const deployLinkToken= await LinkToken.deploy();

  await deployLinkToken.deployed();

  const [addr1,addr2,addr3,addr4,addr5] = await ethers.getSigners();

  console.log("Link Token deployed to:", deployLinkToken.address);

  console.log("Testing 1",await deployLinkToken.linkToken());

  const data = ethers.utils.formatBytes32String("Hello");

  console.log("bool1:",await deployLinkToken.transferAndCall(addr2.address,100,data));

  console.log("bool2:",await deployLinkToken.transfer(addr3.address,20));
  
  console.log("bool3:", await deployLinkToken.approve(addr3.address,10));

  //console.log("bool4:", await deployLinkToken.transferFrom(addr2.address,addr3.address,10));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});