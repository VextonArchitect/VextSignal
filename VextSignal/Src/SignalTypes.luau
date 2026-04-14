--!strict

-- internal node used in the priority-linked listener list
-- represents a single connected callback in the signal chain
export type Node<T...> = {
	Connected: boolean,
	Priority: number,

	_signal: any,
	_next: any,
	_prev: any,

	_fn: (T...) -> (),
}

-- connection handle returned to the user
-- used to manually disconnect a listener from the signal
export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

-- core signal object
-- lightweight event system with priority ordering and multiple execution modes
export type Signal<T...> = {
	_handlerListHead: any,

	-- attach a listener to the signal
	Connect: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- attach a listener that runs only once then auto-disconnects
	Once: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- fire all listeners immediately using coroutine pool execution
	Fire: (self: Signal<T...>, ...any) -> (),

	-- fire listeners using task.spawn (parallel execution)
	FireSpawn: (self: Signal<T...>, ...any) -> (),

	-- fire listeners using task.defer (next scheduler step)
	FireDeferred: (self: Signal<T...>, ...any) -> (),

	-- yield until the signal is fired and return received arguments
	Wait: (self: Signal<T...>) -> T...,

	-- disconnect all listeners without destroying the signal
	DisconnectAll: (self: Signal<T...>) -> (),

	-- fully destroy signal and clean internal state
	Destroy: (self: Signal<T...>) -> (),
}
