// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

error ONLYELECTIONORGANIZER();
error ELECTIONALREADYSTARTED();
error ELECTIONNOTSTARTED();
error ELECTIONHASSTOPPED();
error ELECTIONNOTSTOPPEDYET();
error CANDIDATEALREADYREGISTERED();
error INVALIDCANDIDATEID();

contract Election {
    // State variables
    address public immutable organizer; // address of event organizer
    uint256 public candidateCount; // total number of candidates

    // boolean variables for checking the status of election
    bool public isElectionStarted;
    bool public isElectionStopped;

    mapping(uint256 => Candidate) public candidates; // mapping id with candidate Struct
    mapping(address => bool) public isRegisterdCandidate; //mapping address of a candidate with a boolean value to check whether the addresss is connected or not.

    // Structure for candidate
    struct Candidate {
        address add;
        string position;
        uint256 voteCount;
    }

    // Modifiers
    modifier onlyOrganizer() {
        if (msg.sender != organizer) {
            revert ONLYELECTIONORGANIZER();
        }
        _;
    }

    modifier onlyWhenNotStarted() {
        if (isElectionStarted) {
            revert ELECTIONALREADYSTARTED();
        }
        _;
    }

    modifier onlyWhenStarted() {
        if (!isElectionStarted) {
            revert ELECTIONNOTSTARTED();
        }
        _;
    }

    modifier onlyWhenNotStopped() {
        if (isElectionStopped) {
            revert ELECTIONHASSTOPPED();
        }
        _;
    }

    modifier onlyWhenStopped() {
        if (!isElectionStopped) {
            revert ELECTIONNOTSTOPPEDYET();
        }
        _;
    }
    modifier isCandidateRegisterd(address add) {
        if (isRegisterdCandidate[add]) {
            revert CANDIDATEALREADYREGISTERED();
        }
        _;
    }

    // Events
    event CandidateAdded(
        uint256 indexed candidateId,
        address add,
        string position
    );
    event ElectionStarted();
    event ElectionStopped();
    event VoteCast(address indexed voter, uint256 indexed candidateId);

    // Constructor
    constructor() {
        organizer = msg.sender;
    }

    // Public Functions

    // Function to start an election
    function startElection()
        public
        onlyOrganizer
        onlyWhenNotStarted
        onlyWhenNotStopped
    {
        isElectionStarted = true;
        emit ElectionStarted();
    }

    // function to stop an election
    function stopElection()
        public
        onlyOrganizer
        onlyWhenStarted
        onlyWhenNotStopped
    {
        isElectionStopped = true;
        emit ElectionStopped();
    }

    // function to add a candidate
    function addCandidate(
        address _add,
        string memory _position
    )
        public
        onlyOrganizer
        isCandidateRegisterd(_add)
        onlyWhenNotStarted
        onlyWhenNotStopped
    {
        candidates[candidateCount] = Candidate(_add, _position, 0); // Adding a new candidate
        isRegisterdCandidate[_add] = true;
        emit CandidateAdded(candidateCount, _add, _position);
        candidateCount++;
    }

    // function to declare the winner of the election
    function winner() public view onlyWhenStopped returns (address) {
        uint256 winningVoteCount;
        address winningCandidateId;
        for (uint256 i; i <= candidateCount; ) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = candidates[i].add;
            }
            unchecked {
                i++;
            }
        }
        return winningCandidateId;
    }

    // External functions

    // Function to update the vote of a candidate
    // @note : Though this function is declared in the Election contract it cannot be called in this contract as it is an external function.
    // @returns : bool

    function updateVote(
        uint256 _candidateId
    ) external onlyWhenStarted onlyWhenNotStopped returns (bool) {
        if (_candidateId > candidateCount) {
            revert INVALIDCANDIDATEID();
        }
        candidates[_candidateId].voteCount++;
        emit VoteCast(msg.sender, _candidateId);
        return true;
    }


}
