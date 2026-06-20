#!/usr/bin/env bash
# Run the Halmos symbolic check and compare the outcome to EXPECT.txt.
#   master: EXPECT.txt = counterexample  (the property is violated; Halmos returns inputs)
#   fixed : EXPECT.txt = proved          (Halmos proves the property for all uint256 inputs)
set -uo pipefail
cd "$(dirname "$0")/.."

out=$(halmos --function check_avg_withinBounds 2>&1)
echo "$out"

expect=$(tr -d '[:space:]' < EXPECT.txt)
if echo "$out" | grep -q "Counterexample"; then result="counterexample"; else result="proved"; fi

echo "--------"
echo "halmos result: $result | expected: $expect"
if [ "$result" = "$expect" ]; then
  echo "PASS"
  exit 0
else
  echo "MISMATCH"
  exit 1
fi
