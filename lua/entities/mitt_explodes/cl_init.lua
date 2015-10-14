include("shared.lua")
include("cl_buttons.lua")

function ENT:Initialize()

	self.Modules = {}
	self.DisarmedModules = {}

	self:SetupButtons()

end

function ENT:AddModuleClient( name, id )

	local tab = self.ModuleTables[ name ]
	if !tab then
		error( "Tried to create a nonexistant module '" .. name .. "'!" )
	end

	local entity = self
	local MOD = {}
	tab.__index = tab
	setmetatable( MOD, tab )

	MOD.UniqueID = id

	function MOD:GetBomb()

		return entity

	end

	function MOD:IsTimer()

		return self.TechName == "timer"

	end
	function MOD:SendNet( ... )

		net.Start( "ktne_network" )
			net.WriteEntity( self:GetBomb() )
			net.WriteInt( self.UniqueID, 32 )
			local args = {...}
			local count = #args
			net.WriteInt( count, 32 )
			for i = 1, count do
				net.WriteInt( args[i], 32 )
			end
		net.SendToServer()

	end

	MOD:NetworkVar( "Int", "Position" )
	MOD:NetworkVar( "Bool", "Disarmed" )
	self.Modules[ id ] = MOD
	MOD:OnStart()

end

function ENT:AddDecorClient( name, id )

	local tab = self.DecorationTables[ name ]
	if !tab then
		error( "Tried to create a nonexistant module '" .. name .. "'!" )
	end

	local entity = self
	local MOD = {}
	tab.__index = tab
	setmetatable( MOD, tab )
	MOD.UniqueID = id

	function MOD:GetBomb()

		return entity

	end

	function MOD:IsSerial()

		return self.TechName == "serial"

	end
	MOD:NetworkVar( "Int", "Position" )

	self.Decorations[ MOD.UniqueID ] = MOD

	MOD:OnStart()

end

function ENT:Think()

	self:SharedThink()

	for i = 1, self:GetModuleCount() do

		if !self.Modules[i] and self:GetNWString( i .. "__Type" ) != "" then
			// module doesn't exist yet
			self:AddModuleClient( self:GetNWString( i .. "__Type" ), i )
			self.DisarmedModules[ i ] = self:GetNWString( i .. "_Disarmed" )
		elseif !self.Decorations[ i ] and self:GetNWString( i .. "_DType" ) != "" then
			// decor doesn't exist yet
			self:AddDecorClient( self:GetNWString( i .. "_DType" ), i )
		end

	end

	for k, v in pairs( self.Modules ) do
		if v:GetDisarmed() == true and self.DisarmedModules[ v.UniqueID ] == false then
			self.DisarmedModules[ v.UniqueID ] = true
			self.PressedButtons = nil
			self.OnButton = false
			self.ButtonArgs = nil
			v:OnDisarmed()
		end
	end

end
/*

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), -90 )

*/
function ENT:GetModulePos( pos )

	local spacing = self.SegmentSpacing
	
	local x, y = spacing * 0.5, spacing * 1
	x = x - ( ( pos <= 3 and pos <= 6 or pos <= 9 and pos > 6 ) and 0 or spacing )
	y = y - ( ( pos - 1 ) % 3 * spacing )

	if pos > 6 then
		y = -y
	end

	local offset = Vector( x, y, 6.2 * ( pos <= 6 and 1 or -1 ) )
	return self:LocalToWorld( offset )

end

function ENT:GetModuleAngles( pos )

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), -90 )

	if pos > 6 then
		ang:RotateAroundAxis( ang:Right(), 180 )
	end

	return ang

end

function ENT:Right()

	return self:GetRight()

end
function ENT:Up()

	return self:GetForward()

end
function ENT:Forward()

	return self:GetUp()

end

function ENT:GetDecorPos( ind )

	local spacing = self.SegmentSpacing
	local pos = self:GetPos()
	if ind <= 12 then // top or bottom

		pos = pos + self:Up() * ( ind <= 6 and 1 or -1 ) * spacing
		pos = pos + self:Forward() * ( ( ind - 1 ) % 6 <= 2 and -0.25 or 0.25 ) * spacing
		pos = pos + self:Right() * ( ( ind - 1 ) % 3 - 1 ) * spacing

	else

		pos = pos + self:Up() * ( ( ind - 1 ) % 2 == 0 and -0.5 or 0.5 ) * spacing
		pos = pos + self:Right() * ( ind <= 16 and -1.5 or 1.5 ) * spacing
		pos = pos + self:Forward() * ( ( ind - 1 ) % 4 <= 1 and -0.25 or 0.25 ) * spacing

	end
	return pos

