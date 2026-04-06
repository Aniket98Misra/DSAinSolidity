// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MerkleProof
 * @dev Implementation of Merkle Tree proof verification.
 */
contract MerkleWhitelist {
    bytes32 public immutable merkleRoot;

    // To prevent a user from claiming twice
    mapping(address => bool) public hasClaimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Checks if a leaf belongs to the tree using a proof.
     * @param proof The sibling hashes at each level of the tree.
     * @param leaf The hash of the data we are verifying (e.g., address + amount).
     */
    function verify(bytes32[] calldata proof, bytes32 leaf) public view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // The "Sort Pairs" Trick: 
            // We hash the smaller value first to maintain a consistent tree structure
            // regardless of whether the user is a left or right child.
            if (computedHash <= proofElement) {
                // Hash(current, sibling)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(sibling, current)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }

    function claimAirdrop(uint256 amount, bytes32[] calldata proof) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        // Double Hashing (Security): Prevents "Second Preimage Attacks"
        // We hash the encoded data to create the leaf.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));

        require(verify(proof, leaf), "Invalid Merkle Proof");

        hasClaimed[msg.sender] = true;
        emit Claimed(msg.sender, amount);
        
        // (Logic to transfer tokens would go here)
    }
}
