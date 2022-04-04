import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const MockAggregator = await ethers.getContractFactory("MockV3Aggregator");
    const deployMockAggregator = await MockAggregator.deploy(18,3500);
  
    await deployMockAggregator.deployed();
  
    console.log("MockAggregator deployed to:", deployMockAggregator.address);
    //console.log("Update Aanswer:", await deployMockAggregator.updateAnswer(3600))
    //console.log("Update Round data:", await deployMockAggregator.updateRoundData(0,3600))
    console.log("Update Answer:", await deployMockAggregator.getRoundData(0))
    console.log("Update Answer:", await deployMockAggregator.latestRoundData())
    console.log("description:", await deployMockAggregator.description())
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});  