import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const stakeFactory = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
    const platform = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
  
    const StakeFactory = await ethers.getContractAt("StakeTokenFactory",stakeFactory);
    // const deploystakeFactory = await StakeFactory.deploy();
  
    // await deploystakeFactory.deployed();

    console.log("StakeFactory deployed to:", StakeFactory.address);

    //const byteCode = await StakeFactory.getBytecode("Factory", "fct");

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