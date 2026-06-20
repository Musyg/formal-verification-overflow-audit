# Averaging Overflow, Demonstration Security Review

![tests](https://github.com/Musyg/formal-verification-overflow-audit/actions/workflows/ci.yml/badge.svg)

A self-contained demonstration of a formal-verification security review: an integer-averaging
function with an unchecked-overflow bug, a [Halmos](https://github.com/a16z/halmos) symbolic
property that returns a concrete counterexample on `master`, and a `fixed` branch where Halmos
proves the property holds for every `uint256` input.

> This is a demonstration on intentionally vulnerable code. `Average.sol` was written to
> showcase formal-verification methodology end to end. It is not production code, not a real
> client engagement, and must never be deployed. The finding is a real correctness bug in this
> demo library, not an invented severity.

## Why this repo exists

Anyone can write "I do formal verification" in a bio. This repo shows the work instead: a
property, a target that violates it, a machine-checked counterexample, and a fix the prover
verifies for all inputs. A test samples; a proof covers the whole domain. If it isn't
reproducible, it isn't done.

## Repository layout

The review lives across two branches:

| Branch | Contents | What a green check means |
|--------|----------|--------------------------|
| `master` | The overflowing `avg` and the symbolic property | Halmos returns a counterexample: the property is violated |
| `fixed`  | The overflow-free `avg` and the same property | Halmos proves the property for all `uint256` inputs |

- `src/Average.sol`, the library under review
- `test/Average.symbolic.t.sol`, the Halmos property `check_avg_withinBounds`
- `scripts/verify.sh`, runs Halmos and checks the outcome against `EXPECT.txt`
- `Averaging_Overflow_Review.pdf`, the full written report

## Finding

| ID | Severity | Summary |
|----|----------|---------------------------------------------------------------|
| M-01 | Medium | Averaging overflow. `avg(a, b)` computes `(a + b) / 2` inside an `unchecked` block. When `a + b` exceeds `2^256 - 1` it wraps, so the result falls outside `[min(a,b), max(a,b)]`. Halmos finds it instantly: `a = 0xc000...0000`, `b = 0x4000...0000`, whose sum is exactly `2^256` and wraps to `0`, giving `avg = 0` while `min(a,b) = 0x4000...0000`. Any caller that trusts the result to be bounded (a price midpoint, a threshold, a median) inherits the break. |

The property is the bound itself: the average must lie between the two inputs. On `master`
Halmos refutes it with the inputs above; on `fixed` Halmos proves it for the whole `uint256`
domain.

## Reproduce it

Requires [Foundry](https://book.getfoundry.sh/getting-started/installation) and
[Halmos](https://github.com/a16z/halmos) (`pip install halmos`).

```bash
git clone https://github.com/Musyg/formal-verification-overflow-audit.git
cd formal-verification-overflow-audit
forge install

# master: Halmos returns a counterexample
bash scripts/verify.sh

# fixed: Halmos proves the property
git checkout fixed
bash scripts/verify.sh
```

Or call Halmos directly: `halmos --function check_avg_withinBounds`.

## The fix

Never form the sum. Order the inputs and add half the gap to the smaller one:

```solidity
(uint256 lo, uint256 hi) = a < b ? (a, b) : (b, a);
return lo + (hi - lo) / 2;
```

`hi - lo` cannot underflow (`lo <= hi`), and `lo + (hi - lo) / 2 <= hi <= type(uint256).max`,
so no intermediate value overflows and the result is always in `[lo, hi]`. Halmos proves it.

## Why a proof, not a test

A fuzzer samples the input space; it can pass while a bug hides in inputs it never drew. Halmos
treats `a` and `b` as fully symbolic and discharges the property with an SMT solver, so a green
result on `fixed` means the bound holds for all `2^512` input pairs, not merely the ones a test
happened to try. That exhaustiveness is the point of formal verification.

## How severity is rated

Medium. The bug is a correctness violation in a utility function. Its impact depends on the
caller: a consumer that relies on the average being bounded (pricing, thresholds, medians) can
be pushed to a wrong branch or a zero value. Rated as a proven correctness break whose
downstream severity is context dependent.
