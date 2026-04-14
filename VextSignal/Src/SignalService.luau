--!strict
local Types = require(script.Parent.SignalTypes)

type Connection = Types.Connection
type Signal<T...> = Types.Signal<T...>

type InternalNode = {
	Connected: boolean,
	Priority: number,
	_signal: any,
	_next: any,
	_prev: any,
	_fn: (...any) -> (),
}

-- Pool of reusable coroutines
local freeThreads: { thread } = {}
local MAX_POOL_SIZE = 128

-- Runs handler safely so one error does not break others
local function runHandler(func: (...any) -> (), ...: any)
	local ok, err = pcall(func, ...)
	if not ok then
		warn(`[VextSignal Error]: {tostring(err)}`)
	end
end

-- Coroutine loop that waits for work and reuses itself
local function yieldLoop()
	while true do
		local thread = coroutine.running()
		table.insert(freeThreads, thread)

		local func, args = coroutine.yield()

		if func and args then
			local a = args :: { [number]: any, n: number }
			runHandler(func, table.unpack(a, 1, a.n))
		end

		-- Drop extra threads if pool grows too much
		if #freeThreads > MAX_POOL_SIZE then
			break
		end
	end
end

-- Gets a coroutine from pool or creates a new one
local function getThread(): thread
	if #freeThreads > 0 then
		return table.remove(freeThreads) :: thread
	end

	local newThread = coroutine.create(yieldLoop)
	coroutine.resume(newThread)
	return newThread
end

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		_handlerListHead = nil,
	}, Signal) :: any
end

-- Disconnects this connection and removes it from the list
function Connection.Disconnect(self: any)
	if not self.Connected then
		return
	end

	self.Connected = false

	local signal = self._signal
	local prev = self._prev
	local next = self._next

	if prev then
		prev._next = next
	elseif signal._handlerListHead == self then
		signal._handlerListHead = next
	end

	if next then
		next._prev = prev
	end

	-- Clear references for GC
	self._signal = nil
	self._prev = nil
	self._next = nil
end

function Signal.Connect<T...>(self: Signal<T...>, func: (T...) -> (), priority: number?): Connection
	local selfAny: any = self

	local connection: InternalNode = {
		Connected = true,
		Priority = priority or 0,
		_signal = selfAny,
		_next = nil,
		_prev = nil,
		_fn = func :: any,
	}

	setmetatable(connection, Connection)

	local head = selfAny._handlerListHead :: InternalNode?

	-- Insert into list sorted by priority (highest first)
	if not head or connection.Priority > head.Priority then
		connection._next = head
		if head then
			head._prev = connection
		end
		selfAny._handlerListHead = connection
	else
		local current = head

		while current._next and (current._next :: InternalNode).Priority >= connection.Priority do
			current = current._next :: InternalNode
		end

		connection._next = current._next

		if current._next then
			(current._next :: InternalNode)._prev = connection
		end

		current._next = connection
		connection._prev = current
	end

	return (connection :: any) :: Connection
end

function Signal.Fire<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			-- Use pooled coroutine for better performance
			local ok, err = coroutine.resume(getThread(), item._fn, args)
			if not ok then
				warn(`[VextSignal Critical]: Failed to resume thread: {tostring(err)}`)
			end
		end

		item = nextItem
	end
end

function Signal.FireSpawn<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			-- Run immediately using task.spawn
			task.spawn(item._fn, table.unpack(args, 1, args.n))
		end

		item = nextItem
	end
end

function Signal.FireDeferred<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			local fn = item._fn

			-- Run at end of frame
			task.defer(function()
				runHandler(fn, table.unpack(args, 1, args.n))
			end)
		end

		item = nextItem
	end
end

function Signal.Once<T...>(self: Signal<T...>, func: (T...) -> (), priority: number?): Connection
	local connection: Connection
	local fired = false

	connection = self:Connect(function(...: any)
		if fired then return end
		fired = true
		connection:Disconnect()
		func(...)
	end, priority)

	return connection
end

function Signal.Wait<T...>(self: Signal<T...>): T...
	local runningThread = coroutine.running()

	self:Once(function(...: any)
		-- Resume waiting thread with args
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

-- Disconnects all listeners
function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?

	while item do
		item.Connected = false
		item = item._next
	end

	selfAny._handlerListHead = nil
end

-- Fully clears the signal
function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()
	setmetatable(self, nil)
end

return Signal :: any
