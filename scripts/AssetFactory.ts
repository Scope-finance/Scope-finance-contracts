import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
  
    const AssetFactory = await ethers.getContractFactory("Factory");
    const deployAssetFactory = await AssetFactory.deploy();
  
    await deployAssetFactory.deployed();
  
    console.log("AssetFactory deployed to:", deployAssetFactory.address);

   console.log(await deployAssetFactory.getBytecode("Factory","fct"));

    //await deployAssetFactory.addPlatform()
    //await deployAssetFactory.
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });