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

-- Create a new signal (supports Luau generics for type safety)
local mySignal = Signal.new<string, number>()

-- Connect a listener
local connection = mySignal:Connect(function(name, score)
    print(string.format("Player %s scored %d points!", name, score))
end)

-- Fire the signal
mySignal:Fire("Vexton", 1500)

-- Disconnect when no longer needed
connection:Disconnect()
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
local Signal = require(path.to.VextSignal)

-- Defining a complex signal for a Combat System
local OnHit = Signal.new<Model, number, boolean>() -- Target, Damage, IsCritical

-- 1. High Priority: Logic that must run BEFORE damage (e.g., Shield/Invulnerability check)
OnHit:Connect(function(target, damage)
    print("Priority 100: Checking defensive buffs for", target.Name)
end, 100)

-- 2. Normal Priority: Visual effects and Sound
OnHit:Connect(function(_, _, isCrit)
    if isCrit then
        print("Priority 0: Playing Critical Hit sound effect!")
    end
end, 0)

-- 3. The 'Once' Pattern: Useful for achievement or first-blood logic
OnHit:Once(function()
    print("First Blood! Someone took damage for the first time.")
end)

-- 4. Using Wait() in a separate thread (e.g., for a cinematic or combo sequence)
task.spawn(function()
    print("Sequence: Waiting for the next hit...")
    local target, damage = OnHit:Wait()
    print("Sequence: Recorded a hit of " .. damage .. " on " .. target.Name)
end)

-- Simulated combat event
task.wait(1)
OnHit:Fire(workspace.EnemyDummy, 45, true)

-- Cleanup: Destroy the signal when the weapon/NPC is removed
-- This will automatically disconnect all remaining listeners.
-- OnHit:Destroy()
```

---

## 📄 License

MIT License © 2026

> Use it. Break it. Improve it.
