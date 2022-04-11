// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { ScopeToken } from "../typechain";

async function main() {
  // We get the contract to deploy
  const [signer, signer2] = await ethers.getSigners();
  const ScopeTixToken = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const StakersToken = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
  const MockAggregator = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const assetFactory = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
  const stakeFactory = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
  const platform = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
  const assetAddress = "0xEb34c7AF8D387Cc94d6f31Ed128ab838C8AC0ae9";
  const stakeFactoryAsset = "0x3b7E32d3d292068d09Bc12661371Cff65B9C732b"
  const ScopeTixTokenInteract = await ethers.getContractAt("ScopeToken",ScopeTixToken)
  const StakersTokenInteract = await ethers.getContractAt("StakersToken",StakersToken)
  const Platform = await ethers.getContractAt("Platform",platform);
  // const deployPlatform = await Platform.deploy(ScopeTixToken,assetFactory,stakeFactory);

  // await deployPlatform.deployed();

  console.log("Platform deployed to:", Platform.address);

  await Platform.addAsset("Factory",MockAggregator);


  // await Platform.addAssetAggregator("Factory",MockAggregator);
  
  // await ScopeTixTokenInteract.connect(signer2).approve(
  //   Platform.address,
  //   "10000000000000000000000000000000"
  // )
  
  // await Platform.connect(signer2).stakeOnAsset("Gold", "100000000000000000000")

  // console.log("view allowance:", await ScopeTixTokenInteract.allowance(signer2.address, Platform.address));

  // const assetAdd = await Platform.connect(signer2).assetAddress("Gold")

  // console.log("Gold add:", assetAdd);
  
  // const assetContract = await ethers.getContractAt("AssetContract",assetAdd)

  // assetContract.connect(signer).purchaseAssets("Gold","300000000000000000000")

  //  await deployThetix.speculate("Demo asset", "100");

  //  console.log("Balance:", await ScopeTixTokenInteract.balanceOf(signer.address));
 

  //  console.log("Get latest Price:",await deployThetix.getLatestPrice("Demo asset"));

  // const addAsset =  await Platform.addAssetAggregator("Factory",MockAggregator);
  // console.log(addAsset);

  // await StakersTokenInteract.approve(
  //   Platform.address,
  //   "1000000000000000000000000000000"
  // ) 

  // console.log("Allowance:",await StakersTokenInteract.allowance(
  //   signer.address,
  //   Platform.address
  // ))

  // console.log("Amount:",await StakersTokenInteract.balanceOf(signer.address))
  // const buyAsset = await Platform.buyAsset("Factory", "10000000000000000000000");

//console.log(buyAsset);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
