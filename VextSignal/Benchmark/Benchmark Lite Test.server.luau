--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared.Systems.VextSignal.Src.SignalService)

print("\n[VextSignal]: Starting high-load performance benchmark...")
print("--------------------------------------------------")

-- Create test signal instance
local TestSignal = VextSignal.new()

-- Number of iterations for stress test
local ITERATIONS = 21_000_000 -- 21 million calls

-- Simple counter to ensure execution is not optimized away
local counter = 0

-- Basic listener used for benchmarking signal execution cost
TestSignal:Connect(function()
	counter += 1
end)

local function RunBenchmark()
	print(string.format("Firing signal %d times...", ITERATIONS))

	local startTime = os.clock()

	-- Main stress loop
	for _ = 1, ITERATIONS do
		TestSignal:Fire()
	end

	local endTime = os.clock()

	-- Performance calculations
	local duration = endTime - startTime
	local avgLatency = duration / ITERATIONS
	local throughput = math.floor(1 / avgLatency)

	print("--------------------------------------------------")
	print("Benchmark results:")
	print(string.format(" > Total time:     %.6f seconds", duration))
	print(string.format(" > Average latency: %.10f seconds", avgLatency))
	print(string.format(" > Throughput:      %d ops/sec", throughput))
	print("--------------------------------------------------")
end

-- Allow Roblox engine to stabilize before starting benchmark
task.wait(2)

RunBenchmark()

-- Cleanup after benchmark to ensure no memory leaks remain
task.delay(1, function()
	TestSignal:Destroy()
	print("[VextSignal]: Benchmark completed. Memory cleaned.")
end)
