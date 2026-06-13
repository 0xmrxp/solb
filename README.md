# solb — Solidity Building Blocks

[![CI](https://github.com/0xmrxp/solb/actions/workflows/ci.yml/badge.svg)](https://github.com/0xmrxp/solb/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/solb.svg)](https://www.npmjs.com/package/solb)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/solidity-%5E0.8.24-363636?logo=solidity)](https://docs.soliditylang.org/)
[![Built with Foundry](https://img.shields.io/badge/built%20with-Foundry-FFDB1C?logo=ethereum)](https://book.getfoundry.sh/)

**`solb`** is a lightweight, composable library of security-first Solidity primitives. Import the modules you need, inherit or attach them to your types, and ship with fewer footguns.

No bloat. No mandatory inheritance chains. Just focused, audited, gas-aware building blocks for the parts of smart contract development that get rewritten in every project — input validation, structured error handling, and intent lifecycle management.

---

## Table of Contents

- [Why solb](#why-solb)
- [Installation](#installation)
- [Modules](#modules)
  - [Guards](#guards)
  - [RevertLens](#revertlens)
  - [IntentBase](#intentbase)
- [Development](#development)
- [Roadmap](#roadmap)
- [Security](#security)
- [License](#license)

---

## Why solb

Every Solidity codebase ends up reimplementing the same handful of patterns:

- Zero-value and zero-address checks scattered everywhere
- Deadline and bounds validation with inconsistent error messages
- Custom errors with no machine-readable context for off-chain monitoring
- Hand-rolled intent/order lifecycle state machines for bridges, DEX aggregators, and cross-chain systems

`solb` extracts these into small, independently usable modules — each with full NatSpec, custom errors, and Foundry test coverage.

| Module | Purpose | Pattern |
|---|---|---|
| [`Guards`](#guards) | Defensive validation primitives (zero checks, bounds, deadlines, array lengths) | `using ... for` library |
| [`RevertLens`](#revertlens) | Structured reverts with on-chain context emission for off-chain indexing/debugging | Abstract contract (inherit) |
| [`IntentBase`](#intentbase) | Intent lifecycle management (`OPEN → FILLED / CANCELLED / EXPIRED`) | Abstract contract (inherit) |

---

## Installation

```bash
npm install solb
```

### Foundry

Add `node_modules` to your library paths in `foundry.toml`:

```toml
[profile.default]
libs = ["node_modules", "lib"]
```

### Hardhat

No extra configuration needed — Hardhat resolves `node_modules` by default.

```solidity
import { Guards } from "solb/contracts/guards/Guards.sol";
```

---

## Modules

### Guards

Library-on-type validation primitives. Each function reverts with a descriptive custom error on failure, or returns the original value for chaining on success.

```solidity
import { Guards } from "solb/contracts/guards/Guards.sol";

contract MyDEX {
    using Guards for uint256;
    using Guards for address;

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) external {
        tokenIn.notZero();
        tokenOut.notZero();
        amountIn.notZero().withinBounds(MIN_SWAP, MAX_SWAP);
        minAmountOut.notZero();
        deadline.notExpired();

        // ... swap logic
    }
}
```

**Available functions:**

| Function | Type | Description |
|---|---|---|
| `notZero(uint256)` | `uint256` | Reverts if value is `0` |
| `notZero(address)` | `address` | Reverts if address is `address(0)` |
| `notExpired(uint256 deadline)` | `uint256` | Reverts if `block.timestamp > deadline` |
| `withinBounds(uint256 value, uint256 min, uint256 max)` | `uint256` | Reverts if value is outside `[min, max]` |
| `equal(uint256 a, uint256 b)` | `uint256` | Reverts if `a != b` |
| `notContract(address)` | `address` | Reverts if address has deployed bytecode |
| `lengthMatch(uint256 actual, uint256 expected)` | `void` | Reverts if array lengths mismatch |

All numeric and address guards are chainable:

```solidity
uint256 result = amount.notZero().withinBounds(1, 100).equal(75);
```

---

### RevertLens

An abstract contract providing `revertIf()` — a structured revert helper that emits a `RevertContext` event before reverting, so off-chain indexers and monitoring tools can decode failure context even from mainnet transactions.

```solidity
import { RevertLens } from "solb/contracts/revert/RevertLens.sol";

contract MyVault is RevertLens {
    error InsufficientBalance(uint256 requested, uint256 available);

    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external {
        revertIf(
            amount > balances[msg.sender],
            InsufficientBalance.selector,
            abi.encode(amount, balances[msg.sender])
        );

        balances[msg.sender] -= amount;
        // ... transfer logic
    }
}
```

The revert data produced is identical to `abi.encodeWithSelector(InsufficientBalance.selector, amount, balances[msg.sender])` — fully compatible with `vm.expectRevert` and standard error decoding tools, while also emitting `RevertContext(bytes4 errorCode, address caller, bytes context)` for indexing.

---

### IntentBase

An abstract base contract for intent-based execution systems (bridges, DEX aggregators, cross-chain swaps). Handles the full lifecycle so protocols don't reimplement the same state machine.

```
OPEN ──────► FILLED
  │
  ├────────► CANCELLED   (by creator)
  │
  └────────► EXPIRED     (deadline passed)
```

```solidity
import { IntentBase } from "solb/contracts/intent/IntentBase.sol";
import { IntentTypes } from "solb/contracts/intent/IntentTypes.sol";

contract MyBridgeProtocol is IntentBase {

    function createBridgeIntent(
        address recipient,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) external returns (bytes32 intentId) {
        IntentTypes.IntentParams memory params = IntentTypes.IntentParams({
            creator: msg.sender,
            filler: address(0),   // open to anyone
            deadline: deadline,
            nonce: nonce,
            data: abi.encode(recipient, amount)
        });

        intentId = _registerIntent(params);
    }

    function fillBridgeIntent(bytes32 intentId) external {
        _fillIntent(intentId);
        // ... bridge execution logic
    }

    function cancelBridgeIntent(bytes32 intentId) external {
        _cancelIntent(intentId);
        // ... refund logic
    }
}
```

**Provided functions:**

| Function | Visibility | Description |
|---|---|---|
| `_registerIntent(IntentParams)` | `internal` | Creates a new intent in `OPEN` status, enforces unique nonce and future deadline |
| `_fillIntent(bytes32)` | `internal` | Marks an intent `FILLED`, reverts if not open or expired |
| `_cancelIntent(bytes32)` | `internal` | Marks `CANCELLED` (by creator) or `EXPIRED` (past deadline) |
| `getIntent(bytes32)` | `external view` | Returns the full `Intent` struct |
| `isNonceUsed(address, uint256)` | `external view` | Checks if a creator's nonce has been consumed |

---

## Development

```bash
git clone https://github.com/0xmrxp/solb
cd solb

forge install
forge build --sizes
forge test -vvv
forge fmt --check
```

### Project Structure

```
solb/
├── contracts/
│   ├── guards/        Guards.sol, IGuards.sol
│   ├── revert/         RevertLens.sol, IRevertLens.sol
│   ├── intent/          IntentBase.sol, IntentTypes.sol, IIntentBase.sol
│   └── index.sol
├── test/
│   ├── guards/
│   ├── revert/
│   └── intent/
├── script/
│   └── Deploy.s.sol
└── .github/workflows/ci.yml
```

---

## Roadmap

| Version | Module | Status |
|---|---|---|
| v1.0 | `Guards` | ✅ Shipped |
| v1.0 | `RevertLens` | ✅ Shipped |
| v1.0 | `IntentBase` | ✅ Shipped |
| v1.1 | `RateLimiter` | Planned |
| v1.1 | `CircuitBreaker` | Planned |
| v2.0 | `CapabilityEnforcer` | Future |
| v2.0 | `SafeUpgrade` | Future |

---

## Security

`solb` modules are designed to be minimal, explicit, and easy to audit — but they have **not** undergone a formal third-party security audit. Use at your own risk and review the source before deploying to production.

If you discover a security issue, please open a private security advisory on GitHub rather than a public issue.

---

## License

[MIT](./LICENSE)