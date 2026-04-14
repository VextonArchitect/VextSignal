--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared.Systems.VextSignal.Src.SignalService)

print("\n[VextSignal]: Starting high-load performance benchmark...")
print("--------------------------------------------------")

-- Create signal instance for testing
local TestSignal = VextSignal.new()

-- Number of iterations for stress test
local ITERATIONS = 21_000_000 -- 21 million calls

-- Counter to ensure execution is not optimized away by Luau
local counter = 0

-- Simple listener to measure raw execution cost per Fire()
TestSignal:Connect(function()
	counter += 1
end)

local function RunBenchmark()
	print(string.format("Firing signal %d times...", ITERATIONS))

	local startTime = os.clock()

	-- Main stress test loop
	for _ = 1, ITERATIONS do
		TestSignal:Fire()
	end

	local endTime = os.clock()

	-- Benchmark results
	local duration = endTime - startTime
	local avgLatency = duration / ITERATIONS
	local throughput = math.floor(1 / avgLatency)

	print("--------------------------------------------------")
	print("Benchmark results:")
	print(string.format(" > Total time:      %.6f seconds", duration))
	print(string.format(" > Avg latency:     %.10f seconds", avgLatency))
	print(string.format(" > Throughput:      %d ops/sec", throughput))
	print("--------------------------------------------------")
end

-- Let Roblox engine stabilize before heavy benchmark
task.wait(2)

RunBenchmark()

-- Cleanup to avoid memory retention after stress test
task.delay(1, function()
	TestSignal:Destroy()
	print("[VextSignal]: Benchmark completed. Memory cleaned.")
end)
