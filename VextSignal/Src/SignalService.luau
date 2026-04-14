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

-- Thread Pooling
local freeThreads: { thread } = {}
local MAX_POOL_SIZE = 128

-- Executed in a separate thread to prevent one listener's error from crashing the whole Signal.
local function runHandler(func: (...any) -> (), ...: any)
	local ok, err = pcall(func, ...)
	if not ok then
		warn(`[VextSignal Error]: {tostring(err)}`)
	end
end

-- The loop that keeps threads alive for reuse.
local function yieldLoop()
	while true do
		local thread = coroutine.running()
		table.insert(freeThreads, thread)
		
		local func: any, args: any = coroutine.yield()

		if func and args then
			local a = args :: { [number]: any, n: number }
			runHandler(func, table.unpack(a, 1, a.n))
		end
		
		-- If the pool is too large, let the thread die naturally to save memory.
		if #freeThreads > MAX_POOL_SIZE then
			break
		end
	end
end

local function getThread(): thread
	if #freeThreads > 0 then
		return table.remove(freeThreads) :: thread
	end
	local newThread = coroutine.create(yieldLoop)
	coroutine.resume(newThread) -- Initialize the loop
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

-- Disconnects the listener and cleans up references for the Garbage Collector.
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
	
	-- Nullify references to prevent memory leaks
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

	-- Insert node into prioritized linked list (Descending order)
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
			-- Using thread pooling for optimal performance
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
			-- Uses task.spawn for immediate execution in a new thread
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
			-- Defers execution to the next engine step
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
		-- Resume the waiting thread with passed arguments
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

-- Disconnects all active listeners without destroying the Signal object.
function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	while item do
		item.Connected = false
		item = item._next
	end
	selfAny._handlerListHead = nil
end

-- Completely cleans up the Signal.
function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()
	setmetatable(self, nil)
end

return Signal :: any
