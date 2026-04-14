--!strict

-- Internal node structure used for the prioritized linked list.
export type Node<T...> = {
	Connected: boolean,
	Priority: number,
	_signal: any,
	_next: any,
	_prev: any,
	_fn: (T...) -> (),
}

-- Public connection handle. Provides an interface to stop listening to events.
export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

-- Core Signal Object.
-- Efficiently manages event listeners with priority support and thread pooling.
export type Signal<T...> = {
	_handlerListHead: any,

	-- Subscribes a handler to the signal.
	Connect: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- Subscribes a handler that automatically disconnects after one execution.
	Once: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- Executes all handlers immediately using thread pooling.
	Fire: (self: Signal<T...>, ...any) -> (),

	-- Executes handlers using task.spawn (Fastest for single fires).
	FireSpawn: (self: Signal<T...>, ...any) -> (),

	-- Schedules handlers to run at the end of the current frame.
	FireDeferred: (self: Signal<T...>, ...any) -> (),

	-- Yields the current thread until the signal is fired.
	Wait: (self: Signal<T...>) -> T...,

	-- Disconnects all listeners.
	DisconnectAll: (self: Signal<T...>) -> (),

	-- Cleans up the signal and its connections.
	Destroy: (self: Signal<T...>) -> (),
}

return {}
