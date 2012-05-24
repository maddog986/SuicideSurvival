level = {
	time = CurTime(),
	maps = {},
	defaulttime = (30 * 60)
}

--returns current map name
function level.Name()
	return string.lower(game.GetMap())
end

--returns next map name
function level.GetNext()
	return level.__next or "Unknown"
end

--returns map max time to play
function level.MaxTime()
	for _idx, _info in pairs( level.maps ) do
		if (string.lower(_info.n) == string.lower(level.Name())) then
			--return the map time limit
			return _info.t
		end
	end

	return level.defaulttime
end

--returns the time left on the map
function level.TimeLeft()
	--figure out the time left
	local left = (level.MaxTime() - (CurTime() - level.time))
	--if passed time (in map change delay most likely) then return zero
	if (left <= 0) then return 0 end
	--return time left
	return left
end