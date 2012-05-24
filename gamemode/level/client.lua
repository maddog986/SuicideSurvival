include( 'shared.lua' )

--adds a map to the cycle
function level.Add( msg )
	local name = msg:ReadString()
	local time = msg:ReadLong()

	table.insert(level.maps, {n = name, t = time or level.defaulttime})
end
usermessage.Hook("level.Add", level.Add)


--removes a map from the cycle
function level.Remove( msg )
	local name = msg:ReadString()

	for _idx, _info in pairs( level.maps ) do
		if (_info.n == name) then
			level.maps[_idx] = nil
		end
	end
end
usermessage.Hook("level.Remove", level.Remove)


--sets a map to load next
function level.SetNext( name )
	level.__next = (name:ReadString() or string.lower(game.GetMapNext()))
end
usermessage.Hook("level.SetNext", level.SetNext)


--sets a map to load next
function level.SetTime( time )
	level.time = time:ReadFloat()
end
usermessage.Hook("level.SetTime", level.SetTime)