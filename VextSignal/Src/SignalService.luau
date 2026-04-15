--!strict
local Types = require(script.Parent.SignalTypes)

export type Connection = Types.Connection
export type Signal<T...> = Types.Signal<T...>
type InternalNode = Types.Node<any>

-- configuration
local MAX_POOL_SIZE = 512
local freeThreads: { thread } = {}

-- runs handler safely so one error does not break the whole signal
local function runHandler(func: (...any) -> (), args: { any }, argCount: number)
	local success, fault = pcall(func :: any, table.unpack(args, 1, argCount))
	if not success then
		warn(string.format("[VextSignal Error]: %s\n%s", tostring(fault), debug.traceback()))
	end
end

-- coroutine loop reused by the thread pool
local function yieldLoop()
	local currentThread = coroutine.running()

	while true do
		local func, args, argCount = coroutine.yield()

		if func then
			runHandler(func, args, argCount)
		end

		-- return thread to pool or kill it if pool is full
		if #freeThreads < MAX_POOL_SIZE then
			table.insert(freeThreads, currentThread)
		else
			break
		end
	end
end

-- gets a reusable coroutine or creates a new one
local function getThread(): thread
	local t: thread? = table.remove(freeThreads)

	if not t or coroutine.status(t) == "dead" then
		local newThread = coroutine.create(yieldLoop)
		t = newThread
		coroutine.resume(newThread)
	end

	return t :: thread
end

-- connection object
local Connection = {}
Connection.__index = Connection

-- disconnects this listener from the signal
function Connection.Disconnect(self: any)
	if not (self and self.Connected) then
		return
	end

	self.Connected = false

	local signal = self._signal
	local prev = self._prev :: InternalNode?
	local next = self._next :: InternalNode?

	if prev then
		prev._next = next
	elseif signal and (signal :: any)._handlerListHead == self then
		(signal :: any)._handlerListHead = next
	end

	if next then
		next._prev = prev
	end

	-- clear references for gc
	self._signal = nil
	self._prev = nil
	self._next = nil
	self._fn = nil
end

-- signal object
local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		_handlerListHead = nil,
	}, Signal) :: any
end

function Signal.Connect<T...>(self: any, func: (T...) -> (), priority: number?): Connection
	local connection: InternalNode = {
		Connected = true,
		Priority = priority or 0,
		_signal = self,
		_next = nil,
		_prev = nil,
		_fn = func :: (...any) -> (),
		Disconnect = Connection.Disconnect,
	}

	setmetatable(connection :: any, Connection)

	local selfAny = self :: any
	local head = selfAny._handlerListHead :: InternalNode?

	-- insert into doubly linked list sorted by priority
	if not head or connection.Priority > head.Priority then
		connection._next = head
		if head then
			head._prev = connection
		end
		selfAny._handlerListHead = connection
	else
		local current: InternalNode = head

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

-- fire using coroutine pool (safe mode)
local function FireSecure(self: any, ...: any)
	local item = self._handlerListHead :: InternalNode?
	if not item then
		return
	end

	local args: any = table.pack(...)
	local count = args.n

	while item do
		local nextItem = item._next
		local fn = item._fn

		if item.Connected and fn then
			coroutine.resume(getThread(), fn, args, count)
		end

		item = nextItem
	end
end
(Signal :: any).FireSecure = FireSecure

-- fire using task.spawn (fast, async)
function Signal.Fire<T...>(self: any, ...: T...)
	local item = (self :: any)._handlerListHead :: InternalNode?

	while item do
		local nextItem = item._next
		local fn = item._fn

		if item.Connected and fn then
			task.spawn(fn :: any, ...)
		end

		item = nextItem
	end
end

-- fire using pcall (synchronous safe execution)
function Signal.FireHyper<T...>(self: any, ...: T...)
	local item = (self :: any)._handlerListHead :: InternalNode?

	while item do
		local nextItem = item._next
		local fn = item._fn

		if item.Connected and fn then
			local success, err = pcall(fn :: any, ...)
			if not success then
				warn("[VextSignal Hyper Error]: " .. tostring(err))
			end
		end

		item = nextItem
	end
end

-- fire at end of frame using task.defer
local function FireDeferred(self: any, ...: any)
	local item = self._handlerListHead :: InternalNode?
	if not item then
		return
	end

	local args: any = table.pack(...)
	local count = args.n

	while item do
		local nextItem = item._next
		local fn = item._fn

		if item.Connected and fn then
			task.defer(runHandler :: any, fn :: any, args, count)
		end

		item = nextItem
	end
end
(Signal :: any).FireDeferred = FireDeferred

-- connects a handler that runs once
function Signal.Once<T...>(self: any, func: (T...) -> (), priority: number?): Connection
	local connection: Connection
	local fired = false

	connection = (self :: Signal<T...>):Connect(function(...: T...)
		if fired then
			return
		end
		fired = true
		connection:Disconnect()
		func(...)
	end, priority)

	return connection
end

-- yields until the signal fires and returns passed arguments
function Signal.Wait<T...>(self: any): T...
	local runningThread = coroutine.running();

	(self :: any):Once(function(...: any)
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

-- disconnects all listeners
function Signal.DisconnectAll(self: any)
	local item = (self :: any)._handlerListHead :: InternalNode?

	while item do
		local nextItem = item._next
		item.Connected = false
		item._fn = nil
		item._prev = nil
		item._next = nil
		item = nextItem
	end

	(self :: any)._handlerListHead = nil
end

-- fully clears the signal and releases resources
function Signal.Destroy(self: any)
	(self :: any):DisconnectAll()
	setmetatable(self :: any, nil)
end

return (Signal :: any) :: Types.SignalClass
