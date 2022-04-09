// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { ScopeToken } from "../typechain";

async function main() {
  // We get the contract to deploy
  const [signer] = await ethers.getSigners();
  const ScopeTixToken = "0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e";
  const StakersToken = "0x5f3f1dBD7B74C6B46e8c44f98792A1dAf8d69154"
  const MockAggregator = "0x610178dA211FEF7D417bC0e6FeD39F05609AD788";
  const assetFactory = "0x922D6956C99E12DFeB3224DEA977D0939758A1Fe";
  const stakeFactory = "0x5081a39b8A5f0E35a8D959395a630b68B74Dd30f";
  const platform = "0x1fA02b2d6A771842690194Cf62D91bdd92BfE28d";
  const assetAddress = "0xEb34c7AF8D387Cc94d6f31Ed128ab838C8AC0ae9";
  const stakeFactoryAsset = "0x3b7E32d3d292068d09Bc12661371Cff65B9C732b"
  const ScopeTixTokenInteract = await ethers.getContractAt("ScopeToken",ScopeTixToken)
  const StakersTokenInteract = await ethers.getContractAt("StakersToken",StakersToken)
  const Platform = await ethers.getContractAt("Platform",platform);
  // const deployPlatform = await Platform.deploy(StakersToken,assetFactory,stakeFactory);

  // await deployPlatform.deployed();

  console.log("Platform deployed to:", Platform.address);

 //await deployPlatform.addAsset("Demo asset",MockAggregator);

//  await ScopeTixTokenInteract.connect(signer).approve(
//      deployThetix.address,
//      "100000000000000"
//  )

//  console.log("view allowance:", await ScopeTixTokenInteract.allowance(signer.address, deployThetix.address));
 

//  await deployThetix.speculate("Demo asset", "100");

//  console.log("Balance:", await ScopeTixTokenInteract.balanceOf(signer.address));
 

//  console.log("Get latest Price:",await deployThetix.getLatestPrice("Demo asset"));

const addAsset =  await Platform.addAssetAggregator("Factory",MockAggregator);
// console.log(addAsset);

await StakersTokenInteract.approve(
  Platform.address,
  "1000000000000000000000000000000"
)

console.log("Allowance:",await StakersTokenInteract.allowance(
  signer.address,
  Platform.address
))

console.log("Amount:",await StakersTokenInteract.balanceOf(signer.address))

const buyAsset = await Platform.buyAsset("Factory", "100000000000000000000");

//console.log(buyAsset);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
