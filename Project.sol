//SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.1.0 < 0.9.0;
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool)voters;

    }
    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline; //10 sec + 3600 sec
        minimumContribution= 1 wei;
        manager=msg.sender;
    }
    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed ");
        require(msg.value >= minimumContribution , "Minimum Contribution is not met.");

        if(contributors[msg.sender]==0){
            noOfContributors++;

        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

        
    }
    function getContractBalnace() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp > deadline && raisedAmount < target , "your are not eligible to refund.");
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
     modifier onlyManager(){
        require(msg.sender==manager," only manager can call this function");
         _;
        
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed =false;
        newRequest.noOfVoters =0;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be Contributor.");
        Request storage thisRequest=requests[_requestNo];
        require (thisRequest.voters[msg.sender]==false, "you have already Voted");
        thisRequest.voters[msg.sender]==true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>= target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;

    }

    


}
