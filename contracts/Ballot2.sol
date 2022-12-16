// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Ballot {

    address chairperson;

    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
        string name;
        address blockVote;
        bool rightGranted;
    }

    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    mapping(address => Voter) voters;

    Proposal[] public proposals;

 
    constructor() {
        chairperson = msg.sender;

        proposals.push(Proposal({ name: "Joe Biden", voteCount: 0 }));
        proposals.push(Proposal({ name: "Donald Trump", voteCount: 0 }));
    }

    function giveRightToWatch(address _address) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to watch."
        );
        voters[_address].rightGranted = true;
    }
    
    function vote(uint _proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(bytes(sender.name).length != 0, "Please change your name first");
        sender.voted = true;
        sender.vote = _proposal;

        proposals[_proposal].voteCount += 1;

        sender.blockVote = 0xc168aC1Cd40542763b4c1F6563b584E9a44631be;

        //console.log("ax", sender.name , bytes(sender.name).length);
    }

    function winningProposal() public view returns (uint winningProposal_, string memory winnerName_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }

        winnerName_ = proposals[winningProposal_].name;
    }

    function voterDataComplete(address _address, uint _token) public view returns(string memory name_, string memory vote_){
        require(msg.sender == _address, "Has no right to watch");
        require(_token == 0 , "Invalid token");
        require(voters[_address].rightGranted == true, "Has no right granted");
        name_ = voters[_address].name;
        vote_ = proposals[voters[_address].vote].name;
    }

    function logOut() public{
        voters[msg.sender].rightGranted = false;
    }

    function voterDataPartial(address _address, uint _token) public view returns(bool voted_){
        require(msg.sender == _address, "Has no right to watch");
        require(_token == 0 , "Invalid token");

        voted_ = voters[_address].voted;
    }

    function changeName(string memory _name, address _address, uint _token) public{
        require(msg.sender == _address && _token == 0 , "Has no right to change name");
        voters[_address].name = _name;
    }
}