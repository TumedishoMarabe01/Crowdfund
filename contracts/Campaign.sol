// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract Campaign{

    // Set once, at deployment, and never changeable afterwards.
    address public immutable creator;
    uint256 public immutable goal; // in wei (also a token)
    uint256 public immutable deadline; // Unix time, in seconds

    // Change every time someone contributes.
    uint256 public totalRaised;
    bool public withdrawn;
    mapping(address backer => uint256 amount) public contributions; //contribution variable like an array with an index(address) and the value(the amount).

    //Types of events
    event Contributed(address indexed backer, uint256 amount);
    event Withdrawn(address indexed creator, uint256 amount);
    event Refunded(address indexed backer, uint256 amount);

    //Custom errors
    error InvalidGoal();
    error InvalidDuration();
    error ZeroContribution();
    error CampaignEnded(uint256 deadline);
    error CampaignStillRunning(uint256 deadline);
    error NotCreator();
    error GoalNotReached(uint256 totalRaised, uint256 goal);
    error GoalReached();
    error AlreadyWithdrawn();
    error NothingToRefund();
    error TransferFailed();

    //modifiers - only allows the creator to withdraw
    modifier onlyCreator(){
        require(msg.sender == creator, NotCreator());
        _;
    }

    //only use this function if the campaign has elapsed
    modifier afterDeadline(){ 
        require(msg.sender == creator, CampaignStillRunning(deadline));
        _;
    }


    //Constructor used to intialise the immutable variables
    constructor(uint256 goal_, uint256 durationMinutes) {
        require(goal_ > 0, InvalidGoal());      //is like an if statement
        require(durationMinutes > 0, InvalidDuration());
        creator = msg.sender; //make use of msg state variable to get the address of the creator
        goal = goal_;
        deadline = block.timestamp + durationMinutes * 1 minutes; //block gives you the current time
    }

    // Backers send ether here; the contract keeps it.
    //payable used for when receiving money
    function contribute() external payable {
        require(msg.value > 0, ZeroContribution());
        require(block.timestamp < deadline, CampaignEnded(deadline));
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit Contributed(msg.sender, msg.value); //this will display under events 
    }

    // The creator collects the funds after the deadline if the goal was met.
    function withdraw() external onlyCreator afterDeadline {
        // Checks
        require(totalRaised >= goal, GoalNotReached(totalRaised, goal));
        require(!withdrawn, AlreadyWithdrawn());
        // Effects
        withdrawn = true; //withdraw when conditions are met
        uint256 amount = totalRaised;
        emit Withdrawn(creator, amount); 
        // Interaction
        (bool status,) = creator.call{value: amount}(""); //takes the money and puts it into the user account. The function returns two outputs. Without this line the creator wont get the money
        require(status, TransferFailed());
    }

    // A backer takes their money back after the deadline if the goal was missed.
    function refund() external afterDeadline {
        // Checks
        require(totalRaised < goal, GoalReached());
        uint256 amount = contributions[msg.sender];
        require(amount > 0, NothingToRefund());
        // Effects: zero the balance before sending, so a second call finds nothing to refund
        contributions[msg.sender] = 0;
        emit Refunded(msg.sender, amount);
        // Interaction
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, TransferFailed());
    }


}