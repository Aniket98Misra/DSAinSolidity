// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OptimizedLendingPool {
    uint256 public constant LIQUIDATION_THRESHOLD = 1e18; // 1.0 Health Factor
    
    // Bare-metal mapping. No arrays, no bubbling, no tracking indices.
    mapping(address => uint256) public userCollateral;
    mapping(address => uint256) public userDebt;

    // Simplified oracle fetcher
    function getHealthFactor(address _user) public view returns (uint256) {
        // In reality, this involves fetching oracle prices: 
        // (collateralValue * liquidationThreshold) / debtValue
        if (userDebt[_user] == 0) return type(uint256).max;
        return (userCollateral[_user] * 1e18) / userDebt[_user];
    }

    // The Off-chain worker calls this directly with their target
    function liquidate(address _targetUser, address _collateralAsset, uint256 _debtToCover) external {
        uint256 currentHealth = getHealthFactor(_targetUser);
        
        // O(1) Verification: The contract only cares IF the user is liquidatable, 
        // not if they are the "most" liquidatable in the entire system.
        require(currentHealth < LIQUIDATION_THRESHOLD, "Health factor > 1");

        // ... Execute liquidation math, burn debt, transfer collateral + penalty ...
    }
}
