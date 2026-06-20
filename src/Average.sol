// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/// @title Average (remediated)
/// @notice Returns the floor average of two unsigned integers without overflow.
/// @dev The sum `a + b` is never formed. Ordering the inputs and computing
///      `lo + (hi - lo) / 2` keeps every intermediate value within uint256:
///      `hi - lo` does not underflow because lo <= hi, and `lo + (hi - lo) / 2 <= hi`,
///      so the result always lies in [lo, hi]. Halmos proves this for all inputs.
library Average {
    function avg(uint256 a, uint256 b) internal pure returns (uint256) {
        (uint256 lo, uint256 hi) = a < b ? (a, b) : (b, a);
        return lo + (hi - lo) / 2;
    }
}
