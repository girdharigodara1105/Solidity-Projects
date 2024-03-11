//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract CrowdFunding
{
    mapping(address=>uint) public contributors;
    address public manager;
    uint target;
    uint deadline;
    uint raisedAmount;
    uint noOfContributors;
    uint minContribution;

    struct Request 
    {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline)
    {
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 0.1 ether;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= minContribution, "Minimum contribution is not met");

        if(contributors[msg.sender] == 0)
        {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance () public view returns (uint)
    {
        return address(this).balance;
    }

    function refund () public {
        require(block.timestamp > deadline && raisedAmount < target, "You are not eligible for refund");
        require(contributors[msg.sender] > 0, "You didn't contributed anything");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    modifier onlyManager ()
    {
        require (msg.sender == manager, "Only manager can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager
    {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest (uint _requestNo) public 
    {
        require(contributors[msg.sender] > 0, "You must be a contributor to vote");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager
    {
        require(raisedAmount >= target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "This request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2, "Majority doesn't support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
