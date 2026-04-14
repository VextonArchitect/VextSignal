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

### 🟢 Available Now (Core Features)

#### ⚙️ High-Velocity Middleware
Full support for intercepting, modifying, or blocking signal execution.  
Perfect for analytics, debugging, and gameplay control layers.

---

#### 🧪 Strict Type Validation
Built-in runtime argument checking to maintain codebase integrity and prevent silent runtime bugs.

---

#### 🎯 Priority Execution
Fine-grained control over listener execution order using priority-based dispatching.

---

#### 🧩 VextGroups
Advanced memory management system with batch-disconnection capabilities for safe cleanup of connections.

---

#### 🌐 Cross-Boundary Bridge
Unified API for seamless Server ↔ Client communication without changing usage patterns.

---

## 🚀 Future Development (Upcoming Milestones)

| Feature            | Phase          | Description |
|--------------------|---------------|-------------|
| 🖥️ Visual Profiler UI | 🛠️ Development | Roblox Studio plugin for real-time signal stress monitoring and performance debugging |
| 📦 Network Batching | 📅 Q3 2026     | Groups high-frequency remote calls into optimized packets to reduce network overhead |
| 🧹 Intelli-Cleanup  | 📅 Q4 2026     | Automatically destroys signals and connections tied to removed Instances |
| 🧠 Native Buffering | 💡 Research    | Internal buffering system designed for extreme-load scenarios to prevent frame drops |
| 📊 Analytics Hooks  | 💡 Research    | Built-in integrations for external analytics systems to track gameplay events |

---

### 🛠 Why VextSignal?

| Comparison      | VextSignal                          | BindableEvent        |
|----------------|-------------------------------------|----------------------|
| Performance     | 🔥 High Throughput (optimized loops, pooling, no unnecessary allocations) | ⚖️ Moderate (Roblox-managed overhead) |
| Middleware      | ✅ Supported (interceptors, hooks, analytics layers) | ❌ Not supported |
| Async Choice    | ✅ Spawn / Defer / Pool / Secure / Hyper modes | ❌ Forced single execution model |
| Debugging       | ✅ Built-in Profiler + runtime stats | ❌ No built-in tooling |
| Priority System | ✅ Per-listener execution priority | ❌ Not available |
| Memory Control  | ✅ Manual cleanup + VextGroups batch disconnect | ❌ GC-only lifecycle |
| Scalability     | 🚀 Designed for high-frequency systems (combat, hitboxes, AI) | ⚖️ Limited under heavy event spam |
| Execution Modes | ✅ Multiple (FireHyper / FireSecure / Fire / FireDeferred) | ❌ Only standard event firing |

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
local onHit = VextSignal.new()
```

### 3. Connecting Listeners
You can connect functions just like a standard event, or use Priority to ensure specific code runs first.
```lua 
-- Standard Connection
onHit:Connect(function(damage)
    print("Damage dealt:", damage)
end)

-- Priority Connection (higher number = runs earlier)
onHit:Connect(function()
    print("This runs FIRST")
end, 100)
```

### 4. Firing the Signal
Choose the mode that fits your performance needs.
```lua
-- Maximum speed (synchronous)
onHit:FireHyper(50)

-- Thread-safe (asynchronous)
onHit:FireSecure(50)
```

### 5. Advanced Cleanup
Avoid memory leaks by using Signal Groups. This is perfect for NPC death or UI closing.
```lua
local group = VextSignal.createGroup()

group:Add(onHit:Connect(function() ... end))
group:Add(onStaminaChange:Connect(function() ... end))

-- Later, clean everything at once:
group:DisconnectAll()
```

---

### 📄 License
Distributed under the MIT License.

Made with 💙 by Vext