end

function ENT:GetDecorAngles( ind )

	local ang = self:GetAngles()

	if ind <= 12 then
		if ind <= 6 then
			ang:RotateAroundAxis( self:Right(), -90 )
		else
			ang:RotateAroundAxis( self:Right(), 90 )
		end
		ang:RotateAroundAxis( self:Up(), 90 )
	elseif ind <= 16 then
		ang:RotateAroundAxis( self:Up(), -90 )
		ang:RotateAroundAxis( self:Right(), 180 )
	else
		ang:RotateAroundAxis( self:Up(), 90 )
	end

	return ang

end

local c_black = Color( 0,0,0 )
local c_white = Color( 160,160,160 )
local c_gray = Color( 100,100,100 )
local c_green = Color( 0,255,0 )
local c_red = Color( 255,0,0 )

function ENT:DrawModule( mod, x, y, visible )

	if !mod then return end
	local position = mod:GetPosition()

	local size = self.ModuleSize
	local scale = self.SegmentSpacing / size

	local pos = self:GetModulePos( position )
	local ang = self:GetModuleAngles( position )

	local norm = pos - EyePos()
	norm:Normalize()
	if ang:Up():Dot( norm ) > 0 then return end

	pos = pos - ang:Forward() * size/2*scale - ang:Right() * size/2*scale
	cam.Start3D2D( pos, ang, scale )

		/*surface.SetDrawColor( c_black )
		surface.DrawRect( 0, 0, size, size )

		surface.SetDrawColor( position % 2 == 1 and c_white or c_gray )
		surface.DrawRect( 4, 4, size-8, size-8 )
		*/

		render.ClearStencil()
		render.SetStencilEnable( true )

		render.SetStencilWriteMask( 1 )
		render.SetStencilTestMask( 1 )
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_REPLACE )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )


		render.OverrideColorWriteEnable( true, false )

		surface.SetDrawColor( c_black )
		surface.DrawRect( 4, 4, size-8, size-8 )
		render.OverrideColorWriteEnable( false, false )

		render.SetStencilCompareFunction( STENCIL_EQUAL )

		mod:Draw( size, size, x, y, visible )

		render.SetStencilEnable(false)

		local col = c_black
		if mod:GetDisarmed() then
			col = self:GetDefused() and RealTime() % 0.25 > 0.125 and CurTime() - self:GetDefuseTime() < 3 and c_black or c_green
		elseif mod:GetPosition() == self:GetLastStrikeModule() and CurTime() - self:GetLastStrike() < 0.25 then
			col = c_red
		end

		surface.SetDrawColor( col )
		surface.DrawRect( 0,0,4,size )
		surface.DrawRect( 0,0,size,4 )
		surface.DrawRect( size-4, 0, 4, size )
		surface.DrawRect( 0, size-4, size, 4 )

	cam.End3D2D()

end

function ENT:DrawDecor( dec )

	local position = dec:GetPosition()

	local ang = self:GetDecorAngles( position )
	local size = self.ModuleSize
	local scale = self.SegmentSpacing / size

	local pos = self:GetDecorPos( position )
	local ang = self:GetDecorAngles( position )

	local norm = pos - EyePos()
	norm:Normalize()
	if ang:Up():Dot( norm ) > 0 then return end

	pos = pos - ang:Forward() * size/2*scale - ang:Right() * size/4*scale

	cam.Start3D2D( pos, ang, scale )

		dec:Draw( size, size / 2 )

	cam.End3D2D()

end

function ENT:Draw()

	self:DrawModel()

	debugoverlay.Axis( self:GetDecorPos( self.Decor or 1 ), self:GetDecorAngles( self.Decor or 1 ), self.SegmentSpacing/2, 0.1, false )

	local x, y, visible, mod = self:GetMouse()

	for k, v in pairs( self.Modules ) do
		if mod == v:GetPosition() then
			self:PushButtons( v:GetPosition() )
		end
		self:DrawModule( v, x, y, mod == v:GetPosition() )
		if mod == v:GetPosition() then
			self:PopButtons()
		end
	end

	if mod == 0 and self.IsMouseDown then
		if self.CanHoldButton and self.IsMouseDown then // moved off button so release it
			self:OnMousePressed( false )
		end

		self.CanHoldButton = nil
		self.ButtonArgs = nil
		self.PressedButton = nil
		self.ButtonArgsObj = nil
		self.IsMouseDown = nil
	end

	for k,v in pairs( self.Decorations ) do
		self:DrawDecor( v )
	end

end


