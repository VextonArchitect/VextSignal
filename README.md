# ⚡ VextSignal > High-performance, extensible signal system for Roblox --- ## 🚀 Overview **VextSignal** is a modern replacement for traditional event systems like BindableEvent. It is designed for **high-frequency gameplay systems** such as combat, hitboxes, AI, and networking. Built with performance, flexibility, and scalability in mind. --- ## ✨ Features ### 📊 Built-in Debug Profiler A developer-only profiling system designed to monitor signal performance. * Tracks how often each signal is fired * Measures average execution time of listeners * Detects heavy handlers that may cause frame drops > Perfect for optimizing combat systems and real-time events. --- ### 🛡️ Argument Validation Layer Optional runtime validation for safer development. * Ensures correct argument types when firing signals * Throws clear errors on misuse * Helps catch bugs in non-strict environments --- ### 🌐 Native Bridge (Cross-Boundary Signals) Seamless server ↔ client communication.
lua
Signal:FireClient(player, ...)
Signal:FireAllClients(...)
* Wraps RemoteEvent automatically * Keeps a consistent API across boundaries --- ### ⏳ Promise Integration Modern async workflows with Promise support.
lua
Signal:WaitPromise():andThen(function(...)
	print(...)
end)
* Converts signals into Promises * Clean async chaining --- ### 🛠️ Signal Groups (Batch Disconnect) Efficient cleanup system.
lua
Group:DisconnectAll()
* Group multiple signals or connections * Clean everything in one call * Prevent memory leaks --- ### 🔄 Middleware Support Intercept and extend signal behavior.
lua
Signal:Use(function(next, ...)
	print("Signal fired")
	return next(...)
end)
* Add logging, analytics, validation * Modify or block execution * Fully composable --- ## 📦 Installation ### Option 1 — Manual 1. Download the module 2. Place it inside ReplicatedStorage 3. Require it:
lua
local Signal = require(ReplicatedStorage.Signal)
--- ### Option 2 — Rojo / Wally (optional) *(Add your package manager instructions here if needed)* --- ## 🧠 Basic Usage ### Create a Signal
lua
local signal = Signal.new()
### Connect
lua
signal:Connect(function(value)
	print("Received:", value)
end)
### Fire
lua
signal:Fire("Hello World")
--- ## ⚡ Advanced Usage ### Once
lua
signal:Once(function()
	print("Fired once")
end)
--- ### Wait
lua
local value = signal:Wait()
print(value)
--- ### Priority
lua
signal:Connect(function()
	print("High priority")
end, 10)
--- ### Async Fire
lua
signal:FireSpawn(...)
signal:FireDeferred(...)
--- ## 🧩 Example (Hitbox System)
lua
local hitbox = HitboxManager.new(character, settings)

hitbox.OnHit:Connect(function(victim)
	local hum = victim:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:TakeDamage(10)
	end
end)
--- ## ⚙️ Performance VextSignal is optimized for: * ⚡ High-frequency events (combat, hitboxes) * 🧵 Coroutine pooling * 🧠 Minimal allocations * 📉 Reduced overhead vs BindableEvent --- ## 📚 Comparison | Feature | VextSignal | BindableEvent | | --------------- | ---------- | ------------- | | Performance | ⚡ High | ⚖️ Medium | | Priority | ✅ | ❌ | | Middleware | ✅ | ❌ | | Promise Support | ✅ | ❌ | | Debug Tools | ✅ | ❌ | | Extensibility | 🔥 Full | ❌ | --- ## 🛡️ Safety * Error isolation via pcall * Optional argument validation * Safe disconnect handling * No memory leaks when used correctly --- ## 📌 Roadmap * [ ] Full profiler UI * [ ] Network replication layer * [ ] Event batching system * [ ] Built-in analytics hooks --- ## 🤝 Contributing Contributions are welcome! * Open an issue * Submit a pull request * Suggest improvements --- ## 📄 License MIT License --- ## 💬 Final Notes VextSignal is built for developers who want **full control over their event systems**. If you're building: * ⚔️ Combat systems * 🧠 AI systems * 🌐 Networked gameplay Then this library is for you. --- **Made with 💙 by Vext**
