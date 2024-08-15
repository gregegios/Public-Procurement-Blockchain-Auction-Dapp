// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiAuction {
    address public owner;

    struct Bid {
        address bidder;
        uint256 bidAmount;
        string secondNumber; // Must be 32 characters long.
    }

    struct Auction {
        string name;
        uint256 startTime;
        uint256 endTime;
        bool started;
        uint256 lowestBid;
        address lowestBidder;
        bool isFirstBid;
        string lowestBidderName; // New field to store the name of the lowest bidder after auction ends
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public nextAuctionId;

    event NewBid(uint256 indexed auctionId, address bidder, uint256 amount, string secondNumber);
    event NewAuction(uint256 indexed auctionId, string name, uint256 startTime, uint256 endTime, bool started, uint256 lowestBid, address lowestBidder);
    event NameSubmitted(uint256 indexed auctionId, string name);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the auction owner.");
        _;
    }

    modifier auctionActive(uint256 auctionId) {
        require(block.timestamp >= auctions[auctionId].startTime && block.timestamp <= auctions[auctionId].endTime, "Auction is not active or has ended.");
        _;
    }

    modifier postAuction(uint256 auctionId) {
        require(block.timestamp > auctions[auctionId].endTime && block.timestamp <= auctions[auctionId].endTime + 5 minutes, "Not the correct time to submit name.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startAuction(string memory name, uint256 customStartTime) external onlyOwner {
        uint256 auctionId = nextAuctionId++;
        Auction storage auction = auctions[auctionId];
        auction.name = name;
        auction.startTime = customStartTime;
        auction.endTime = customStartTime + 5 minutes;
        auction.started = true;
        auction.lowestBid = 0;
        auction.isFirstBid = true;

        emit NewAuction(auctionId, name, auction.startTime, auction.endTime, auction.started, auction.lowestBid, auction.lowestBidder);
    }

    function submitBid(uint256 auctionId, uint256 bidAmount, string memory secondNumber) external auctionActive(auctionId) {
        require(bytes(secondNumber).length == 32, "The second number must be exactly 32 characters long.");
        Auction storage auction = auctions[auctionId];

        if (auction.isFirstBid) {
            auction.lowestBid = bidAmount;
            auction.lowestBidder = msg.sender;
            auction.isFirstBid = false;
        } else if (bidAmount < auction.lowestBid) {
            auction.lowestBid = bidAmount;
            auction.lowestBidder = msg.sender;
        }

        emit NewBid(auctionId, msg.sender, bidAmount, secondNumber);
    }

    function submitName(uint256 auctionId, string calldata name) external postAuction(auctionId) {
        require(msg.sender == auctions[auctionId].lowestBidder, "Only the lowest bidder can submit their name.");
        Auction storage auction = auctions[auctionId];
        auction.lowestBidderName = name;

        emit NameSubmitted(auctionId, name);
    }

    function checkAuctionStatus(uint256 auctionId) external view returns (bool, address, uint256, string memory) {
        Auction storage auction = auctions[auctionId];
        bool hasEnded = block.timestamp > auction.endTime;
        return (hasEnded, auction.lowestBidder, auction.lowestBid, auction.lowestBidderName);
    }

    function getAuction(uint256 auctionId) external view returns (Auction memory) {
        return auctions[auctionId];
    }

}
