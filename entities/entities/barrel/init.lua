AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

function  ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.Entity:PhysicsInit( SOLID_NONE )	--SOLID_VPHYSICS
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_NONE )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then phys:Wake() end
end

function ENT:OnRemove()
	self:EmitSound( "surprised.wav" )

	local ent = ents.Create( "env_explosion" )
	ent.BarrelOwner = self:GetOwner()
	ent:SetPos( self:GetPos() )
	ent:SetParent( self:GetOwner() )
	ent:SetOwner( self:GetOwner() )
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", "150" )
	ent:Fire( "Explode", 0, 0 )

	--[[
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "barrel_explode", effectdata, true, true )
	
	self:EmitSound( "vo/k_lab/kl_ahhhh.wav" )]]
end

function ENT:OnTakeDamage(  dmg )
	--only bullet damage can kill us
	if (!dmg:IsBulletDamage()) then return end
	
	local ply = dmg:GetAttacker()

	if (dmg:GetInflictor():IsPlayer()) then ply = dmg:GetInflictor() end

	self:Remove() --remove entity
	self:GetOwner():TakeDamage( 200, ply, ply) --kill the player
end
--[[
function ENT:Think()
	if (!self:GetOwner()) or (!self:GetOwner():Alive()) then
		self:Remove()
		return
	end

	self:SetPos( self:GetOwner():GetPos() )
end
]]