//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    uint public nextId;

    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        require(date>block.timestamp, "You can only organize event for future dates");
        require(ticketCount>0, "You can only organize event if you create more than 0 tickets");
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable
    {
        require(events[id].date != 0, "This event doesn't exist");
        require(events[id].date>block.timestamp, "The event has already occured");
        require(msg.value >= (events[id].price*quantity), "Ether is not enough");
        require(events[id].ticketRemain >= quantity, "Not enough tickets");
        tickets[msg.sender][id] += quantity;
        payable(msg.sender).transfer(msg.value-(events[id].price*quantity));
    }

    function transferTicket(uint id, uint quantity, address to) external {
        require(events[id].date != 0, "This event doesn't exist");
        require(events[id].date>block.timestamp, "The event has already occured");
        require(tickets[msg.sender][id] >= quantity, "You don't have enough tickets");
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }
}