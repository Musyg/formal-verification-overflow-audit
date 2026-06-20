// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/// @title Average (vulnerable)
/// @notice Returns the floor average of two unsigned integers.
/// @dev BUG: the sum `a + b` is computed inside an `unchecked` block, so it can overflow
///      uint256 and wrap around. When it does, `(a + b) / 2` is far outside the interval
///      [min(a,b), max(a,b)]. This is the classic averaging-overflow bug (the same defect
///      that lived in binary search implementations for years). It only triggers for inputs
///      whose sum exceeds 2^256 - 1, so random fuzzing almost never hits it.
library Average {
    function avg(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return (a + b) / 2;
        }
    }
}
