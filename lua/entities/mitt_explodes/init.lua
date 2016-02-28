/*
The MIT License (MIT)

Copyright (c) 2015 mitterdoo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_modloader.lua")
AddCSLuaFile("sh_decloader.lua")
AddCSLuaFile("sh_networking.lua")
AddCSLuaFile("sh_helper.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_buttons.lua")
include("shared.lua")
util.AddNetworkString( "ktne_network" )
util.AddNetworkString( "ktne_prompt" )


for k,v in pairs( file.Find( "sound/" .. ENT.SndPath .. "/*", "GAME" ) ) do
	if not v:find"%.bz2$" then 
		resource.AddFile( "sound/" .. ENT.SndPath .. "/" .. v )
	end
end

ENT.DefaultTime = 60 * 5
ENT.Create_Modules = 1
ENT.Create_Difficulty = 1



ENT.TimerSpeeds = {
	1,
	0.811,
	0.66
}

local function SpawnEnt( ply, tr, time, mods, diff )

	if not tr.Hit then return end
	local pos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("mitt_explodes")
	ent:SetPos(pos)
	ent.DefaultTime = math.max( 30, time )
	ent.Create_Modules = math.max( 3, mods )
	ent.Create_Difficulty = math.max( 1, diff )
	local ang = ent:GetAngles()
	ang:RotateAroundAxis( ang:Right(), 90 )
	ent:SetAngles( ang )
	ent:Spawn()
	ent:Activate()

	if ply.AddCleanup then
		ply:AddCleanup( "mitt_explodes" )
		undo.Create( "#mitt_explodes" )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
		undo.Finish()
	end

end

function ENT:SpawnFunction(ply,tr)

	net.Start( "ktne_prompt" )
	net.Send( ply )

end

net.Receive( "ktne_prompt", function( len,ply )

	local time = net.ReadUInt( 32 )
	local mods = net.ReadUInt( 32 )
	local diff = net.ReadUInt( 32 )
	SpawnEnt( ply, util.TraceLine( util.GetPlayerTrace(ply) ),time, mods, diff )

end )



function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject() if (phys:IsValid()) then phys:Wake() end

	self:GenerateSerial()
	self:SetPaused(true)
	self:SetDefaultTime( self.DefaultTime )
	self:SetPausedTime( self:GetDefaultTime() )

end




function ENT:Think()

	self:SharedThink()

	if self:GetTime(true) == 0 then
		self:BlowUp()
	end
	if CurTime() - self:GetCreationTime() >= 2 and !self.StartedTimer and !self.DEBUG then
		self.StartedTimer = true
		self:StartTimer()
	end



	self:NextThink( CurTime() )
	return true

end

net.Receive( "ktne_network", function( len, ply )

	// PLAYER CHECK
	local ent = net.ReadEntity()
	if !IsValid( ent ) or ent:GetClass() != "mitt_explodes" then return end
	if ent:GetPaused() and !ent.DEBUG then return end
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
function ENT:GetRandomModulePosition( forceTimer, stack )

	stack = stack and stack + 1 or 1
	if stack > 999 then
		error( "STACK OVERFLOW" )
	end
	local used = self:GetUsedModuleSpaces()
	assert( table.Count(used) < 12, "max number of modules hit!" )

	local frontCount = 0
	for i = 1, 6 do
		if used[i] then
			frontCount = frontCount + 1
		end
	end
	local picked = math.random( frontCount < 6 and 1 or 7, frontCount < 6 and 6 or 12 )
	if forceTimer then
		picked = math.random( 1, 6 )
		if frontCount == 6 then return false end
	end
	if used[picked] then
		return self:GetRandomModulePosition( forceTimer, stack)
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
	assert( table.Count(used) < 20, "max number of decorations hit!" )

	local picked
	while true do
		picked = math.random( 1, 20 )
		if !used[picked] then return picked end
	end

end


function ENT:AddModule( name, pos )

	local modTable = self.ModuleTables[ name ]
	assert( modTable, "module name invalid!" )

	local entity = self
	local MOD = {}
	local oldIndex = modTable.__index
	modTable.__index = modTable
	setmetatable( MOD, modTable )
	local newPos = self:GetRandomModulePosition( MOD.ForceWithTimer )
	if !newPos then
		MOD = nil
		modTable.__index = oldIndex
		return false
	end

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

		if isfunction( self.OnDisarm ) then
			self:OnDisarm()
		end

	end

	MOD:NetworkVar( "Int", "Position" )
	MOD:NetworkVar( "Bool", "Disarmed" )
	if pos then
		MOD:SetPosition( pos )
	elseif name == "timer" then
		MOD:SetPosition( math.random( 1, 6 ) )
	else
		MOD:SetPosition( newPos )
	end
	self:SetNWString( MOD.UniqueID .. "__Type", MOD.TechName )
	self:SetModuleCount( self:GetModuleCount() + 1 )
	self.Modules[ MOD.UniqueID ] = MOD

	if isfunction( MOD.OnStart ) then
		MOD:OnStart()
	end
	return MOD

end

function ENT:CreateModules()

	self:KillModules()
	self.Modules = {}

	self:AddModule( "timer" )

	local limit = 0
	local rnd = self.Create_Modules
	local Diff = self.Create_Difficulty
	local i = 0
	while i < rnd and limit < 999 do

		limit = limit + 1
		i = i + 1
		local v, k = table.Random( self.ModuleTables )
		if k == "timer" or !v.Enabled then i = i - 1 continue end

		if ( v.Rarity and math.random( 1, v.Rarity ) == 1 or !v.Rarity ) and v.Difficulty <= Diff then
			local worked = self:AddModule( k )
			if !worked then
				i = i - 1
			end
		else
			i = i - 1
		end

	end

end

function ENT:KillModules()

	for k,v in pairs( self.Modules ) do
		if isfunction( v.OnEnd ) then
			v:OnEnd()
		end
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

	if isfunction( MOD.OnStart ) then
		MOD:OnStart()
	end
	return MOD

end

function ENT:CreateDecorations()

	self:KillDecorations()
	self.Decorations = {}

	local entity = self
	self:AddDecoration( "serial" )

	local limit = 0
	local i = 0
	local rnd = math.random( 2,18 )
	while i < rnd and limit < 999 do

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
		if isfunction( v.OnEnd ) then
			v:OnEnd()
		end
		self.Decorations[k] = nil
	end

end






