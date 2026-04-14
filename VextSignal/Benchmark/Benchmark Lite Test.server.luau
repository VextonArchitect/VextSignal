--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared)

print("\n[VextSignal]: Starting High-Load Performance Test...")
print("--------------------------------------------------")

-- signal used for stress testing
local TestSignal = VextSignal.new()

-- number of fire calls
local ITERATIONS = 21000000 -- 21 million iterations

-- simple counter to verify execution
local counter = 0

-- minimal listener to reduce overhead noise
TestSignal:Connect(function()
	counter += 1
end)

-- main benchmark function
local function RunBenchmark()
	print(string.format("Testing: Firing %d signals...", ITERATIONS))

	-- start timing
	local StartTime = os.clock()

	-- tight loop to measure raw throughput
	for i = 1, ITERATIONS do
		TestSignal:FireHyper()
	end

	-- end timing
	local EndTime = os.clock()

	local Duration = EndTime - StartTime
	local AvgLatency = Duration / ITERATIONS
	local Throughput = math.floor(1 / AvgLatency)

	print("--------------------------------------------------")
	print("Results:")
	print(string.format(" > Total Time:  %.6f seconds", Duration))
	print(string.format(" > Avg Latency: %.8f seconds", AvgLatency))
	print(string.format(" > Throughput:  %d ops/sec", Throughput))
	print("--------------------------------------------------")
end

-- small delay to avoid startup interference
task.wait(2)

RunBenchmark()

-- cleanup after test
task.delay(1, function()
	TestSignal:Destroy()
	print("[VextSignal]: Test completed. Memory cleared.")
end)
