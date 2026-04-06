// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DoublyLinkedListOrderBook
 * @notice A gas-efficient way to manage ordered limit orders.
 */
contract DexOrderBook {
    struct Order {
        uint256 id;
        address creator;
        uint256 price;
        uint256 amount;
        uint256 next; // ID of the next order (lower priority/price)
        uint256 prev; // ID of the previous order (higher priority/price)
    }

    mapping(uint256 => Order) public orders;
    uint256 public head; // Highest priority order
    uint256 public tail; // Lowest priority order
    uint256 public orderCount;

    event OrderAdded(uint256 id, uint256 price, uint256 prev, uint256 next);
    event OrderRemoved(uint256 id);

    /**
     * @dev Inserts an order between two known nodes.
     * @param _id New Order ID
     * @param _price Price of the order
     * @param _prev ID of the order that should come BEFORE this one
     */
    function insertOrder(uint256 _id, uint256 _price, uint256 _prev) external {
        require(orders[_id].id == 0, "Order ID exists");
        
        Order storage newOrder = orders[_id];
        newOrder.id = _id;
        newOrder.price = _price;
        newOrder.creator = msg.sender;

        if (head == 0) {
            // Case 1: First order in the book
            head = _id;
            tail = _id;
        } else if (_prev == 0) {
            // Case 2: Insert at the very front (New Head)
            newOrder.next = head;
            orders[head].prev = _id;
            head = _id;
        } else {
            // Case 3: Insert in the middle or at the tail
            uint256 _next = orders[_prev].next;
            
            newOrder.prev = _prev;
            newOrder.next = _next;

            orders[_prev].next = _id;

            if (_next != 0) {
                orders[_next].prev = _id;
            } else {
                tail = _id; // It was inserted after the old tail
            }
        }

        orderCount++;
        emit OrderAdded(_id, _price, newOrder.prev, newOrder.next);
    }

    /**
     * @dev $O(1)$ removal of an order.
     */
    function removeOrder(uint256 _id) external {
        Order storage order = orders[_id];
        require(order.id != 0, "Order not found");

        if (order.prev != 0) {
            orders[order.prev].next = order.next;
        } else {
            head = order.next; // Removing the head
        }

        if (order.next != 0) {
            orders[order.next].prev = order.prev;
        } else {
            tail = order.prev; // Removing the tail
        }

        delete orders[_id];
        orderCount--;
        emit OrderRemoved(_id);
    }
}
