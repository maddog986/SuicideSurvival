include( 'shared.lua' )
include( 'level/client.lua' )
--include( 'scoreboard.lua' )

util.PrecacheModel( "models/props_c17/oildrum001_explosive.mdl" )
util.PrecacheModel( "models/a_shrubbery.mdl" )
util.PrecacheModel( "models/round_bush.mdl" )

--create default fonts to use
surface.CreateFont("Tahoma", 22, 700, true, false, "MDSBtip22")
surface.CreateFont("Tahoma", 18, 700, true, false, "MDSBtip18")
surface.CreateFont("Tahoma", 16, 400, true, false, "MDSBtip16")
surface.CreateFont("Tahoma", 14, 400, true, false, "MDSBtip14")


/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( )
---------------------------------------------------------*/
function GM:HUDShouldDraw( name )
	--table of huds we dont need
	local no = {"CHudAmmo","CHudMessage","CHudWeaponSelection","CHudSuitPower","CHudBattery","CHudSecondaryAmmo","CHudDamageIndicator"}

	if (!LocalPlayer()) or (!LocalPlayer().Team) then return end

	--only humans need the health hud
	if (LocalPlayer():Team() == TEAM_BARRELS) then table.insert(no, "CHudHealth") end

	return !table.HasValue(no, name)
end


/*---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
---------------------------------------------------------*/
function GM:HUDDrawTargetID()
     return false
end


/*---------------------------------------------------------
   Name: gamemode:CalcView( )
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angles, fov )
	--Get the ragdoll entity of the player
	--This will return nil if the player is alive
	local rag = ply:GetRagdollEntity()

	--If the entity is valid
	if ValidEntity(rag) then
		--Get the eye attachment from the ragdoll
		local att = rag:GetAttachment(rag:LookupAttachment("eyes"))

		--Don't return a self made table here, return the table returned by the base function
		return self.BaseClass:CalcView( ply, att.Pos, att.Ang, fov )
	end

	--custom barrel view
	if (ply:Team() == TEAM_BARRELS and ply:Alive()) then origin = (origin + (ply:GetForward() * -100)) end

	--Else return what is received, which means don't change anything
	return self.BaseClass:CalcView( ply, origin, angles, fov )
end


/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
---------------------------------------------------------*/
function GM:HUDPaint()
	self.BaseClass.HUDPaint( self )

	self:MakeHud({
		{"Suicide Survival", "MDSBtip22", Color(255,255,0,180)},
		{"Current Map: " .. level.Name(), "MDSBtip16", Color(255,255,255,180)},
		{"Next Map: " .. level.GetNext(), "MDSBtip16", Color(255,255,255,180)},
		{"Time Left: " .. self:SecondsToClock(level.TimeLeft()), "MDSBtip16", Color(255,255,255,180)}
	},{position = "Bottom Right"})

	if (LocalPlayer():Alive()) then return end

	self:MakeHud({
		{"Your Dead. Press any key to respawn.", "MDSBtip22", Color(255,255,0,255)}
	},{position = "Center Center"})
end


