// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StackStrings {
    /**
     * @dev Concatenates two bytes32 strings natively on the stack.
     * bytes32 strings are strictly left-aligned.
     * Example: 
     * base = "Hello" (0x48656c6c6f0000...)
     * addition = "World" (0x576f726c640000...)
     */
    function concatenate(bytes32 base, uint256 baseByteLength, bytes32 addition) 
        public 
        pure 
        returns (bytes32) 
    {
        // To append 'addition' to 'base', we shift the addition to the right
        // by the number of bits already occupied in 'base'.
        // 1 byte = 8 bits.
        uint256 shiftBits = baseByteLength * 8;

        // Shift 'addition' right, then bitwise OR it with the base.
        return base | (addition >> shiftBits);
    }

    /**
     * @dev Slices a substring from a bytes32 word.
     * Extracts 'length' bytes starting from 'startIndex'.
     */
    function slice(bytes32 data, uint256 startIndex, uint256 length) 
        public 
        pure 
        returns (bytes32) 
    {
        // Shift left to drop the leading characters we don't want
        bytes32 shiftedLeft = data << (startIndex * 8);

        // We want to clear out the trailing characters after our target length.
        // We create a mask of 1s for the length we want to keep, shifted to the far left.
        // Example: If length is 3, mask is 0xFFFFFF00000...
        
        uint256 shiftRightBits = 256 - (length * 8);
        
        // This math creates the mask safely on the stack
        uint256 mask = type(uint256).max << shiftRightBits;

        // Bitwise AND keeps only our target slice, padded with zeros on the right
        return shiftedLeft & bytes32(mask);
    }

    /**
     * @dev Extracts a single character at a specific index using bit shifting.
     * (Solidity allows data[index] for bytes32, but doing it via shifts 
     * keeps it purely mathematical).
     */
    function getCharAt(bytes32 data, uint256 index) 
        public 
        pure 
        returns (bytes1) 
    {
        // Calculate how many bits to shift right to push the target byte 
        // to the furthest right position (lowest order byte).
        uint256 shiftBits = (31 - index) * 8;
        
        // Shift, then cast directly down to bytes1 to truncate the rest
        return bytes1(uint8(uint256(data) >> shiftBits));
    }
}
