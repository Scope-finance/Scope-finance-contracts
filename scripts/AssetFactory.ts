import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const assetFactory = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
    const platform = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";

    const AssetFactory = await ethers.getContractAt("Factory",assetFactory);
    // const deployAssetFactory = await AssetFactory.deploy();
  
    // await deployAssetFactory.deployed();

  

    console.log("AssetFactory deployed to:", AssetFactory.address);
    //const byteCode = await AssetFactory.getBytecode("Factory","fct")

    // console.log(byteCode);

    const[signer] = await ethers.getSigners()

    // await ethers.provider.transaction.nonce
  
    const nonce = await ethers.provider.getTransactionCount(signer.address) + 1;

    console.log("Nonce:",nonce);
    
    await AssetFactory.addPlatform(platform);

    await AssetFactory.deploy(nonce,"Gold","xau")  
    console.log("assetAddress", await AssetFactory.assetAddress("Gold"));  
    //await deployAssetFactory.addPlatform()
    //await deployAssetFactory. 
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });