// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceOracleBuffer {
    // The fixed size of our history window
    uint256 public constant BUFFER_SIZE = 10;
    
    // Fixed-size array to store the prices
    uint256[BUFFER_SIZE] public priceHistory;
    
    // Pointers and tracking metrics
    uint256 public head;        // Points to the next index to write to
    uint256 public totalItems;  // Counts total updates (caps at BUFFER_SIZE for calculations)
    uint256 public runningSum;  // Keeps a running sum to make averaging O(1) gas

    event PriceUpdated(uint256 newPrice, uint256 newAverage);

    /**
     * @notice Adds a new price to the circular buffer and updates the moving average.
     * @param _price The newest price feed data.
     */
    function addPrice(uint256 _price) external {
        // If the buffer is full, we are about to overwrite the oldest price.
        // Subtract the old price from the running sum before overwriting it.
        if (totalItems == BUFFER_SIZE) {
            runningSum -= priceHistory[head];
        } else {
            totalItems++;
        }

        // Write the new price over the oldest data
        priceHistory[head] = _price;
        
        // Add the new price to our running sum
        runningSum += _price;

        // Advance the head pointer and wrap it around using the modulo operator
        head = (head + 1) % BUFFER_SIZE;

        emit PriceUpdated(_price, getMovingAverage());
    }

    /**
     * @notice Calculates the sliding window average of the recorded prices.
     * @return The O(1) gas moving average.
     */
    function getMovingAverage() public view returns (uint256) {
        if (totalItems == 0) return 0;
        return runningSum / totalItems;
    }

    /**
     * @notice Helper to fetch the entire history in order from oldest to newest.
     * @dev Mostly for off-chain/frontend consumption to avoid heavy on-chain loops.
     */
    function getHistory() external view returns (uint256[] memory) {
        uint256[] memory orderedHistory = new uint256[](totalItems);
        
        // If buffer isn't full, oldest is at index 0
        // If buffer is full, oldest is right where 'head' is currently pointing
        uint256 start = totalItems == BUFFER_SIZE ? head : 0;

        for (uint256 i = 0; i < totalItems; i++) {
            orderedHistory[i] = priceHistory[(start + i) % BUFFER_SIZE];
        }

        return orderedHistory;
    }
}
