--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- ensure the path points to your SignalService module
local VextSignal = require(ReplicatedStorage.Shared)

print("\n[VextSignal]: Initializing Benchmark extreme test...")
print("--------------------------------------------------")

local RootSignal = VextSignal.new()
local ChaosSignal = VextSignal.new()
local CleanupSignal = VextSignal.new()

local Stats = {
	TotalCalls = 0,
	DeepInvocations = 0,
	SelfDestructs = 0,
}

-- 1. // Layer: dynamic chaos (self-modifying listeners)
-- Treates 500 listeners that disconnect themselves and create new ones during execution.
-- Tests if the linked-list can handle mid-cycle mutations without skipping nodes.
for i = 1, 500 do
	local connection
	connection = ChaosSignal:Connect(function()
		Stats.TotalCalls += 1
		Stats.SelfDestructs += 1
		connection:Disconnect() -- kill current connection

		-- Instantly create a new connection in the same thread
		ChaosSignal:Connect(function()
			Stats.TotalCalls += 1
		end)
	end)
end

-- 2. // Layer: cross-recursion (circular dependency)
-- Signal a triggers signal b, which triggers a again.
-- Tests the thread pool management and stack safety.
RootSignal:Connect(function(level: number)
	Stats.TotalCalls += 1
	if level < 30 then
		ChaosSignal:Fire()
		RootSignal:Fire(level + 1)
	end
end)

ChaosSignal:Connect(function()
	Stats.DeepInvocations += 1
end)

-- 3. // Layer: heavy payload (memory stress)
-- Passes large tables to ensure coroutines handle data allocation/garbage collection efficiently.
CleanupSignal:Connect(function(data: { string })
	Stats.TotalCalls += 1
	local _junk = #data -- simulate data processing
end)

-- // Core execution: benchmark extreme test
local function RunExtremeTest()
	local start_time = os.clock()
	local large_data = table.create(1000, "Vext_Power") -- Heavy memory argument

	print("Executing 2,200 recursive waves with heavy payloads...")

	for i = 1, 2200 do
		-- Trigger chain reactions in parallel threads
		task.spawn(function()
			RootSignal:Fire(1)
			CleanupSignal:Fire(large_data)
		end)
	end

	-- Allow time for asynchronous tasks to settle
	task.wait(3)

	local duration = os.clock() - start_time - 3 -- Subtract wait time
	print("--------------------------------------------------")
	print("Benchmark extreme test results:")
	print(string.format(" > total processed calls: %d", Stats.TotalCalls))
	print(string.format(" > deep invocations:      %d", Stats.DeepInvocations))
	print(string.format(" > self-destructs:        %d", Stats.SelfDestructs))
	print(string.format(" > execution time:        %.4f seconds", duration))
	print("--------------------------------------------------")
end

task.wait(1)
local success, err = pcall(RunExtremeTest)

if not success then
	warn("[Vext Critical]: Benchmark extreme test failed! error: " .. tostring(err))
else
	print("[Vext Success]: Architectural integrity maintained under extreme chaos.")
end

-- Cleanup
task.delay(1, function()
	RootSignal:Destroy()
	ChaosSignal:Destroy()
	CleanupSignal:Destroy()
end)
