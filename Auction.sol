pragma solidity >=0.7.0 <0.9.0;



contract Auction {

    // auction parameters
    // payable = this address can be used to send some coins
    address payable public beneficiary;
    uint public auctionEndTime;

    // variables of current state of auction
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    // auction ended or not
    bool ended = false;

    // events
    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }


    // users can bid
    function bid() public payable {
        if(block.timestamp > auctionEndTime){
            // revert stops the function from executing
            revert("Auction ended");
        }

        if(msg.value <= highestBid){
            revert("There is already a higher or equal bid");
        }

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
    }

    // overbid users can withdraw their coins
    function withdraw() public returns (bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    // auction end
    function auctionEnd() public {
        if(block.timestamp < auctionEndTime){
            revert("The auction not ended yet");
        }

        if(ended){
            revert("The function auction ended has already been called");
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // send return false if it fails
        // transfer stops if fails
        beneficiary.transfer(highestBid);
    }

}
