--!strict

-- public connection handle
-- represents a single listener attached to a signal
export type Connection = {
	Connected: boolean,

	-- disconnects this listener from the signal
	Disconnect: (self: Connection) -> (),
}

-- internal node used in the doubly linked list
-- not intended for public use
export type Node<T...> = {
	Connected: boolean,
	Priority: number,

	_signal: any,
	_next: any,
	_prev: any,

	-- handler function (can be nil after disconnect for gc)
	_fn: ((T...) -> ())?,
}

-- main signal interface
-- manages listeners and event dispatch
export type Signal<T...> = {
	-- head of the internal linked list
	_handlerListHead: Node<T...>?,

	-- adds a listener with optional priority
	Connect: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- adds a listener that runs once and auto disconnects
	Once: (self: Signal<T...>, func: (T...) -> (), priority: number?) -> Connection,

	-- fires using coroutine pool (balanced performance + safety)
	FireSecure: (self: Signal<T...>, T...) -> (),

	-- fires using task.spawn (fast, async)
	Fire: (self: Signal<T...>, T...) -> (),

	-- fires synchronously with pcall (lowest overhead, blocking)
	FireHyper: (self: Signal<T...>, T...) -> (),

	-- fires at end of frame using task.defer
	FireDeferred: (self: Signal<T...>, T...) -> (),

	-- yields until the signal fires and returns passed arguments
	Wait: (self: Signal<T...>) -> T...,

	-- disconnects all listeners
	DisconnectAll: (self: Signal<T...>) -> (),

	-- fully clears the signal and releases resources
	Destroy: (self: Signal<T...>) -> (),
}

return {}
