# ⚡ VextSignal

> High-performance, extensible signal system for Roblox (Luau)

---

## 🚀 Overview

VextSignal is a high-performance replacement for Roblox BindableEvents and traditional signal systems.

It is designed for:
- ⚔️ Combat systems
- 🧠 AI systems
- 🎯 Hitboxes
- 🌐 Networking-heavy games

Built with:
- Linked-list architecture
- Coroutine pooling
- Minimal allocations
- Multiple execution modes

---

## 🏆 Execution Modes

| Mode | Execution Model | Speed | Safety | Latency | Description |
|------|----------------|------|--------|---------|-------------|
| FireHyper | direct pcall | 🔥 extreme | ⚠️ medium | ⚡ ultra low | Fastest execution, no scheduler |
| FireSecure | coroutine pool | 🚀 very high | 🛡️ high | ⚡ low | Reusable threads, stable under load |
| Fire | task.spawn | ⚖️ medium | 🛡️ high | ⏳ medium | Default Roblox async execution |
| FireDeferred | task.defer | ⚖️ medium | 🛡️ high | ⏳ delayed | Runs on next frame |

---

## 📊 Benchmark Results

### 🔥 Extreme Stress Test

| Metric | Result |
|--------|--------|
| Total Calls | 90,092,700 |
| Execution Time | 9.97s |
| Throughput | ~9.03M ops/sec |
| Deep Invocations | 179,800 |
| Self Destructs | 500 |

---

### 🧪 Secondary Benchmark

| Metric | Result |
|--------|--------|
| Total Calls | 29,062,500 |
| Execution Time | 8.75s |
| Throughput | ~3.32M ops/sec |
| Deep Invocations | 58,000 |
| Self Destructs | 500 |

---

## 🧠 Interpretation

| Category | Winner | Reason |
|----------|--------|--------|
| Max Speed | FireHyper | No scheduler overhead |
| Stability | FireSecure | Thread pooling |
| Simplicity | Fire | Native Roblox model |
| Frame control | FireDeferred | avoids frame spikes |

---

## ⚡ Core Features

### 📊 Built-in Performance Design
- Tracks high-frequency signals
- Optimized for millions of calls/sec
- Designed for combat-heavy systems

---

### 🧵 Coroutine Pool System
- Reuses threads instead of spawning new ones
- Reduces GC pressure
- Improves stability under load

---

### 🛡️ Safe Execution Layer
- Uses pcall isolation
- Prevents one listener crash affecting others
- Debug-friendly error logging

---

### 🔄 Priority System
```lua
signal:Connect(function()
	print("high priority")
end, 10)

Listeners execute by priority order (highest first).

---

### ⏳ Execution Variants
```lua
signal:Fire()         -- async spawn
signal:FireSecure()   -- coroutine pool
signal:FireHyper()    -- direct execution
signal:FireDeferred()``` -- next fram

--- 
### 🎯 Once Listener
signal:Once(function()
	print("runs only once")
end)
