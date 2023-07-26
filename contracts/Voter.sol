// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "contracts/Election.sol";

error ONLYORGANIZER();
error VOTERALREADYREGISTERED();
error NOTAREGISTEREDVOTER();
error ALREADYVOTED();

contract Voter {

    // State Variables
    Election private immutable election;//Instance of election

    // Mappings
    mapping(address => bool) public isVoterRegistered; // mapping to see if a user is registered or not.
    mapping(address => bool) public hasVoted;// mappping to check whether a user has voted or not.

    // Modifiers
    modifier onlyElectionOrganizer() {
        if(msg.sender != election.organizer()){
            revert ONLYORGANIZER();
        }
        _;
    }

    modifier onlyVoter() {
        if(!isVoterRegistered[msg.sender]){
            revert NOTAREGISTEREDVOTER();
        }
        _;
    }

    // Constructor
    constructor(address _electionContractAddress) {
        election = Election(_electionContractAddress);
    }

    // Functions

    //Function to register a voter before voting
    function registerVoter(address _voterAddress) public onlyElectionOrganizer {
        if(isVoterRegistered[_voterAddress]){
            revert VOTERALREADYREGISTERED();
        }
        isVoterRegistered[_voterAddress] = true;
    }

    // function to vote a candidate

    function vote(uint256 _candidateId) external onlyVoter {
        if(hasVoted[msg.sender]){
            revert ALREADYVOTED();
        }
        bool voted = election.updateVote(_candidateId);
        if(voted){
            hasVoted[msg.sender] = true;
        }
    }
}

