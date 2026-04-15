# ⚡VextSignal

A high-performance, extensible signal system for Roblox (Luau), built for high-frequency systems such as combat, hit detection, AI, UI, and networking.

---

## 📌 Overview

| Category       | Description                       |
| -------------- | --------------------------------- |
| Project Type   | Signal / Event System             |
| Engine         | Roblox (Luau)                     |
| Primary Use    | Combat, Hitboxes, AI, Networking  |
| Alternative To | BindableEvent                     |
| Focus          | Performance, determinism, control |

---

## 🏷️ Status

| Metric   | Value              |
| -------- | ------------------ |
| Status   | Active Development |
| License  | MIT                |
| Language | Luau               |
| Platform | Roblox             |

---
## 🛣️ Roadmap (Future Updates)

VextSignal continues to evolve with focus on performance, scalability, and tooling.

| Feature | Status | Description |
|----------|--------|-------------|
| **Signal Bridge** | ✅ Released | Centralized event system with namespaces |
| **Middleware System** | ⏳ Planned | Intercept and control event execution flow |
| **RemoteSignal Integration** | ⏳ Planned | High-performance client-server networking layer |
| **Payload Validation** | ⏳ Planned | Runtime validation for signal arguments |
| **Visual Profiler** | 🚧 In Progress | Studio tool for tracing and performance analysis |
## 💡 Summary
Focused on building a scalable, high-performance event ecosystem for Roblox systems.
---

## ⚙️ Design Goals

| Goal            | Description                                         |
| --------------- | --------------------------------------------------- |
| Low Overhead    | Minimal allocations in hot execution paths          |
| High Throughput | Handles high-frequency event dispatch efficiently   |
| Determinism     | Predictable execution order via priority system     |
| Flexibility     | Multiple execution strategies depending on use case |
| Control         | Explicit lifecycle and memory management            |

---

## 🚀 Execution Modes

| Mode           | Strategy       | Latency    | Notes                            |
| -------------- | -------------- | ---------- | -------------------------------- |
| `FireHyper`    | Direct `pcall` | Ultra Low  | Fastest, synchronous             |
| `FireSecure`   | Coroutine pool | Low        | Balanced performance & isolation |
| `Fire`         | `task.spawn`   | Medium     | General-purpose async            |
| `FireDeferred` | `task.defer`   | Next Frame | Useful for batching / cleanup    |

---

## 📊 Benchmark Notes

Benchmarks were conducted under controlled conditions:

| Category    | Details                        |
| ----------- | ------------------------------ |
| Environment | Roblox Studio (Luau VM)        |
| Scenario    | High-frequency signal dispatch |
| Duration    | 10–30 seconds continuous load  |
| Scale       | 1M – 10M signal fires          |

> Results may vary depending on workload and execution mode.

---

## 🆚 Comparison

| Feature        | VextSignal | BindableEvent |
| -------------- | ---------- | ------------- |
| Performance    | High       | Medium        |
| Determinism    | Yes        | No            |
| Priority       | Yes        | No            |
| Async Control  | Multiple   | Single        |
| Memory Control | Manual     | GC only       |

---

## 🧠 Core Features

* ⚡ Priority-based listener execution (deterministic order)
* 🔁 Multiple execution models (sync + async strategies)
* 🧵 Coroutine pooling to reduce allocation under load
* 🧹 Explicit memory control (manual disconnect & cleanup)
* 🎯 Minimal abstraction overhead (no Instances, no BindableEvents)

---

## 📦 Installation

### Manual

Place the module in `ReplicatedStorage`
### Rojo

Add the module to your `src` directory

---

## 🔗 API

### Creation

```lua
local signal = VextSignal.new()
```

---

### Connections

```lua
signal:Connect(fn, priority?) -- priority defaults to 0. Higher runs first.
signal:Once(fn, priority?)
```

---

### Firing

```lua
signal:FireHyper(...)
signal:FireSecure(...)
signal:Fire(...)
signal:FireDeferred(...)
```

---

### Lifecycle

```lua
connection:Disconnect()
signal:DisconnectAll()
signal:Destroy()
```

---

### Yielding

```lua
local result = signal:Wait()
```

---

## ⚡ Example

```lua
local signal = VextSignal.new()

signal:Connect(function()
	print("Low priority")
end, 0)

signal:Connect(function()
	print("High priority")
end, 100)

signal:FireHyper()
```

**Output:**

```
High priority
Low priority
```

---

## 🧠 Summary

**VextSignal** is designed for developers who need:

* precise control over execution
* predictable behavior under load
* and minimal overhead in performance-critical systems

It is especially suited for:

* combat systems
* hit detection
* real-time AI
* high-frequency event pipelines

---

## ⚠️ Notes

* `FireHyper` is synchronous and may block execution
* `FireSecure` introduces small overhead due to argument packing
* Performance characteristics depend on usage patterns
* Not a drop-in replacement for all BindableEvent use cases

---

## 🥀 Comment

Made By Vext 💖
