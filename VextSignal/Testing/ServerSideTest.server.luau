--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Systems.VextSignal.Src.SignalService)

local signal = Signal.new()

print("--- Basic functional test ---")
-- basic connection test
signal:Connect(function(message)
	print("listener 1 received:", message)
end)
signal:Fire("hello world")

print("\n--- Priority execution test ---")
-- checks execution order based on priority (higher first)
signal:Connect(function()
	print("priority 0 (standard)")
end, 0)

signal:Connect(function()
	print("priority 10 (high)")
end, 10)

signal:Connect(function()
	print("priority -5 (low)")
end, -5)

signal:Fire()

print("\n--- Single execution test (once) ---")
-- should run only once and auto-disconnect
signal:Once(function()
	print("this should only print once")
end)

signal:Fire()
signal:Fire() -- should not trigger again

print("\n--- Connection disconnection test ---")
-- verify manual disconnect works correctly
local connection = signal:Connect(function()
	print("error: this should have been disconnected")
end)

connection:Disconnect()
signal:Fire()

print("\n--- Disconnect all test ---")
-- ensure all listeners are removed
signal:Connect(function()
	print("error: listener a survived disconnectall")
end)

signal:Connect(function()
	print("error: listener b survived disconnectall")
end)

signal:DisconnectAll()
signal:Fire()

print("\n--- Yielding wait test ---")
-- test async waiting for signal result
task.spawn(function()
	print("waiting for signal...")
	local val1, val2 = signal:Wait()
	print("wait resolved with data:", val1, val2)
end)

task.wait(0.5)
signal:Fire("data_alpha", "data_beta")

print("\n--- Fire modes comparison ---")
-- test different execution modes
signal:Connect(function()
	print("handler triggered")
end)

print("triggering sync fire (immediate):")
signal:Fire()

print("triggering firespawn (new thread):")
signal:Fire()

print("triggering firedeferred (next cycle):")
signal:FireDeferred()

print("\n--- Mass iteration test (1,000 fires) ---")
-- performance and stability under repeated calls
local callCount = 0
local massSignal = Signal.new()

massSignal:Connect(function()
	callCount += 1
end)

for i = 1, 1000 do
	massSignal:Fire()
end

print("total successful calls recorded:", callCount)

print("\n--- Mid-fire disconnection stress test ---")
-- connection removes itself during execution
local selfDestructConn
selfDestructConn = signal:Connect(function()
	print("connection is disconnecting itself now...")
	selfDestructConn:Disconnect()
end)

signal:Fire() -- first trigger + self disconnect
signal:Fire() -- should not trigger again

print("\n--- All tests completed successfully ---")
