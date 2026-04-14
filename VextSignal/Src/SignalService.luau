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

-- coroutine pool for reusing threads and reducing allocations
local freeThreads: { thread } = {}
local MAX_POOL_SIZE = 128

-- safely executes a handler so one failure doesn't break signal chain
local function runHandler(func: (...any) -> (), ...: any)
	local ok, err = pcall(func, ...)
	if not ok then
		warn(`[VextSignal Error]: {tostring(err)}`)
	end
end

-- worker loop used by pooled coroutines
-- waits for assigned work and executes it safely
local function yieldLoop()
	while true do
		local thread = coroutine.running()
		table.insert(freeThreads, thread)

		local func, args = coroutine.yield()

		if func and args then
			local a = args :: { [number]: any, n: number }
			runHandler(func, table.unpack(a, 1, a.n))
		end

		-- prevents unbounded growth of coroutine pool
		if #freeThreads > MAX_POOL_SIZE then
			break
		end
	end
end

-- gets a reusable coroutine or creates a new one if pool is empty
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

-- removes connection from signal linked list and cleans references
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

	-- clear references for garbage collector safety
	self._signal = nil
	self._prev = nil
	self._next = nil
end

-- connects a listener with optional priority ordering
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

	-- insert into linked list sorted by priority (high first)
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

-- fires all listeners using coroutine pool execution
function Signal.Fire<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			local ok, err = coroutine.resume(getThread(), item._fn, args)
			if not ok then
				warn(`[VextSignal Critical]: Failed to resume thread: {tostring(err)}`)
			end
		end

		item = nextItem
	end
end

-- fires all listeners using task.spawn (parallel execution)
function Signal.FireSpawn<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			task.spawn(item._fn, table.unpack(args, 1, args.n))
		end

		item = nextItem
	end
end

-- fires listeners at end of frame using task.defer
function Signal.FireDeferred<T...>(self: Signal<T...>, ...: any)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	local args = table.pack(...)

	while item do
		local nextItem = item._next

		if item.Connected then
			local fn = item._fn

			task.defer(function()
				runHandler(fn, table.unpack(args, 1, args.n))
			end)
		end

		item = nextItem
	end
end

-- connects a listener that auto-disconnects after first call
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

-- yields current thread until signal is fired
function Signal.Wait<T...>(self: Signal<T...>): T...
	local runningThread = coroutine.running()

	self:Once(function(...)
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

-- removes all listeners without destroying object
function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?

	while item do
		item.Connected = false
		item = item._next
	end

	selfAny._handlerListHead = nil
end

-- fully destroys signal and clears connections
function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()
	setmetatable(self, nil)
end

return Signal :: any
