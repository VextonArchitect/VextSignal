# VextSignal ⚡

> **VextSignal** is a high-performance, strictly typed signal implementation for Luau. While most libraries focus on simplicity, VextSignal is engineered for high-frequency systems where every microsecond and byte of memory matters.

---

## 🚀 Why VextSignal?
Standard Roblox **BindableEvents** are heavy. They serialize arguments, overhead the Task Scheduler, and offer zero type safety. 

VextSignal eliminates this by using a **custom thread pool** and direct reference passing, keeping your frame times consistent even under extreme load. It's built specifically for:
* ⚔️ **Hitbox Systems**
* 🔄 **Custom Game Loops**
* 🌐 **Networked State Management**

---

## 💎 Core Pillars

### 🛡️ Strict Luau Typing
Full support for generic variadic types `T...`. Get autocomplete and linting errors in VS Code or Studio before you even hit "Play."

### ⚖️ Priority-Based Execution
Not all listeners are equal. Use the `priority` parameter to ensure your data logic runs **before** your UI or VFX updates.

### 🧵 Thread Re-use (Pooling)
Instead of spamming `task.spawn` and stressing the scheduler, VextSignal reuses "sleeping" threads. This significantly cuts down on CPU spikes.

### ⚡ O(1) Disconnects
Built on a doubly-linked list. Disconnecting a listener is an instant operation, regardless of whether you have 10 or 10,000 active connections.

---

## 📦 Installation

### Rojo
Add this to your `default.project.json`:

```json
"VextSignal": {
  "$path": "path/to/VextSignal"
},

📖 Quick Start

local Signal = require(path.to.VextSignal)

-- Define a signal with specific types for maximum safety
local OnCombatAction = Signal.new<Player, string, number>()

-- Connect with high priority (runs first)
OnCombatAction:Connect(function(player, actionType, damage)
    print(`Log: {player.Name} performed {actionType}`)
end, 100)

-- Standard connection
OnCombatAction:Connect(function(player, actionType, damage)
    -- Trigger VFX or UI update
end)

OnCombatAction:Fire(LocalPlayer, "Slash", 45)

🚦 Choosing the Right Fire Mode

Method,                        Use Case,                             Internal Behavior
Fire,                          Default,Fastest.                      Uses the internal thread pool for immediate execution.
FireSpawn,                     Isolation,Uses task.spawn.            Best if you need to ensure an error in one listener doesn't catch others.
FireDeferred,                  Optimization,Uses task.defer.         Perfect for non-critical UI to keep the main thread lean.


Technical Details
Linked List: Avoids the table.remove performance trap.

Variadic Packs: Optimized handling of table.pack/unpack to prevent memory thrashing.

Cleanup: Destroy() handles full garbage collection of all nodes and metadata.

📄 License
Licensed under the MIT License. Use it, break it, improve it.
