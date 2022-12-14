pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public{
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
}

contract Campaign{
    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping (address=>bool) approvals;
    }
    address public manager;
    uint public minimumContribution;
    mapping (address => bool) public approvers;
    Request[] public requests;
    uint public approvalCount=0;

    modifier restricted(){
        require(msg.sender==manager);
        _;
    }

    function Campaign(uint minimum, address creator) public{
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable{
        require(msg.value > minimumContribution);
        approvers[msg.sender]=true;
        approvalCount++;
    }

    function createReuquest(string description, uint value, address recipient)
    public restricted {
        Request memory newRequest = Request({
            description:description,
            value:value,
            recipient:recipient,
            complete:false,
            approvalCount:0
        });  
        requests.push(newRequest); 
    }

    function approvalRequest(uint index) public{
        Request storage request = requests[index];
        require(request.approvals[msg.sender]==false);
        require(approvers[msg.sender]);

        request.approvals[msg.sender]=true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];

        require(!request.complete);
        require(request.approvalCount >(approvalCount/2));
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns(
        uint,uint,uint,uint,address
    ){
        return(
            minimumContribution,
            this.balance,
            requests.length,
            approvalCount,
            manager
        );
    }

    function getRequestCount() public view returns(uint){
        return requests.length;
    }

}