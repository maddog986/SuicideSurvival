AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "level/shared.lua" )
AddCSLuaFile( "level/client.lua" )

include( 'shared.lua' )
include( 'level/server.lua' )

--load models
for k, v in pairs(file.Find("materials/Models/a_shrubbery*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/Models/"..v)
end
for k, v in pairs(file.Find("materials/Models/pappel*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/Models/"..v)
end
for k, v in pairs(file.Find("materials/Models/round_bush*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/Models/"..v)
end

--load materials
for k, v in pairs(file.Find("materials/ferret_*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/"..v)
end
for k, v in pairs(file.Find("materials/glasswindow*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/"..v)
end
for k, v in pairs(file.Find("materials/ss_*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/"..v)
end
for k, v in pairs(file.Find("materials/wooddoor022a*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile("materials/"..v)
end

resource.AddFile("models/a_shrubbery.mdl")
resource.AddFile("models/pappel.mdl")
resource.AddFile("models/round_bush.mdl")

util.PrecacheModel("models/a_shrubbery.mdl")
util.PrecacheModel("models/pappel.mdl")
util.PrecacheModel("models/round_bush.mdl")

GM.footsteps_human = {}

for k, v in pairs(file.Find("sound/footsteps_human/*", "GAME")) do
	table.insert(GM.footsteps_human, "footsteps_human/"..v)

	MsgN("-- AddFile: " .. v)
	resource.AddFile(Sound("footsteps_human/"..v))
end

GM.footsteps_shrub = {}

for k, v in pairs(file.Find("sound/footsteps_shrub/*", "GAME")) do
	table.insert(GM.footsteps_shrub, "footsteps_shrub/"..v)

	MsgN("-- AddFile: " .. v)
	resource.AddFile( Sound("footsteps_shrub/"..v) )
end

for k, v in pairs(file.Find("sound/taunts_suicider/*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile( Sound("taunts_suicider/"..v) )
end

for k, v in pairs(file.Find("sound/taunts_survivor/*", "GAME")) do
	MsgN("-- AddFile: " .. v)
	resource.AddFile( Sound("taunts_survivor/"..v) )
end


resource.AddFile("sound/boing.wav")
util.PrecacheSound( "boing.wav" )

resource.AddFile("sound/surprised.wav")
util.PrecacheSound( "surprised.wav" )

resource.AddFile("sound/violin_down.wav")
util.PrecacheSound( "violin_down.wav" )

resource.AddFile("sound/violin_up.wav")
util.PrecacheSound( "violin_up.wav" )

resource.AddFile("sound/warp1.wav")
util.PrecacheSound( "warp1.wav" )

resource.AddFile("sound/consnd/joinserver.mp3")
util.PrecacheSound( "consnd/joinserver.mp3" )


function GM:Initialize()
	timer.Simple(1, function()
		local ent = ents.FindByClass("item_ammo_crossbow")

		for _, _ent in pairs( ent ) do
			_ent:Remove()
		end
	end)
end


/*---------------------------------------------------------
   Name: gamemode:DoPlayerDeath( )
   Desc: Carries out actions when the player dies
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, attacker, dmginfo )
	--only do ragdoll if human
	if (ply:Team() == TEAM_HUMANS) then
		ply:AddDeaths( 1 )
		ply:CreateRagdoll()
		return
	end

	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		if ( attacker != ply ) then
			attacker:AddFrags( 1 )
		end
	end
end


/*---------------------------------------------------------
   Name: gamemode:PlayerDeathSound
---------------------------------------------------------*/
function GM:PlayerDeathSound()
	return true
end


/*---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker )
	return true
end


/*---------------------------------------------------------
   Name: gamemode:EntityTakeDamage
---------------------------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ( ent:IsPlayer() && attacker:IsPlayer() && ent:Team() == TEAM_BARRELS) then dmginfo:SetDamage( 1000 ) end

	if (attacker:IsPlayer()) then dmginfo:SetInflictor( attacker ) end

	if (inflictor.BarrelOwner) then
		inflictor = inflictor.BarrelOwner
		attacker = inflictor

		dmginfo:SetInflictor( inflictor )
		dmginfo:SetAttacker( inflictor )
	end
end


/*---------------------------------------------------------
   Name: gamemode:KeyPress
---------------------------------------------------------*/
function GM:KeyPress( ply, key )
	self.BaseClass.KeyPress( self, ply, key )

	if (ply:Team() == TEAM_BARRELS) and (key == IN_ATTACK) and (ply:Alive()) and (ply.Barrel:IsValid()) and ((CurTime() - ply.Spawned) > 0.1) then
		ply:Kill()
	return end

	--barrel attack2 play sounds
	if (ply:Team() == TEAM_BARRELS) and (key == IN_ATTACK2) and (ply:Alive()) then
		local sounds = {"taunts_suicider/behindyou01.wav", "taunts_suicider/behindyou02.wav", "taunts_suicider/overhere01.wav", "taunts_suicider/overthere01.wav", "taunts_suicider/overthere02.wav", "taunts_suicider/yalala.wav"}

		ply:EmitSound( sounds[math.random(1, #sounds)] )
	return end

	--human attack2 play sounds
	if (ply:Team() == TEAM_HUMANS) and (key == IN_ATTACK2) and (ply:Alive()) then
		local sounds = {"taunts_survivor/ecky.wav", "taunts_survivor/ni.wav", "taunts_survivor/notseen.wav", "taunts_survivor/shrub.wav", "taunts_survivor/shrub2.wav"}

		ply:EmitSound( sounds[math.random(1, #sounds)] )
	return end

	if (key != IN_USE ) then return end

	if (ply:Team() == TEAM_BARRELS) then
		ply:Kill()
		ply:SetTeam( TEAM_HUMANS )
		ply:PrintMessage( HUD_PRINTTALK, "You're now on the humans team, press 'E' to switch back to the barrels team" )
	else
		ply:Kill()
		ply:SetTeam( TEAM_BARRELS )
		ply:PrintMessage( HUD_PRINTTALK, "You're now on the barrels team, press 'E' to switch back to the humans team" )
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath
---------------------------------------------------------*/
function GM:PlayerDeath( ply, inflictor, killer )
	self.BaseClass.PlayerDeath( self, ply, inflictor, killer )

	--remove barrel view if it exists
	if (ValidEntity(ply.Barrel)) then ply.Barrel:Remove() end
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( ply )
	--reset spawn time.. little hacky way of making sure we dont explode on attack key press
	ply.Spawned = CurTime()

	--auto balance
	if (ply:Team() == TEAM_BARRELS) then
		ply:SetTeam( TEAM_BARRELS )
		ply:SetupBarrel()
	else
		ply:SetTeam( TEAM_HUMANS )
		ply:SetupPlayer()
	end
end


/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip
---------------------------------------------------------*/
function GM:PlayerNoClip( ply )
	return false
end


/*---------------------------------------------------------
   Name: gamemode:PlayerFootstep
---------------------------------------------------------*/
function GM:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )
	if ( ply:KeyDown( IN_JUMP ) and !ply:KeyDownLast( IN_JUMP )) then
		ply:EmitSound( "boing.wav", 40, 100 )
		return true
	end

	if (ply:Team() == TEAM_BARRELS) then
		ply:EmitSound( table.Random(self.footsteps_shrub), 40, 100 )
	else		
		ply:EmitSound( table.Random(self.footsteps_human), 40, 100 )
	end

	return true
end


/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( ply )
	ply:SendLua("surface.PlaySound( \"consnd/joinserver.mp3\" )")
end


local meta = FindMetaTable("Entity")

if (!meta.OldSetColor) then meta.OldSetColor = meta.SetColor end

--fixes alpha issues
function meta:SetColor( color )
	if (color.a < 255) then self:SetRenderMode(1) end
	return self:OldSetColor(color)
end




--add some player options
local meta = FindMetaTable( "Player" )

--fix these functions
function meta:SprintDisable()
	GAMEMODE:SetPlayerSpeed( self, 250, 250 )
end

function meta:SprintEnable()
	GAMEMODE:SetPlayerSpeed( self, 250, 350 )
end

function meta:AddScore( amount )
	self.Score = (self.Score or 0) + amount
end

function meta:GetScore()
	return (self.Score or 0)
end

function meta:SetupPlayer()
	//Remove any old ammo
	self:RemoveAllAmmo()

	--only need a pistol
	self:GiveAmmo( 9999, "Pistol", true )
	self:Give( "weapon_pistol" )
	self:SelectWeapon( "weapon_pistol" )

	--self:Give( "weapon_shuriken" )
	--self:SelectWeapon( "weapon_shuriken" )

	local modelname = player_manager.TranslatePlayerModel( self:GetInfo( "cl_playermodel" ) )
	util.PrecacheModel( modelname )

	self:SetModel( modelname )
	self:SprintEnable()
	self:SetJumpPower( 230 )
	self:SetColor( Color(255, 255, 255, 255) )	--hacky but works
end

function meta:SetupBarrel()
	--little hacky since i dont know how to set a barrel view any better
	local ent = ents.Create( "barrel" )
	ent:SetPos( self:GetPos() )
	ent:SetOwner( self )
	ent:SetParent( self )
	ent:SetModel( level.GetModel() )
	ent:Spawn()

	self.Barrel = ent
	self:SprintDisable()
	self:SetJumpPower( 230 )
	self:SetColor( Color(255, 255, 255, 0) ) 	--hacky but works
end