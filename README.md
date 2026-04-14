# ⚡ VextSignal

A high-performance, extensible signal system for Roblox (Luau), designed for high-frequency gameplay systems such as combat, hitboxes, AI, and networking.

---

## 📌 Overview

| Category       | Description                      |
| -------------- | -------------------------------- |
| Project Type   | Signal / Event System            |
| Target Engine  | Roblox (Luau)                    |
| Primary Use    | Combat, Hitboxes, AI, Networking |
| Alternative To | BindableEvent                    |
| Design Focus   | Performance + Control            |

---

## 🏷️ Project Status

| Metric   | Value              |
| -------- | ------------------ |
| Status   | Active Development |
| License  | MIT                |
| Language | Luau               |
| Platform | Roblox             |

---

## ⚙️ Core Design Goals

| Goal            | Description                       |
| --------------- | --------------------------------- |
| Low Allocation  | Minimize GC pressure in hot paths |
| High Throughput | Handle extreme event spam         |
| Determinism     | Predictable execution order       |
| Flexibility     | Multiple execution models         |
| Debuggability   | Middleware + instrumentation      |

---

## 🚀 Execution Models

| Mode         | Strategy       | Latency    | Safety | Use Case           |
| ------------ | -------------- | ---------- | ------ | ------------------ |
| FireHyper    | Direct pcall   | Ultra Low  | Medium | Combat / Hitboxes  |
| FireSecure   | Coroutine pool | Low        | High   | Complex logic      |
| Fire         | task.spawn     | Medium     | High   | General events     |
| FireDeferred | task.defer     | Next frame | High   | Cleanup / batching |

---

## 🧠 Core Features

| Feature               | Description                          |
| --------------------- | ------------------------------------ |
| Middleware System     | Intercept / modify / block execution |
| Priority System       | Deterministic listener ordering      |
| Strict Typing         | Runtime argument validation          |
| VextGroups            | Batch connection management          |
| Cross-Boundary Bridge | Server ↔ Client unified API          |

---

## 📊 Benchmark Methodology

| Category    | Details                        |
| ----------- | ------------------------------ |
| Environment | Roblox Studio / Luau VM        |
| Test Setup  | Empty place, no rendering load |
| Load Type   | High-frequency signal spam     |
| Duration    | 10–30 seconds continuous run   |
| Scale       | 1M – 10M signal fires          |

---

## 📦 Installation

| Method | Steps                             |
| ------ | --------------------------------- |
| Manual | Place module in ReplicatedStorage |
| Rojo   | Add module to src directory       |

---

## 🧩 Basic Usage

| Step    | Code                                                       |
| ------- | ---------------------------------------------------------- |
| Require | `local VextSignal = require(ReplicatedStorage.VextSignal)` |
| Create  | `local signal = VextSignal.new()`                          |

---

## 🔗 API Reference

| Function                | Description          |
| ----------------------- | -------------------- |
| `new()`                 | Creates a signal     |
| `Connect(fn, priority)` | Adds listener        |
| `Once(fn)`              | One-time listener    |
| `FireHyper(...)`        | Fast sync execution  |
| `FireSecure(...)`       | Safe async execution |
| `Fire(...)`             | Standard async       |
| `FireDeferred(...)`     | Next-frame execution |
| `Disconnect()`          | Removes connection   |
| `Destroy()`             | Cleans signal        |

---

## ⚡ Connection Example

| Type     | Code                                |
| -------- | ----------------------------------- |
| Normal   | `signal:Connect(function(...) end)` |
| Priority | `signal:Connect(fn, 100)`           |
| Once     | `signal:Once(fn)`                   |

---

## 🚀 Firing Signals

| Mode     | Code                       |
| -------- | -------------------------- |
| Hyper    | `signal:FireHyper(...)`    |
| Secure   | `signal:FireSecure(...)`   |
| Standard | `signal:Fire(...)`         |
| Deferred | `signal:FireDeferred(...)` |

---

## 🧠 Middleware

| Concept   | Example                                                |
| --------- | ------------------------------------------------------ |
| Intercept | `signal:Use(function(next, ...) return next(...) end)` |
| Modify    | Change arguments before passing forward                |
| Block     | Stop execution chain                                   |

---

## 🧹 Signal Groups

| Action  | Code                                     |
| ------- | ---------------------------------------- |
| Create  | `local group = VextSignal.createGroup()` |
| Add     | `group:Add(signal:Connect(fn))`          |
| Cleanup | `group:DisconnectAll()`                  |

---

## 🆚 Comparison

| Feature        | VextSignal      | BindableEvent |
| -------------- | --------------- | ------------- |
| Performance    | High            | Medium        |
| Middleware     | Yes             | No            |
| Priority       | Yes             | No            |
| Async Modes    | Multiple        | Single        |
| Debug Tools    | Yes             | No            |
| Memory Control | Manual + Groups | GC only       |

---

## 🛣️ Roadmap

| Feature            | Status         |
| ------------------ | -------------- |
| Visual Profiler UI | In Development |
| Network Batching   | Planned        |
| Auto Cleanup       | Planned        |
| Native Buffering   | Research       |
| Analytics Hooks    | Research       |

---

## 🥀 Comment

Made By Vext 💖

---

## 🧠 Summary

| Aspect   | Description                    |
| -------- | ------------------------------ |
| Purpose  | High-performance signal system |
| Strength | Control + speed + scalability  |
| Target   | High-frequency Roblox systems  |
