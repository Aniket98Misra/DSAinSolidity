// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleBloomFilter {
    // A 256-bit bitset stored in a single EVM storage slot.
    // (Ethereum mainnet block headers use a larger 2048-bit filter).
    uint256 public filter;

    /**
     * @dev Simulates 3 hash functions by extracting 3 distinct 
     * 8-bit integers from a single keccak256 hash.
     */
    function _getIndices(bytes memory data) internal pure returns (uint8, uint8, uint8) {
        bytes32 hash = keccak256(data);
        
        // Extracting three 8-bit numbers (0-255) to map to our 256-bit integer
        uint8 index1 = uint8(uint256(hash));
        uint8 index2 = uint8(uint256(hash >> 8));
        uint8 index3 = uint8(uint256(hash >> 16));
        
        return (index1, index2, index3);
    }

    /**
     * @dev Adds an element to the filter.
     */
    function add(bytes memory data) external {
        (uint8 i1, uint8 i2, uint8 i3) = _getIndices(data);
        
        // Use Bitwise OR to flip the bits at those indices to 1
        filter = filter | (uint256(1) << i1) | (uint256(1) << i2) | (uint256(1) << i3);
    }

    /**
     * @dev Checks if an element is in the filter.
     * Returns TRUE = "Might be in the set" (False positive possible)
     * Returns FALSE = "Definitely NOT in the set" (100% certainty)
     */
    function mightContain(bytes memory data) external view returns (bool) {
        (uint8 i1, uint8 i2, uint8 i3) = _getIndices(data);
        
        // Create a mask representing the bits that SHOULD be 1
        uint256 mask = (uint256(1) << i1) | (uint256(1) << i2) | (uint256(1) << i3);
        
        // Bitwise AND checks if the filter contains all 1s from the mask
        return (filter & mask) == mask;
    }
}
