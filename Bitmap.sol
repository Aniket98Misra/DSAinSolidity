// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BitmapClaimTracker {
    // Each uint256 maps to 256 individual boolean flags.
    // wordIndex => 256-bit word
    mapping(uint256 => uint256) public claimedBitMap;

    /**
     * @dev Checks if a specific index has claimed.
     */
    function isClaimed(uint256 _index) public view returns (bool) {
        // Find which 256-bit word this index lives in
        uint256 wordIndex = _index / 256;
        
        // Find exactly which bit (0-255) represents this index inside that word
        uint256 bitIndex = _index % 256;
        
        // Create a mask with a 1 at the target bit position
        uint256 mask = 1 << bitIndex;
        
        // Bitwise AND isolates the target bit. If it's > 0, the bit was 1 (claimed).
        return (claimedBitMap[wordIndex] & mask) != 0;
    }

    /**
     * @dev Sets an index as claimed. 
     * Reverts if already claimed to prevent double-spending.
     */
    function claim(uint256 _index) external {
        require(!isClaimed(_index), "Already claimed");

        uint256 wordIndex = _index / 256;
        uint256 bitIndex = _index % 256;
        
        // Create a mask with a 1 at the target bit position
        uint256 mask = 1 << bitIndex;

        // Bitwise OR flips the target bit to 1 while leaving all other bits unchanged
        claimedBitMap[wordIndex] = claimedBitMap[wordIndex] | mask;

        // ... Execute airdrop transfer logic ...
    }
}
