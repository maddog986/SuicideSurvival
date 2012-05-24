include( 'shared.lua' )

--adds a map to the cycle
function level.Add( name, time, model )
	--send to clients as they need the new info
	umsg.Start("level.Add")
	umsg.String( name )
	umsg.Long( time )
	umsg.End()

	table.insert(level.maps, {n = name, t = time or level.defaulttime, m = model})

	level.SetupNext()
end

--removes a map from the cycle
function level.Remove( name )
	--send to clients as they need the new info
	umsg.Start("level.Remove")
	umsg.String( name )
	umsg.End()

	for _idx, _info in pairs( level.maps ) do
		if (_info.n == name) then
			level.maps[_idx] = nil
		end
	end

	level.SetupNext()
end

--sets a map to load next
function level.SetNext( name )
	--send to clients as they need the new info
	umsg.Start("level.SetNext")
	umsg.String( name )
	umsg.End()

	level.__next = name

	--reset map change timer
	timer.Adjust("MapChange", level.MaxTime(), 0, level.ChangeMap)
end


function level.ChangeTime( name, time )
	for _idx, _info in pairs( level.maps ) do
		if (_info.n == name) then
			_info.t = time
		return end
	end
end




--freezes players, shows score, then changes map after a delay
function level.ChangeMap( name )
	--kill map changing timer
	timer.Destroy("MapChange")

	--make sure this function isnt called twice
	if (level.changingmap) then return end

	--we are changing maps now
	level.changingmap = true

	--change map in 10 seconds
	timer.Simple(10, function()
		level.LoadMap( name )
	end)

	--some player stuff
	for _, ply in pairs( player.GetAll() ) do
		ply:Freeze( true )
		ply:SendLua("GAMEMODE:ScoreboardShow()")
	end
end

--loads a map
function level.LoadMap( name )
	game.ConsoleCommand( "changelevel " .. (name or level.GetNext()) .. "\n" )
end

--figures out the next map in the cycle
function level.SetupNext()
	local found = false

	for _idx, _info in pairs( level.maps ) do
		if (found) then
			level.SetNext( _info.n )
			return _info.n
		end

		if (string.lower(_info.n) == string.lower(level.Name())) then found = true end
	end

	level.SetNext( level.maps[1].n )
	return level.maps[1].n
end

function level.GetModel()
	for _idx, _info in pairs( level.maps ) do
		if (string.lower(_info.n) == string.lower(level.Name())) then
			return (_info.m or "models/a_shrubbery.mdl")
		end
	end

	return "models/a_shrubbery.mdl"
end

--setup map change timer
timer.Create("MapChange", level.MaxTime(), 0, level.MapChange)

--send the new player all the map info
hook.Add("PlayerInitialSpawn", "level.PlayerInitialSpawn", function( ply )
	umsg.Start("level.SetTime")
	umsg.Float( level.time )
	umsg.End()

	umsg.Start("level.SetNext")
	umsg.String( level.GetNext() )
	umsg.End()

	for _idx, _info in pairs( level.maps ) do
		umsg.Start("level.Add", ply)
		umsg.String( _info.n )
		umsg.Long( _info.t )
		umsg.End()
	end
end)


level.Add( "ss_an_arena_dev" )
level.Add( "ss_castleyard_v2" )
level.Add( "ss_garden2" )
level.Add( "ss_gardenpanic_b1" )
level.Add( "ss_greenfield" )
level.Add( "ss_greenFog" )
level.Add( "ss_outback" )
level.Add( "ss_park_final" )
level.Add( "ss_plaza_4" )
level.Add( "ss_superGreen" )