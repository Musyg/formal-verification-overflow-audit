// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {Average} from "../src/Average.sol";

/// Symbolic property checked by Halmos over all uint256 inputs.
/// Halmos treats the function arguments as fully symbolic and either proves the assertion
/// for every input or returns a concrete counterexample.
contract AverageSymbolicTest is Test {
    /// The average of a and b must lie within [min(a,b), max(a,b)].
    function check_avg_withinBounds(uint256 a, uint256 b) public pure {
        uint256 m = Average.avg(a, b);
        uint256 lo = a < b ? a : b;
        uint256 hi = a < b ? b : a;
        assert(lo <= m && m <= hi);
    }
}
