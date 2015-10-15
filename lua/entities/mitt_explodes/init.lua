AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_modloader.lua")
AddCSLuaFile("sh_decloader.lua")
AddCSLuaFile("sh_networking.lua")
AddCSLuaFile("sh_helper.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_buttons.lua")
include("shared.lua")
util.AddNetworkString( "ktne_network" )

ENT.TimerSpeeds = {
	1,
	0.8,
	0.65
}
function ENT:SpawnFunction(ply,tr)
	if not tr.Hit then return end
	local pos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create(ClassName)
	ent:SetPos(pos)
	local ang = ent:GetAngles()
	ang:RotateAroundAxis( ang:Right(), 90 )
	ent:SetAngles( ang )
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject() if (phys:IsValid()) then phys:Wake() end

	self:GenerateSerial()
	self:SetPaused(true)
	self:SetPausedTime( 300 )


end

function ENT:Think()

	self:SharedThink()

end

net.Receive( "ktne_network", function( len, ply )

	// PLAYER CHECK
	local ent = net.ReadEntity()
	if !IsValid( ent ) or ent:GetClass() != "mitt_explodes" then return end
	local id = net.ReadInt( 32 )
	if !ent:GetModuleByID( id ) then return end
	if !ent:GetModuleByID( id ).GetNet then return end

	local count = net.ReadInt( 32 )
	local args = {}

	for i = 1, count do
		args[i] = net.ReadInt( 32 )
	end
	ent:GetModuleByID( id ):GetNet( unpack( args ) )

end )


hook.Add( "PlayerInitialSpawn", "ktne_net", function( ply )

	for k, v in pairs( ents.FindByClass( "mitt_explodes" ) ) do

		for _, mod in pairs( v.Modules ) do

			for name, _ in pairs( mod.NetworkedVars ) do
				mod:SendVar( name, ply )
			end

		end

	end

end )

function ENT:OnDisarm( pos )

	if #self:GetModulesToDisarm() == 0 then
		self:Defuse()
	end

end


function ENT:GetUsedModuleSpaces()

	local used = {}
	for k, v in pairs( self.Modules ) do
		used[v:GetPosition()] = true
	end
	return used

end
function ENT:GetRandomModulePosition( forceTimer )

	local used = self:GetUsedModuleSpaces()
	assert( #used < 12, "max number of modules hit!" )

	local frontCount = 0
	for i = 1, 6 do
		if table.HasValue( used, i ) then
			frontCount = frontCount + 1
		end
	end
	local picked = math.random( frontCount < 6 and 1 or 7, frontCount < 6 and 6 or 12 )
	if forceTimer then
		picked = math.random( 1, 6 )
	end

	if used[picked] then
		return self:GetRandomModulePosition( forceTimer )
	else
		return picked
	end

end

function ENT:GetUsedDecorSpaces()

	local used = {}
	for k, v in pairs( self.Decorations ) do
		used[ v:GetPosition() ] = true
	end
	return used

end
function ENT:GetRandomDecorPosition()

	local used = self:GetUsedDecorSpaces()
	assert( #used < 20, "max number of decorations hit!" )

	local picked
	while true do
		picked = math.random( 1, 20 )
		if !used[picked] then return picked end
	end

end


function ENT:AddModule( name )

	local modTable = self.ModuleTables[ name ]
	assert( modTable, "module name invalid!" )

	local entity = self
	local MOD = {}
	modTable.__index = modTable
	setmetatable( MOD, modTable )

	self.UniqueIDNum = self.UniqueIDNum + 1
	MOD.UniqueID = self.UniqueIDNum

	function MOD:GetBomb()

		return entity

	end

	function MOD:IsTimer()

		return self.TechName == "timer"

	end

	function MOD:Disarm()

		self:SetDisarmed( true )
		self:GetBomb():OnDisarm( self:GetPosition() )
		self:OnDisarm()

	end

	MOD:NetworkVar( "Int", "Position" )
	MOD:NetworkVar( "Bool", "Disarmed" )
	if name == "timer" then
		MOD:SetPosition( math.random( 1, 6 ) )
	else
		MOD:SetPosition( self:GetRandomModulePosition( MOD.ForceWithTimer ) )
	end
	self:SetNWString( MOD.UniqueID .. "__Type", MOD.TechName )
	self:SetModuleCount( self:GetModuleCount() + 1 )
	self.Modules[ MOD.UniqueID ] = MOD

	MOD:OnStart()


end

function ENT:CreateModules()

	self:KillModules()
	self.Modules = {}

	self:AddModule( "timer" )

	local limit = 0
	local i = 0
	while i < 3 and limit < 999 do

		limit = limit + 1
		i = i + 1
		local v, k = table.Random( self.ModuleTables )
		if k == "timer" or !v.Enabled then i = i - 1 continue end
		
		if v.Rarity and math.random( 1, v.Rarity ) == 1 or !v.Rarity then
			self:AddModule( k )
		else
			i = i - 1
		end

	end

end

function ENT:KillModules()

	for k,v in pairs( self.Modules ) do
		v:OnEnd()
		self.Modules[k] = nil
	end
	self:SetModuleCount( 0 )
	self.UniqueIDNum = 0

end


function ENT:AddDecoration( name )

	local modTable = self.DecorationTables[ name ]
	assert( modTable, "decoration name invalid!" )
	local entity = self
	local MOD = {}
	modTable.__index = modTable
	setmetatable( MOD, modTable )

	self.UniqueIDNum = self.UniqueIDNum + 1
	MOD.UniqueID = self.UniqueIDNum

	function MOD:GetBomb()

		return entity

	end

	function MOD:IsSerial()

		return self.TechName == "serial"

	end
	MOD:NetworkVar( "Int", "Position" )

	MOD:SetPosition( self:GetRandomDecorPosition() )

	self:SetNWString( MOD.UniqueID .. "_DType", MOD.TechName )
	self:SetModuleCount( self:GetModuleCount() + 1 )

	self.Decorations[ MOD.UniqueID ] = MOD

	MOD:OnStart()

end

function ENT:CreateDecorations()

	self:KillDecorations()
	self.Decorations = {}

	local entity = self
	self:AddDecoration( "serial" )

	local limit = 0
	local i = 0
	while i < math.random( 5,18 ) and limit < 999 do

		limit = limit + 1
		i = i + 1
		local v, k = table.Random( self.DecorationTables )
		if k == "serial" or !v.Enabled then i = i - 1 continue end

		if v.Rarity and math.random( 1, v.Rarity ) == 1 or !v.Rarity then
			self:AddDecoration( k )
		else
			i = i - 1
		end

	end

end

function ENT:KillDecorations()

	for k,v in pairs( self.Decorations ) do
		v:OnEnd()
		self.Decorations[k] = nil
	end

end






