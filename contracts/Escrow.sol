// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Escrow {
    enum Status {
        PENDING,
        PAID,
        ADJUDICATED,
        RELEASED,
        REFUNDED,
        RESOLVED,
        DELIVERED
    }
    address public buyer; // sender of the funds
    address payable public seller; // receiver of the funds
    address payable public jury; // jury that will decide the outcome in case of dispute
    uint256 public amount; // amount of the funds
    uint256 public fee; // fee paid by the receiver
    Status public status;

    event Paid(address sender, address receiver, uint256 amount);

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer pay");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can release the funds");
        _;
    }

    modifier onlyJury() {
        require(msg.sender == jury, "Only the jury can call this");
        _;
    }

    modifier notAdjudicated() {
        require(
            status != Status.ADJUDICATED,
            "Escrow is in adjudication process"
        );
        _;
    }

    constructor(
        uint256 _amount,
        uint256 _fee,
        address _seller,
        address _buyer
    ) {
        jury = payable(msg.sender);
        seller = payable(_seller);
        buyer = _buyer;
        amount = _amount;
        fee = _fee;
        status = Status.PENDING;
    }

    function deposit() external payable onlyBuyer {
        require(status == Status.PENDING, "Contract is already paid");
        require(msg.value == amount, "The amount must be equal to the funds");
        status = Status.PAID;
        emit Paid(buyer, seller, amount);
    }

    function confirm() public onlyBuyer {
        require(status == Status.PAID, "Contract has not been paid");
        status = Status.DELIVERED;
    }

    function release() public onlySeller notAdjudicated {
        require(status == Status.DELIVERED, "Contract has not been confirmed");
        seller.transfer(amount - fee);
        jury.transfer(fee);
        status = Status.RELEASED;
    }

    function adjudicate() public {
        require(status != Status.PENDING, "Contract is not paid");
        status = Status.ADJUDICATED;
    }

    function resolve(address _winner) public onlyJury {
        require(status == Status.ADJUDICATED, "Contract is not adjudicated");
        status = Status.RESOLVED;
        payable(_winner).transfer(amount - fee);
        jury.transfer(fee);
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }
}
