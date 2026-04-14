# VextSignal ⚡
![Luau](https://img.shields.io/badge/Luau-Strict-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Roblox-white?style=flat-square)

> **VextSignal** is a high-performance, strictly typed signal implementation for Luau. Engineered for high-frequency systems where every microsecond matters.

---

## 🚀 Why VextSignal?
Standard Roblox **BindableEvents** are heavy. VextSignal eliminates overhead by using a **custom thread pool** and direct reference passing.

* ⚔️ **Hitbox Systems**
* 🔄 **Custom Game Loops**
* 🌐 **Networked State Management**

---

## 💎 Core Pillars

### 🛡️ Strict Luau Typing
Full support for generic variadic types `T...`. Get autocomplete and linting errors before you even hit "Play."

### ⚖️ Priority-Based Execution
Use the `priority` parameter to ensure your data logic runs **before** your UI or VFX updates.

### 🧵 Thread Re-use (Pooling)
Reuses "sleeping" threads instead of spamming `task.spawn`, significantly cutting down on CPU spikes.

### ⚡ O(1) Disconnects
Built on a doubly-linked list. Disconnecting is an instant operation regardless of the number of connections.

---

## 📦 Installation

### Rojo
Add this to your `default.project.json`:

```json
"VextSignal": {
  "$path": "path/to/VextSignal"
}

##📖 Quick Start
local Signal = require(path.to.VextSignal)

-- Define a signal with specific types
local OnCombatAction = Signal.new<Player, string, number>()

-- Connect with high priority
OnCombatAction:Connect(function(player, actionType, damage)
    print(`Log: {player.Name} performed {actionType}`)
end, 100)

OnCombatAction:Fire(LocalPlayer, "Slash", 45)

##🚦 Choosing the Right Fire Mode

Method,                         Use Case,                           Internal Behavior
Fire,                           Default,Fastest.                    Uses the internal thread pool.
FireSpawn,                      Isolation,                          Uses task.spawn. Safety first.
FireDeferred,                   Optimization,                       Uses task.defer. Great for UI updates.

##🛠 Technical Details
Linked List: Avoids table.remove performance traps.

Variadic Packs: Optimized handling of table.pack/unpack.

Cleanup: Destroy() handles full garbage collection.

##📄 License
Licensed under the MIT License. Use it, break it, improve it
