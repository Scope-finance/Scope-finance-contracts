import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const assetFactory = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
    const platform = "0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e";

    const AssetFactory = await ethers.getContractAt("Factory",assetFactory);
    // const deployAssetFactory = await AssetFactory.deploy();
  
    // await deployAssetFactory.deployed();

  

    console.log("AssetFactory deployed to:", AssetFactory.address);
    const byteCode = await AssetFactory.getBytecode("Factory","fct")

    // console.log(byteCode);

    const[signer] = await ethers.getSigners()

    //await ethers.provider.transaction.nonce
  
    const nonce = await ethers.provider.getTransactionCount(signer.address) + 1;

    console.log("Nonce:",nonce);

    console.log("assetAddress", await AssetFactory.assetAddress("Factory")
     );
    
    await AssetFactory.addPlatform(platform);

    await AssetFactory.deploy(nonce,"Factory","fct")  
    console.log("assetAddress", await AssetFactory.assetAddress("Factory"));  
    //await deployAssetFactory.addPlatform()
    //await deployAssetFactory. 
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });