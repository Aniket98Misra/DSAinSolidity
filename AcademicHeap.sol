// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LiquidationHeap {
    struct Position {
        address user;
        uint256 healthFactor; // Scaled by 1e18. < 1e18 means liquidatable.
    }

    Position[] public heap;
    
    // Tracks the exact array index of a user's position for O(1) lookups
    mapping(address => uint256) public userIndex;

    // Standard Min-Heap insertion
    function insertOrUpdate(address _user, uint256 _healthFactor) external {
        uint256 index = userIndex[_user];
        
        if (index == 0 && (heap.length == 0 || heap[0].user != _user)) {
            // New user (assuming we leave index 0 empty for simpler math, 
            // but implemented 0-indexed here for standard array behavior)
            heap.push(Position({user: _user, healthFactor: _healthFactor}));
            uint256 newIndex = heap.length - 1;
            userIndex[_user] = newIndex;
            _bubbleUp(newIndex);
        } else {
            // Update existing user
            uint256 oldFactor = heap[index].healthFactor;
            heap[index].healthFactor = _healthFactor;
            
            if (_healthFactor < oldFactor) {
                _bubbleUp(index);
            } else {
                _bubbleDown(index);
            }
        }
    }

    function _bubbleUp(uint256 _index) internal {
        while (_index > 0) {
            uint256 parentIndex = (_index - 1) / 2;
            
            // If current node is >= parent, the heap property is satisfied
            if (heap[_index].healthFactor >= heap[parentIndex].healthFactor) {
                break;
            }
            
            _swap(_index, parentIndex);
            _index = parentIndex;
        }
    }

    function _bubbleDown(uint256 _index) internal {
        uint256 length = heap.length;
        
        while (true) {
            uint256 leftChild = 2 * _index + 1;
            uint256 rightChild = 2 * _index + 2;
            uint256 smallest = _index;

            if (leftChild < length && heap[leftChild].healthFactor < heap[smallest].healthFactor) {
                smallest = leftChild;
            }
            
            if (rightChild < length && heap[rightChild].healthFactor < heap[smallest].healthFactor) {
                smallest = rightChild;
            }

            if (smallest == _index) {
                break;
            }
            
            _swap(_index, smallest);
            _index = smallest;
        }
    }

    function _swap(uint256 _i, uint256 _j) internal {
        Position memory temp = heap[_i];
        
        heap[_i] = heap[_j];
        heap[_j] = temp;
        
        // The hidden gas killer: updating the index mapping for both users during every swap
        userIndex[heap[_i].user] = _i;
        userIndex[heap[_j].user] = _j;
    }
}
