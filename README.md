# ⚡ VextSignal

![Luau](https://img.shields.io/badge/Luau-Strict-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Roblox-white?style=flat-square)

> **VextSignal** is a high-performance, strictly-typed Signal implementation for Luau, designed for systems where performance, scalability, and determinism matter.

---

## 🚀 Overview

Roblox's built-in **BindableEvents** are convenient — but expensive.

**VextSignal** is built from the ground up to eliminate unnecessary overhead by using:

* ⚡ Custom thread pooling
* 🧠 Direct reference passing (no deep copies)
* 📉 Minimal memory allocations

> Result: predictable performance even under heavy load.

---

## 🎯 Use Cases

VextSignal is ideal for:

* ⚔️ Combat / Hitbox systems
* 🔄 High-frequency game loops
* 🌐 Networked state synchronization
* 🎮 Core gameplay systems

---

## 💎 Key Features

### 🛡️ Strict Typing (Luau)

Full support for variadic generics (`T...`):

```lua
local Signal = require(path.to.VextSignal)

local OnDamage = Signal.new<Player, number>()
```

* ✔ Autocomplete support
* ✔ Compile-time validation
* ✔ Safer APIs

---

### ⚖️ Priority-Based Execution

Control execution order precisely:

```lua
signal:Connect(callback, priority)
```

Higher priority callbacks execute first.

---

### 🧵 Thread Pooling

Instead of spawning new threads:

* 🔁 Reuses idle threads
* 📉 Reduces CPU spikes
* 🚀 Improves consistency

---

### ⚡ O(1) Disconnect

Built on a **doubly-linked list**:

* Instant disconnection
* No array shifting
* Scales efficiently

---

### 🧹 Memory Safety

* Explicit `Destroy()` lifecycle
* No hidden references
* Predictable cleanup

---

## 📖 Quick Start

```lua
local Signal = require(path.to.VextSignal)

-- Create a signal
local OnCombatAction = Signal.new<Player, string, number>()

-- Connect listener
OnCombatAction:Connect(function(player, actionType, damage)
    print(`{player.Name} used {actionType} dealing {damage} damage`)
end, 100)

-- Fire signal
OnCombatAction:Fire(LocalPlayer, "Slash", 45)
```

---

## 🚦 Fire Modes

| Mode             | Description                        | Internal Behavior |
| ---------------- | ---------------------------------- | ----------------- |
| **Fire**         | Fastest, default execution         | Thread pool       |
| **FireSpawn**    | Safe, isolated execution           | `task.spawn`      |
| **FireDeferred** | Deferred execution (UI / batching) | `task.defer`      |

---

## 🛠 Implementation Details

| System         | Description                                |
| -------------- | ------------------------------------------ |
| Linked List    | Efficient connection management            |
| Variadic Packs | Optimized argument handling                |
| Thread Pool    | Reuses execution threads                   |
| Cleanup System | Ensures full garbage collection on destroy |

---

## 📊 Performance Philosophy

> **"Do not allocate what you can reuse."**

VextSignal minimizes:

* Thread creation
* Table allocations
* Garbage collection pressure

---

## 📦 Installation

### Manual

Place the module inside `ReplicatedStorage` or your shared library folder.

### Wally *(optional)*

```toml
VextSignal = "yourname/vextsignal@latest"
```

---

## 🧪 Advanced Example

```lua
local signal = Signal.new<number>()

-- High priority logic
signal:Connect(function(value)
    print("Core logic:", value)
end, 100)

-- Low priority UI
signal:Connect(function(value)
    print("UI update:", value)
end, 0)

signal:Fire(10)
```

---

## 📄 License

MIT License © 2026

> Use it. Break it. Improve it.
