--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared)

print("\n[VextSignal]: Starting High-Load Performance Test...")
print("--------------------------------------------------")

local TestSignal = VextSignal.new()
local ITERATIONS = 21000000 -- 21 Million iterations
local counter = 0

-- Simple listener
TestSignal:Connect(function()
	counter += 1
end)

local function RunBenchmark()
	print(string.format("Testing: Firing %d signals...", ITERATIONS))

	local StartTime = os.clock()

	for i = 1, ITERATIONS do
		TestSignal:Fire()
	end

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

task.wait(2) -- Engine settle
RunBenchmark()

task.delay(1, function()
	TestSignal:Destroy()
	print("[VextSignal]: Test completed. Memory cleared.")
end)
