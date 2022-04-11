import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const stakeFactory = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
    const platform = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
  
    const StakeFactory = await ethers.getContractAt("StakeTokenFactory",stakeFactory);
    // const deploystakeFactory = await StakeFactory.deploy();
  
    // await deploystakeFactory.deployed();

    console.log("StakeFactory deployed to:", StakeFactory.address);

    // //const byteCode = await StakeFactory.getBytecode("Factory", "fct");

     await StakeFactory.addPlatform(platform);

    const [signer] = await ethers.getSigners()

    const nonce = await ethers.provider.getTransactionCount(signer.address) + 1;

    await StakeFactory.deploy(nonce,"Gold","xau");

    console.log("StakeFactory asset adderss",await StakeFactory.assetAddress("Gold"));
    

  

    //console.log("stakeFactory deployed to:", deploystakeFactory.address);
    //const byteCode = await deployAssetFactory.getBytecode("Factory","fct")
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });