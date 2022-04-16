const hre = require("hardhat");
require("@nomiclabs/hardhat-etherscan");


async function main() {

    const multicall = await hre.ethers.getContractFactory("Multicall");
    const multiCallInstance = await multicall.deploy();
    await multiCallInstance.deployed()
    const multiCallAddress = multiCallInstance.address;
    console.log("Multicall Deployed :",multiCallAddress)
  
  }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
