const hre=require("hardhat");

async function main() {

  const Election = await ethers.getContractFactory("Election");
  const election = await Election.deploy();
  await election.deployed();

  console.log("Election deployed to:", election.address);

  const Voter = await hre.ethers.getContractFactory("Voter");
  const voter = await Voter.deploy(election.address);
  await voter.deployed();

  console.log("voter deployed to :",voter.address)
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
