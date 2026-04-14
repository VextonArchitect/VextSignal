# ⚡ VextSignal

> **High-performance, extensible signal system for Roblox (Luau)** > Engineered for high-frequency gameplay systems: Combat, Hitboxes, AI, and Networking.

---

## 🚀 Overview

**VextSignal** is a robust, lightweight replacement for `BindableEvents`. While standard events often struggle under extreme load, VextSignal remains stable, offering specialized firing modes and developer tools to keep your game running at 60 FPS.

---

## 🏆 Performance Benchmarks

VextSignal is optimized to the theoretical limits of the Luau VM.

### Execution Models
| Mode | Strategy | Latency | Safety | Ideal Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **FireHyper** | Direct `pcall` | ⚡ **Ultra Low** | ⚠️ Medium | Combat core, Hitboxes, tight loops |
| **FireSecure** | Coroutine Pool | ⚡ Low | 🛡️ High | Stress logic, heavy recursion |
| **Fire** | `task.spawn` | ⏳ Medium | 🛡️ High | General UI, Standard events |
| **FireDeferred**| `task.defer` | ⏳ Next Frame | 🛡️ High | Cleanup, Batching, Frame-end logic |

### Stress Test Metrics
* **Peak Throughput:** ~9,000,000 ops/sec.
* **Avg execution time:** 0.39 µs.
* **Stability:** 100% execution rate under self-destructive listener chains.

---

## ✨ Features & Roadmap

| Feature | Status | Description |
| :--- | :--- | :--- |
| **Middleware API** | ✅ Live | Intercept, modify, or block signals (Analytics/Logging). |
| **Argument Validation** | ✅ Live | Runtime type-checking for safer development. |
| **Priority Connections**| ✅ Live | Ensure critical listeners fire before others. |
| **Signal Groups** | ✅ Live | Batch disconnect multiple connections to prevent leaks. |
| **Network Bridge** | ✅ Live | Unified API for Server-to-Client communication. |
| **Profiler UI** | 🛠️ In Dev | A dedicated plugin to visualize signal stress in real-time. |
| **Event Batching** | 📅 Planned | Groups high-frequency remote data into single packets. |
| **Auto-Cleanup** | 📅 Planned | Automatic destruction of signals when instances are removed. |

---

## 📖 Getting Started: A Step-by-Step Guide

### 1. Installation
* **Manual:** Drop the `VextSignal` module into `ReplicatedStorage`.
* **Rojo:** Add the `.lua` file to your `src` directory.

### 2. Basic Setup
To use VextSignal, simply require the module and create a new instance.
```lua
local VextSignal = require(game:GetService("ReplicatedStorage").VextSignal)

-- Create the signal
local onHit = VextSignal.new()```

### 3. Connecting Listeners
You can connect functions just like a standard event, or use Priority to ensure specific code runs first.
```lua 
-- Standard Connection
onHit:Connect(function(damage)
    print("Damage dealt:", damage)
end)```

-- Priority Connection (higher number = runs earlier)
onHit:Connect(function()
    print("This runs FIRST")
end, 100)```

### 4. Firing the Signal
Choose the mode that fits your performance needs.
```lua
-- Maximum speed (synchronous)
onHit:FireHyper(50)

-- Thread-safe (asynchronous)
onHit:FireSecure(50)```

### 5. Advanced Cleanup
Avoid memory leaks by using Signal Groups. This is perfect for NPC death or UI closing.
```lua
local group = VextSignal.createGroup()

group:Add(onHit:Connect(function() ... end))
group:Add(onStaminaChange:Connect(function() ... end))

-- Later, clean everything at once:
group:DisconnectAll()```

---

### 🛠 Why VextSignal?

| Comparison     | VextSignal                 | BindableEvent        |
|----------------|---------------------------|----------------------|
| Performance    | 🔥 High Throughput        | ⚖️ Moderate          |
| Middleware     | ✅ Supported              | ❌ No                |
| Async Choice   | ✅ Spawn / Defer / Pool   | ❌ Forced            |
| Debugging      | ✅ Built-in Profiler      | ❌ No                |

---

### 📄 License
Distributed under the MIT License.

Made with 💙 by Vext