/*---------------------------------------------------------
   Name: gamemode:MakeHud( )
---------------------------------------------------------*/
function GM:MakeHud( Text, Settings )
	local boxWidth, boxHeight = 0, 0
	local textMiddle = 0
	local lineSpacing = 2
	local mT1, mT2 = 0, 0

	if !Settings then Settings = {position="",padding=10} end

	local spacing = (Settings.spacing || 20)

	for _, text in pairs( Text ) do
		local sentence = text[1]
		local _sentence = sentence

		surface.SetFont( text[2] or "MDSBtip18" )

		if type(sentence) == "table" then
			_sentence = ""

			for _, _text in pairs( sentence ) do
				_sentence = _sentence .. " " .. _text
			end

			local textWidth, textHeight = surface.GetTextSize( sentence[1] )
			if (textWidth > mT1) then mT1 = textWidth end
			if (textWidth > textMiddle) then textMiddle = textWidth end

			local textWidth, textHeight = surface.GetTextSize( " " .. sentence[2] )
			if (textWidth > mT2) then mT2 = textWidth end
		end

		--get the height and width sizes from the line of text
		local textWidth, textHeight = surface.GetTextSize( _sentence )

		if ((mT1+mT2) > boxWidth) then boxWidth = (mT1+mT2) end
		if (textWidth > boxWidth) then boxWidth = textWidth end

		--update box height
		boxHeight = boxHeight + (textHeight + lineSpacing)
	end

	--update max box width
	boxWidth = boxWidth + 2 + spacing
	--remove extra padding
	boxHeight = (boxHeight - 2) + spacing

	local boxX, boxY = ScrW(), ScrH()

	if Settings.position == "Top Left" then
		boxX = (Settings.padding || 10)
		boxY = (Settings.padding || 10)
	elseif Settings.position == "Top Right" then
		boxX = (Settings.X || ScrW()) - boxWidth - (Settings.padding || 10)
		boxY = (Settings.padding || 10)
	elseif Settings.position == "Bottom Left" then
		boxX = (Settings.padding || 10)
		boxY = (Settings.Y || ScrH()) - boxHeight - (Settings.padding || 10)
	elseif Settings.position == "Center Center" then
		boxX = (ScrW() / 2) - (boxWidth / 2) - (Settings.padding || 10)
		boxY = (ScrH() / 2) - (boxHeight / 2) - (Settings.padding || 10)
	else
		--if (Settings.position || "Bottom Right") = "Bottom Right" Then
		boxX = (Settings.X || ScrW()) - boxWidth - (Settings.padding || 10)
		boxY = (Settings.Y || ScrH()) - boxHeight - (Settings.padding || 10)
	end


	--draw.RoundedBox( Number Bordersize, Number X, Number Y, Number Width, Number Height, Table Colour )
	draw.RoundedBox(8, boxX, boxY, boxWidth, boxHeight, Color(0, 0, 0, 100))
	--another border
	draw.RoundedBox(8, boxX - 5, boxY - 5, boxWidth + 10, boxHeight + 10, Color(0, 0, 0, 100))

	--draw.DrawText( String Text, String Font, Number X, Number Y, Table Colour, Number Xalign )
	--Xalign Values
	--TEXT_ALIGN_LEFT = 0, TEXT_ALIGN_CENTER = 1, TEXT_ALIGN_RIGHT = 2, TEXT_ALIGN_TOP = 3, TEXT_ALIGN_BOTTOM = 4
	--color = r g b a


	local sX = boxX
	local sY = boxY
	local lineY = (sY-3)	--remove extra spacing

	for _, text in pairs( Text ) do
		local sentence = text[1]
		local _sentence = sentence

		if type(sentence) == "table" then
			_sentence = ""

			for _, _text in pairs( sentence ) do
				_sentence = _sentence .. " " .. _text
			end
		end

		surface.SetFont( text[2] or "MDSBtip18" )

		local textW, textH = surface.GetTextSize( _sentence )

		if type(sentence) == "table" then
			local font = text[2] or "MDSBtip18"
			local pos = {
				x = sX + textMiddle + (spacing/2),
				y = lineY + (spacing/2)
			}
			local color = (text[3] or Color(255,255,255,255))
			local color2 = Color(0,0,0,255)

			--[[
			TEXT_ALIGN_LEFT   = 0
			TEXT_ALIGN_CENTER = 1
			TEXT_ALIGN_RIGHT  = 2
			TEXT_ALIGN_TOP    = 3
			TEXT_ALIGN_BOTTOM = 4
			]]

			draw.SimpleTextOutlined(text[1][1], font, pos.x, pos.y, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, color2)
			draw.TextShadow({text = text[1][1],font = font,pos = {pos.x, pos.y},xalign = TEXT_ALIGN_RIGHT,yalign = TEXT_ALIGN_RIGHT,color = color}, 2, 200)

			draw.SimpleTextOutlined(" " .. text[1][2], font, pos.x, pos.y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, color2)
			draw.TextShadow({text = " " .. text[1][2],font = font,pos = {pos.x, pos.y},xalign = TEXT_ALIGN_LEFT,yalign = TEXT_ALIGN_LEFT,color = color}, 2, 200)
		else
			draw.SimpleTextOutlined(_sentence, (text[2] or "MDSBtip18"), (sX + (boxWidth/2)), (lineY + (spacing/2) + 10), (text[3] or Color(255,255,255,255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
			draw.TextShadow({
				text = _sentence,
				font = (text[2] or "MDSBtip18"),
				pos = {(sX + (boxWidth/2)), (lineY + (spacing/2) + 10)},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = (text[3] or Color(255,255,255,255))
			}, 2, 200)
		end

		lineY = lineY + textH + lineSpacing + 2
	end
end


/*---------------------------------------------------------
   Name: gamemode:PlayerBindPress( )
   Desc: A player pressed a bound key - return true to override action
---------------------------------------------------------*/
function GM:PlayerBindPress( ply, bind, down )
	--disable duck.. kinda hacky but works i guess
	return (down && bind == "+duck") && (ply:Team() == TEAM_BARRELS)
end


/*---------------------------------------------------------
   Name: gamemode:SecondsToClock( )
---------------------------------------------------------*/
function GM:SecondsToClock(sSeconds)
	local nSeconds = tonumber(sSeconds)

	if nSeconds == 0 then
		return "00:00:00"
	else
		nHours = string.format("%02.f", math.floor(nSeconds/3600))
		nMins = string.format("%02.f", math.floor(nSeconds/60 - (nHours*60)))
		nSecs = string.format("%02.f", math.floor(nSeconds - nHours*3600 - nMins *60))
		return nHours..":"..nMins..":"..nSecs
	end
end


























--[[

-- Basic anti-radar by phenex.
local _fakevec = Vector( 1, 0, 0 )

local meta = FindMetaTable( "Entity" )

if meta ~= nil then
	function meta:EyePos() return _fakevec end
	function meta:GetAttachment() return { Ang = _fakevec, Pos = _fakevec } end
	function meta:GetFlexBound() return _fakevec, _fakevec, _fakevec, _fakevec, _fakevec, _fakevec end
	function meta:GetGroundEntity() return NULL end
	function meta:GetPos() return _fakevec end
	function meta:LocalToWorld() return _fakevec end
	function meta:OBBCenter() return _fakevec end
	function meta:OBBMaxs() return _fakevec end
	function meta:OBBMins() return _fakevec end
	function meta:WorldSpaceAABB() return _fakevec, _fakevec end
end

local meta = FindMetaTable( "Player" )

if meta ~= nil then
	function meta:GetEyeTrace() return nil end
	function meta:GetShootPos() return _fakevec end
end

player.GetByID = LocalPlayer
player.GetAll = function( ) return {} end]]