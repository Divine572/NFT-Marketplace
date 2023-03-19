// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "/Users/apple/Desktop/NFT-marketplace/node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "/Users/apple/Desktop/NFT-marketplace/node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "/Users/apple/Desktop/NFT-marketplace/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";



contract NFTMarketplace {
    using SafeMath for uint256;

    struct Auction {
        address tokenAddress;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        uint256 endTime;
        bool active;
    }

    address public owner;
    uint256 public feePercentage; // percentage of the sale price taken as fee
    mapping(address => mapping(uint256 => Auction)) public auctions; // map of all active auctions

    event AuctionCreated(
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        uint256 endTime
    );
    event AuctionEnded(
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    constructor() {
        owner = msg.sender;
        feePercentage = 1; // 1% fee by default
    }

    function createAuction(address _tokenAddress, uint256 _tokenId, uint256 _price, uint256 _duration) public {
        require(_duration > 0, "Duration must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        IERC721 tokenContract = IERC721(_tokenAddress);
        require(tokenContract.ownerOf(_tokenId) == msg.sender, "You don't own this NFT");

        uint256 endTime = block.timestamp.add(_duration);
        Auction memory auction = Auction(_tokenAddress, _tokenId, payable(msg.sender), _price, endTime, true);

        auctions[_tokenAddress][_tokenId] = auction;

        emit AuctionCreated(_tokenAddress, _tokenId, msg.sender, _price, endTime);
    }

    function endAuction(address _tokenAddress, uint256 _tokenId) public {
        Auction storage auction = auctions[_tokenAddress][_tokenId];
        require(auction.active, "Auction has already ended");
        require(block.timestamp >= auction.endTime, "Auction hasn't ended yet");

        address payable seller = auction.seller;
        uint256 price = auction.price;
        auction.active = false;

        IERC721 tokenContract = IERC721(_tokenAddress);
        tokenContract.safeTransferFrom(address(this), msg.sender, _tokenId);

        uint256 fee = price.mul(feePercentage).div(100);
        seller.transfer(price.sub(fee));

        emit AuctionEnded(_tokenAddress, _tokenId, msg.sender, price);
    }

    function setFeePercentage(uint256 _feePercentage) public {
        require(msg.sender == owner, "Only the owner can set the fee percentage");
        require(_feePercentage >= 0 && _feePercentage <= 100, "Fee percentage must be between 0 and 100");
        feePercentage = _feePercentage;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        address payable self = payable(address(this));
        self.transfer(self.balance);
    }

    // fallback function
    receive() external payable {}
}
