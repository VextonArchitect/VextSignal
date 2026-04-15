--!strict
local signal = require(script.Parent.SignalService)
local types = require(script.Parent.SignalTypes)

--[[
	event system

	central registry for all game signals.
	used for communication between systems.
]]

-- event definitions with strict typing
type eventlist = {
	HealRequested: types.Signal<Player, number>,
	PlayerLevelUp: types.Signal<number>,
	WeaponEquipped: types.Signal<string, Tool>,
}

-- scoped signal container
type scope = {
	get: (self: scope, name: string) -> types.Signal<any>,
}

local bridge = {}

-- static events
-- core gameplay signals (preferred usage)

bridge.events = (
	{
		HealRequested = signal.new(),
		PlayerLevelUp = signal.new(),
		WeaponEquipped = signal.new(),
	} :: any
) :: eventlist

-- dynamic events
-- automatically created when accessed

local _dynamiccache: { [string]: types.Signal<any> } = {}

bridge.dynamic = (
	setmetatable({}, {
		__index = function(_, key: string)
			if not _dynamiccache[key] then
				_dynamiccache[key] = signal.new()
			end
			return _dynamiccache[key]
		end,
	}) :: any
) :: { [string]: types.Signal<any> }

-- scoped events
-- namespaced signal groups

local _scopes: { [string]: { [string]: types.Signal<any> } } = {}

function bridge.scope(scopename: string): scope
	if not _scopes[scopename] then
		_scopes[scopename] = {}
	end

	return {
		get = function(_, signalname: string): types.Signal<any>
			local scope = _scopes[scopename]

			if not scope[signalname] then
				scope[signalname] = signal.new()
			end

			return scope[signalname]
		end,
	}
end

-- cleanup
-- disconnects all signals in all systems

function bridge.clearall()
	for _, sig in pairs(bridge.events :: any) do
		sig:DisconnectAll()
	end

	for _, sig in pairs(_dynamiccache) do
		sig:DisconnectAll()
	end

	for _, scope in pairs(_scopes) do
		for _, sig in pairs(scope) do
			sig:DisconnectAll()
		end
	end
end

return bridge
