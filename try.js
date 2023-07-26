const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("Election Campaign", function () {
  let organizer, c1, c2, v1, v2, v3;
  let election;
  let voter;

  beforeEach(async () => {
    [organizer, c1, c2, v1, v2, v3] = await ethers.getSigners();

    const Election = await ethers.getContractFactory("Election")
    election = await Election.deploy();
    await election.deployed();

    const Voter = await ethers.getContractFactory("Voter")
    voter = await Voter.deploy(election.address);
    await voter.deployed();

  })

  describe("Checks after deployment", async () => {

    it("should return the address of organizer", async () => {
      const res = await election.organizer();
      expect(res).to.be.equal(organizer.address);
    })

    it("should return the total number of candidates", async () => {
      const res = await election.candidateCount();
      expect(res).to.be.equal(0);
    })

    it("should return the state of election", async () => {
      const res = await election.isElectionStarted();
      const res2 = await election.isElectionStarted();
      expect(res).to.be.equal(false);
      expect(res2).to.be.equal(false);
    })
  })

  describe('Checking whole election system', () => {
    beforeEach(async() => {
      const cand1 = await election.connect(organizer).addCandidate(c1.address,"CM");
      const cand2 = await election.connect(organizer).addCandidate(c2.address,"CM");
      const elect = await election.connect(organizer).startElection();

    })

    it("check if candidate is registered or not", async () => {
      const isC1Reg = await election.isRegisterdCandidate(c1.address);
      const isC2Reg = await election.isRegisterdCandidate(c2.address);
      expect(isC1Reg).to.be.equal(true);
      expect(isC2Reg).to.be.equal(true);
    })

    it("check if election has started or not", async () => {
      const elec = await election.isElectionStarted();
      expect(elec).to.be.equal(true);
    })

    it("should check voter is registered or not",async()=>{
      const isV1Reg = await voter.isVoterRegistered(v1.address);
      const isV2Reg = await voter.isVoterRegistered(v2.address);
      const isV3Reg = await voter.isVoterRegistered(v3.address);

      expect(isV1Reg).to.be.equal(false);
      expect(isV2Reg).to.be.equal(false);
      expect(isV3Reg).to.be.equal(false);
    })


    it("should register a voter",async()=>{
      const V1Reg = await voter.connect(organizer).registerVoter(v1.address);
      const V2Reg = await voter.connect(organizer).registerVoter(v2.address);
      const V3Reg = await voter.connect(organizer).registerVoter(v3.address);

      const isV1Reg = await voter.isVoterRegistered(v1.address);
      const isV2Reg = await voter.isVoterRegistered(v2.address);
      const isV3Reg = await voter.isVoterRegistered(v3.address);

      const v1Vote = await voter.connect(v1).vote(0);
      const v2Vote = await voter.connect(v2).vote(0);
      const v3Vote = await voter.connect(v3).vote(1);


      expect(isV1Reg).to.be.equal(true);
      expect(isV2Reg).to.be.equal(true);
      expect(isV3Reg).to.be.equal(true);

      const hasV1Voted = await voter.hasVoted(v1.address);
      expect(hasV1Voted).to.be.equal(true);
    })


    it("should allow a voter to vote and chk whether it has voted or not",async()=>{
      // const hasV1Voted = await voter.hasVoted(v1.address);
      // expect(hasV1Voted).to.be.equal(true);
    })

   })
})

