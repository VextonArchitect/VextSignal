--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared)

local localSignal = Signal.new()

print("[vext local]: starting client-side validation...")

-- basic local event handling test
-- simulates simple UI interaction flow
localSignal:Connect(function(inputName)
	print("local action detected:", inputName)
end)

task.wait(1)

-- simulate input trigger (like mouse or key press)
localSignal:Fire("mouse_button_1")

-- test cleanup behavior after destroy
-- ensures no lingering listeners remain active
localSignal:Connect(function()
	print("this will be cleaned up shortly")
end)

-- destroy signal and clear all connections
localSignal:Destroy()

-- verify that destroyed signal cannot be used safely
local success, err = pcall(function()
	localSignal:Fire("test")
end)

if not success then
	print("[vext local]: destroy check passed (cannot fire destroyed signal)")
else
	warn("[vext local]: warning - destroyed signal still accepting fires")
end
