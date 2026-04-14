--!strict
local Types = require(script.Parent.SignalTypes)

type Connection = Types.Connection
type Signal<T...> = Types.Signal<T...>

-- Internal type used for strict member access inside the module
type InternalNode = {
	Connected: boolean,
	Priority: number,
	_next: any,
	_prev: any,
	_fn: (...any) -> (),
}

-- [ THREAD POOLING ] --
local freeThreads: { thread } = {}

-- Safely executes a handler and catches errors to prevent signal interruption.
local function runHandler(func: (...any) -> (), ...: any)
	local result = { pcall(func, ...) }
	if not result[1] then
		warn(`[VextSignal Error]: {tostring(result[2])}`)
	end
end

-- Thread loop: waits for a task, executes it, and returns to the pool.
local function yieldLoop()
	while true do
		table.insert(freeThreads, coroutine.running())
		local func: any, args: any = coroutine.yield()

		if func and args then
			local a = args :: { [number]: any, n: number }
			runHandler(func, table.unpack(a, 1, a.n))
		end
	end
end

-- Retrieves an available thread or spawns a new one if necessary.
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

-- Creates a new Signal instance.
function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		_handlerListHead = nil,
	}, Signal) :: any
end

-- Disconnects a specific connection and updates the linked list.
function Connection.Disconnect(self: any)
	if not self.Connected then
		return
	end
	self.Connected = false

	local prev = self._prev
	local next = self._next

	if prev then
		if prev._handlerListHead == self then
			prev._handlerListHead = next
		else
			prev._next = next
		end
	end
	if next then
		next._prev = prev
	end
end

function Signal.Connect<T...>(self: Signal<T...>, func: (T...) -> (), priority: number?): Connection
	local selfAny: any = self
	local connection: InternalNode = {
		Connected = true,
		Priority = priority or 0,
		_next = nil,
		_prev = selfAny,
		_fn = func :: any,
	}
	setmetatable(connection, Connection)

	local head = selfAny._handlerListHead :: InternalNode?

	-- Insert node based on priority (Descending order)
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
			coroutine.resume(getThread(), item._fn, args)
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
		if fired then
			return
		end
		fired = true
		connection:Disconnect()
		func(...)
	end, priority)

	return connection
end

function Signal.Wait<T...>(self: Signal<T...>): T...
	local runningThread = coroutine.running()

	self:Once(function(...: any)
		task.spawn(runningThread, ...)
	end)

	return coroutine.yield()
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local selfAny: any = self
	local item = selfAny._handlerListHead :: InternalNode?
	while item do
		item.Connected = false
		item = item._next
	end
	selfAny._handlerListHead = nil
end

function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()
	setmetatable(self, nil)
end

return Signal :: any
