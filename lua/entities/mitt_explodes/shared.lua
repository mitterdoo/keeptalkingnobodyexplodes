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

include( "sh_modloader.lua" )
include( "sh_decloader.lua" )
include( "sh_helper.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable		= true
ENT.AdminSpawnable  = true
ENT.PrintName		= "Keep Talking and Nobody Explodes"
ENT.Category 		= "mitterdoo"
ENT.Model			= "models/hunter/blocks/cube05x075x025.mdl"

ENT.SegmentSpacing	= 11.883117675781
ENT.ModuleSize		= 128


/*

	below is a method of utilizing 'sleep' functions. this is how you'd call it:

	self:NewWaitCoroutine( function()
		print( "Hello" )
		sleep( 2 )
		print( "World!" )
		sleep(2)
		local i = 0
		while true do
			i = i + 1
			print( i )
			sleep(1)
		end
	end )
	you can pass varargs into the function. very useful for the morse code module

*/
function ENT:NewWaitCoroutine( func, ... )
	

	local args = {...}
	local wtime
	local function sleep( time )
		wtime = time
		coroutine.yield()
	end
	local env = getfenv( func )
	env.sleep = sleep
	setfenv( func, env )
	
	local sequence = coroutine.create( function()
		func( unpack(args) )
	end )
		
	
	local loopProtect = 99999
	local function loop()
		
		loopProtect = loopProtect - 1
		if loopProtect < 0 then
			error( "STACK OVERFLOW" )
		end
		
		local co, ret = coroutine.resume( sequence )
		local status = coroutine.status( sequence )
		if status == "suspended" and wtime and co then
			timer.Simple( wtime, function()
				wtime = nil
				loop()
			end )
			return
		elseif status == "dead" and co == true and ret == nil then
			-- done
		else
			error( "something went wrong with a coroutine" )
		end
		
	end
	loop()
	
end


function ENT:SetupDataTables()

	self:NetworkVar( "String",	0, "Serial" )
	self:NetworkVar( "Int",		0, "Strikes" )
	self:NetworkVar( "Int",		1, "ModuleCount" )
	self:NetworkVar( "Int",		2, "LastStrikeModule" )
	self:NetworkVar( "Bool", 	0, "Hardcore" )
	self:NetworkVar( "Bool", 	1, "Paused" )
	self:NetworkVar( "Bool", 	2, "Defused" )
	self:NetworkVar( "Float",	0, "StartTime" )
	self:NetworkVar( "Float",	1, "EndTime" )
	self:NetworkVar( "Float",	2, "MaxTime")
	self:NetworkVar( "Float",	3, "PausedTime" )
	self:NetworkVar( "Float",	4, "LastStrike" )
	self:NetworkVar( "Float",	4, "DefuseTime" )

end



function ENT:SharedInitialize()

	self.Modules = {}
	self.Decorations = {}

	if SERVER then
		self:CreateModules()
		self:CreateDecorations()
	end

end
function ENT:OnRemoved()

	self:KillModules()
	self:KillDecorations()

end
function ENT:SharedThink()

	if !self.Initialized then
		self.Initialized = true
		self:SharedInitialize()
	end
	for k, v in pairs( self.Modules ) do

		if isfunction( v.Think ) then
			v:Think()
		end

	end
	math.randomseed( tonumber( util.CRC( os.time() + CurTime() % 1 ) ) ) // for the paranoid

end

function ENT:GetModule( pos )

	for k,v in pairs( self.Modules ) do
		if v:GetPosition() == pos or v.TechName == pos then
			return v
		end
	end

end
function ENT:GetModuleByID( id )

	for k,v in pairs( self.Modules ) do
		if v.UniqueID == id then
			return v
		end
	end

end
