--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared.Systems.VextSignal.Src.SignalService) -- path to signal module

print("\n[VextSignal]: Starting EXTREME STRESS TEST...")
print("--------------------------------------------------")

local RootSignal = VextSignal.new()
local ChaosSignal = VextSignal.new()
local CleanupSignal = VextSignal.new()

-- stats used to validate execution and measure load
local Stats = {
	TotalCalls = 0,
	DeepInvocations = 0,
	SelfDestructs = 0,
}

-- layer 1: dynamic mutation
-- listeners disconnect themselves and create new ones during execution
-- tests list stability under modification
for i = 1, 500 do
	local connection
	connection = ChaosSignal:Connect(function()
		Stats.TotalCalls += 1
		Stats.SelfDestructs += 1

		connection:Disconnect()

		-- create a new listener immediately
		ChaosSignal:Connect(function()
			Stats.TotalCalls += 1
		end)
	end)
end

-- layer 2: recursive calls
-- signals trigger each other to simulate deep call chains
RootSignal:Connect(function(level: number)
	Stats.TotalCalls += 1

	if level < 30 then
		ChaosSignal:FireSecure()
		RootSignal:FireSecure(level + 1)
	end
end)

ChaosSignal:Connect(function()
	Stats.DeepInvocations += 1
end)

-- layer 3: heavy payload
-- passes large tables to test memory pressure
CleanupSignal:Connect(function(data: { string })
	Stats.TotalCalls += 1
	local _ = #data
end)

-- main stress test
local function RunExtremeTest()
	local start_time = os.clock()

	-- large data payload
	local large_data = table.create(1000, "Vext_Power")

	-- number of parallel waves
	local waves = 1800

	print(string.format("running %d stress waves...", waves))

	for i = 1, waves do
		task.spawn(function()
			RootSignal:FireSecure(1)
			CleanupSignal:FireSecure(large_data)
		end)
	end

	-- wait until activity stabilizes
	local last_count = -1
	while Stats.TotalCalls > last_count do
		last_count = Stats.TotalCalls
		task.wait(0.5)
	end

	local duration = os.clock() - start_time - 0.5
	local throughput = math.floor(Stats.TotalCalls / duration)

	print("--------------------------------------------------")
	print("extreme test results:")
	print(string.format(" > total calls:     %d", Stats.TotalCalls))
	print(string.format(" > deep calls:      %d", Stats.DeepInvocations))
	print(string.format(" > self destructs:  %d", Stats.SelfDestructs))
	print(string.format(" > execution time:  %.4f sec", duration))
	print(string.format(" > throughput:      %d ops/sec", throughput))
	print("--------------------------------------------------")
end

task.wait(1)

local success, err = pcall(RunExtremeTest)

if not success then
	warn("[Vext Critical]: test failed: " .. tostring(err))
end

-- cleanup after test
task.delay(1, function()
	RootSignal:Destroy()
	ChaosSignal:Destroy()
	CleanupSignal:Destroy()

	print("[Vext]: memory cleared")
end)
