--!strict

-- Internal node structure used for the linked list.
-- Not intended for direct use by consumers.
export type Node<T...> = {
	Connected: boolean,
	Priority: number,
	_next: any, -- Using 'any' to avoid recursive type depth issues in Luau
	_prev: any,
	_fn: (T...) -> (),
}

-- Public connection handle.
-- Simple interface for users to kill listeners.
export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

-- The core Signal object.
-- Supports variadic generics for full type safety across projects.
export type Signal<T...> = {
	_handlerListHead: any, -- Pointer to the start of the prioritized list

	-- Hook a function to this signal. Optional priority for execution ordering.
	Connect: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- Connects a listener that auto-disconnects after the first fire.
	Once: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- Direct fire. Reuses threads to keep the scheduler happy.
	Fire: (self: Signal<T...>, ...any) -> (),

	-- Standard spawn fire. Good for when you need a fresh thread instantly.
	FireSpawn: (self: Signal<T...>, ...any) -> (),

	-- Defers execution until the next cycle. Best for non-critical UI updates.
	FireDeferred: (self: Signal<T...>, ...any) -> (),

	-- Yields the current thread until the next fire. Returns fired arguments.
	Wait: (self: Signal<T...>) -> T...,

	-- Clears all connections but keeps the signal object alive.
	DisconnectAll: (self: Signal<T...>) -> (),

	-- Full cleanup. Signal becomes useless after this.
	Destroy: (self: Signal<T...>) -> (),
}

return {}
