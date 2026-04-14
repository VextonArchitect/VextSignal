--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- ensure correct module path for signal system
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

-- layer 1: dynamic chaos (self-modifying listeners)
-- 500 listeners that disconnect and recreate themselves during execution
-- tests list stability under mutation while iterating
for i = 1, 500 do
	local connection
	connection = ChaosSignal:Connect(function()
		Stats.TotalCalls += 1
		Stats.SelfDestructs += 1

		-- remove current listener during execution
		connection:Disconnect()

		-- immediately spawn replacement listener
		ChaosSignal:Connect(function()
			Stats.TotalCalls += 1
		end)
	end)
end

-- layer 2: circular recursion (cross-signal dependency)
-- root triggers chaos, chaos triggers root again
-- tests recursion safety + thread handling
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

-- layer 3: heavy payload stress
-- large tables passed through signal pipeline to stress memory + GC
CleanupSignal:Connect(function(data: { string })
	Stats.TotalCalls += 1

	-- simulate real workload on received payload
	local _junk = #data
end)

-- core benchmark execution
local function RunExtremeTest()
	local start_time = os.clock()
	local large_data = table.create(1000, "Vext_Power")

	print("Executing 2,200 recursive waves with heavy payloads...")

	for i = 1, 2200 do
		-- spawn parallel execution waves
		task.spawn(function()
			RootSignal:Fire(1)
			CleanupSignal:Fire(large_data)
		end)
	end

	-- allow async operations to finish
	task.wait(3)

	local duration = os.clock() - start_time - 3

	print("--------------------------------------------------")
	print("Benchmark extreme test results:")
	print(string.format(" > total processed calls: %d", Stats.TotalCalls))
	print(string.format(" > deep invocations:      %d", Stats.DeepInvocations))
	print(string.format(" > self-destructs:        %d", Stats.SelfDestructs))
	print(string.format(" > execution time:        %.4f seconds", duration))
	print("--------------------------------------------------")
end

-- small warmup delay before heavy execution
task.wait(1)

local success, err = pcall(RunExtremeTest)

if not success then
	warn("[Vext Critical]: Benchmark extreme test failed! error: " .. tostring(err))
else
	print("[Vext Success]: Architectural integrity maintained under extreme chaos.")
end

-- cleanup phase
task.delay(1, function()
	RootSignal:Destroy()
	ChaosSignal:Destroy()
	CleanupSignal:Destroy()
end)
