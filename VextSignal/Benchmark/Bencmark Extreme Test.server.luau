--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VextSignal = require(ReplicatedStorage.Shared.Systems.VextSignal.Src.SignalService)

--[[
	benchmark overview
	- throughput: raw dispatch speed (FireHyper)
	- comparison: Hyper vs Secure vs Standard execution cost
	- stability: batch latency distribution
	- memory: gc pressure under sustained load
	- lifecycle: connection churn safety
]]

-- config

local iterations = 1_500_000
local batch_size = 5_000
local latency_samples = 150
local warmup = 30_000

-- signals

local hyper = VextSignal.new()
local secure = VextSignal.new()
local standard = VextSignal.new()

-- state

local stats = {
	hyper_calls = 0,
	secure_calls = 0,
	standard_calls = 0,
	batches = {},
}

-- listeners

hyper:Connect(function(x: number)
	stats.hyper_calls += 1
end)

secure:Connect(function(x: number)
	stats.secure_calls += 1
end)

standard:Connect(function(x: number)
	stats.standard_calls += 1
end)

-- warmup

for i = 1, warmup do
	hyper:FireHyper(i)
	secure:FireSecure(i)
	standard:Fire(i)
end

print("\n[vextsignal benchmark] warmup complete")

-- phase 1: throughput (hyper)

local t0 = os.clock()

for i = 1, iterations do
	hyper:FireHyper(i)
end

local t1 = os.clock()
local hyper_tps = math.floor(iterations / (t1 - t0))

print("\nphase 1 • throughput (hyper)")
print(string.format("  iterations : %d", iterations))
print(string.format("  time       : %.6f sec", (t1 - t0)))
print(string.format("  throughput : %d ops/sec", hyper_tps))

-- phase 2: execution comparison

local function measure(signal, fn, count)
	local start = os.clock()
	for i = 1, count do
		fn(signal, i)
	end
	return os.clock() - start
end

local secure_time = measure(secure, function(s, i)
	s:FireSecure(i)
end, 200_000)

local standard_time = measure(standard, function(s, i)
	s:Fire(i)
end, 200_000)

print("\nphase 2 • execution cost comparison")
print(string.format("  secure   (200k) : %.6f sec", secure_time))
print(string.format("  standard (200k) : %.6f sec", standard_time))

-- phase 3: batch latency

local function run_batch()
	local start = os.clock()
	for i = 1, batch_size do
		hyper:FireHyper(i)
	end
	return os.clock() - start
end

for i = 1, latency_samples do
	stats.batches[i] = run_batch()
end

table.sort(stats.batches)

local sum = 0
for _, v in ipairs(stats.batches) do
	sum += v
end

local function pct(p)
	return stats.batches[math.floor(#stats.batches * p)]
end

local batch_avg = sum / #stats.batches

print("\nphase 3 • batch latency")
print(string.format("  samples : %d", latency_samples))
print(string.format("  avg     : %.6f sec", batch_avg))
print(string.format("  p95     : %.6f sec", pct(0.95)))
print(string.format("  p99     : %.6f sec", pct(0.99)))
print(string.format("  min     : %.6f sec", stats.batches[1]))
print(string.format("  max     : %.6f sec", stats.batches[#stats.batches]))

-- phase 4: connection churn

local churn = VextSignal.new()
local connections = {}

for i = 1, 1000 do
	connections[i] = churn:Connect(function() end)
end

for i = 1, 1000 do
	connections[i]:Disconnect()
end

print("\nphase 4 • connection churn")
print("  status : ok")
print("  connections tested : 1000 connect / 1000 disconnect")

-- phase 5: gc stress

local payload = table.create(1500, "vext")
local gc_before = gcinfo()

for i = 1, 80_000 do
	hyper:FireHyper(payload)
end

local gc_after = gcinfo()

print("\nphase 5 • memory pressure")
print(string.format("  gc delta : %d kb", gc_after - gc_before))

-- cleanup

hyper:Destroy()
secure:Destroy()
standard:Destroy()
churn:Destroy()

print("\nbenchmark complete")
