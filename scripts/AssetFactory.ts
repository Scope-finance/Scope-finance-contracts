import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const assetFactory = "0x922D6956C99E12DFeB3224DEA977D0939758A1Fe";
    const platform = "0x1fA02b2d6A771842690194Cf62D91bdd92BfE28d";

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

    await AssetFactory.deploy(byteCode, nonce,"Factory")  
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