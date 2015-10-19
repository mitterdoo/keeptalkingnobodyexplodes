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

/*

	tl;dr?
	all i'd really worry about is ENT:Button and ENT:CircleButton

	ENT:Button( float x, float y, float w, float h, Color col, [string text], [string font], [string textCol], [int roundedCorners], [float borderSize], [Color borderColor], bool locked, bool canHold, function func, [module obj], ... )
	ENT:CircleButton( float x, float y, float radius, [int vertices], Color col, [string text], [string font], [string textCol], [float borderSize], [Color borderColor], bool locked, bool canHold, function func, [module obj], ... )
		text is optional
		roundedCorners is the corner size like draw.RoundedBox, pass nothing or 0
		canHold determines if you can hold down the button and call the press function again with an additional argument
		func is called when the button is pressed. if holding is disabled on the button, the args are
			function( obj, ... )
		if it is enabled, they are
			function( pressed, obj, ... )
		obj is used for the 'self' argument if you're calling a function on the module defined as MOD:Function.

*/

local C_ORANGE = Color( 0xFF, 0x77, 0x00 )
local C_FLASHING = Color( 255,0,0 )
function ENT:SetupButtons()

	if self.ButtonsPushed then
		error( "WHOA THERE BUCKO THIS IS NOT THE RIGHT PLACE TO CALL THIS" )
	end
	self.ButtonsSetUp = true
	self.ButtonsPushed = false


	function self:CircleButton( x, y, rad, vert, col, text, font, tcol, bsize, bcol, lock, canHold, func, obj, ... )

		local isOn = false
		if !lock then
			local poly = {}
			local vert = vert or 16
			table.insert( poly, { x = x, y = y, u = 0.5, v = 0.5 } )
			for i = 0, vert do
				local a = math.rad( ( i / vert ) * -360 )
				table.insert( poly, { x = x + math.sin( a ) * rad, y = y + math.cos( a ) * rad, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
			end

			local a = math.rad( 0 ) -- This is need for non absolute segment counts
			table.insert( poly, { x = x + math.sin( a ) * rad, y = y + math.cos( a ) * rad, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

			isOn = self:MouseInPoly( poly )
		end
		if isOn then
			self.CanHoldButton = canHold
			self.PressedButton = func
			self.ButtonArgsObj = obj
			self.ButtonArgs = { ... }
			self.OnButton = true

			local outline = self.ActiveModule and self.ActiveModule.HoverOutline or 2

			C_ORANGE.a = 255 - ( RealTime() % 0.7 / 0.7 ) * 60
			C_FLASHING.a = 200 + math.sin( RealTime() * math.pi * 2 * 4 ) * 50

			self:Circle( x, y, rad + outline * 2, canHold and self.IsMouseDown and C_FLASHING or C_ORANGE, vert )

		end
		if isOn and mouseDown then
			col.r = col.r * 0.9
			col.g = col.g * 0.9
			col.b = col.b * 0.9
		end

		self:Circle( x, y, rad, col, vert, bsize or 0, bcol or Color( 0, 0, 0 ) )
		if text then
			surface.SetFont( font or "default" )
			local w2, h2 = surface.GetTextSize( text, font or "default" )
			draw.DrawText( text, font or "default", x, y - h2 / 2, tcol or Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end

	end


	local function normalize2D( x, y )
		return x / math.sqrt( x^2+y^2 ), y / math.sqrt( x^2+y^2 )
	end
	local function drawPoly( poly, col, scale, offset )

		if scale and scale != 1 or offset then
			poly = table.Copy( poly )
			scale = scale or 1
			offset = offset or 0
			local cx, cy = 0,0
			local count = 0
			for k,v in pairs( poly ) do
				cx = cx + v.x
				cy = cy + v.y
				count = count + 1
			end
			cx = cx/count
			cy = cy/count
			for k, v in pairs( poly ) do
				local x, y = v.x, v.y
				local nx, ny = normalize2D( x - cx, y - cy )
				local dist = math.Distance( x, y, cx, cy )
				v.x = cx + nx * ( dist+offset) * scale
				v.y = cy + ny * ( dist+offset) * scale
			end

		end
		surface.SetDrawColor( col )
		draw.NoTexture()
		surface.DrawPoly( poly )

	end


	function self:PolyButton( poly, col, lock, canHold, func, obj, ... )

		local isOn = false
		if !lock then

			isOn = self:MouseInPoly( poly )
		end
		if isOn then
			self.CanHoldButton = canHold
			self.PressedButton = func
			self.ButtonArgsObj = obj
			self.ButtonArgs = { ... }
			self.OnButton = true

			local outline = self.ActiveModule and self.ActiveModule.HoverOutline or 2

			C_ORANGE.a = 255 - ( RealTime() % 0.7 / 0.7 ) * 60
			C_FLASHING.a = 200 + math.sin( RealTime() * math.pi * 2 * 4 ) * 50

			drawPoly( poly, canHold and self.IsMouseDown and C_FLASHING or C_ORANGE, 1, outline )
			//self:Circle( x, y, rad + outline * 2, canHold and self.IsMouseDown and C_FLASHING or C_ORANGE, vert )

		end
		if isOn and mouseDown then
			col.r = col.r * 0.9
			col.g = col.g * 0.9
			col.b = col.b * 0.9
		end
		drawPoly( poly, col )
		//self:Circle( x, y, rad, col, vert, bsize or 0, bcol or Color( 0, 0, 0 ) )

	end

	function self:Button( x, y, w, h, col, text, font, tcol, corner, bsize, bcol, lock, canHold, func, obj, ... )

		local isOn = false
		if !lock then
			isOn = self:MouseOn( x, y, w, h )
		end
		if isOn then
			self.CanHoldButton = canHold
			self.PressedButton = func
			self.ButtonArgsObj = obj
			self.ButtonArgs = { ... }
			self.OnButton = true

			local outline = self.ActiveModule and self.ActiveModule.HoverOutline or 4
			C_ORANGE.a = 255 - ( RealTime() % 0.7 / 0.7 ) * 60
			C_FLASHING.a = 200 + math.sin( RealTime() * math.pi * 2 * 4 ) * 50
			self:Box( corner or 0, x - outline, y - outline, w + outline * 2, h + outline * 2, canHold and self.IsMouseDown and C_FLASHING or C_ORANGE, nil, nil)

		end
		if isOn and mouseDown then
			col.r = col.r * 0.9
			col.g = col.g * 0.9
			col.b = col.b * 0.9
		end
		self:Box( corner or 0, x, y, w, h, col, bsize or 0, bcol or Color( 0, 0, 0 ) )
		if text then
			surface.SetFont( font or "default" )
			local w2, h2 = surface.GetTextSize( text, font or "default" )
			draw.DrawText( text, font or "default", x + w / 2, y + h / 2 - h2 / 2, tcol or Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
	end

	function self:MouseOn( x, y, w, h )

		local mx, my, visible, mouseDown = self.mx, self.my, self.mv, LocalPlayer():KeyDown( IN_USE )
		if self.MouseModule != self.ButtonModule then return false end

		local mod = self:GetModule( self.MouseModule )

		if mod and mod:GetDisarmed() then return false end
		if !visible then return false end
		if !h and w then // circle args
			return math.Distance( x, y, mx, my ) <= w
		end
		local x2, y2 = x + w, y + h
		return mx > x and mx < x2 and my > y and my < y2

	end

	function self:MouseInPoly( verts, mx, my )

		local mx, my, visible, mouseDown = self.mx, self.my, self.mv, LocalPlayer():KeyDown( IN_USE )
		if self.MouseModule != self.ButtonModule then return false end

		local mod = self:GetModule( self.MouseModule )

		if mod and mod:GetDisarmed() then return false end
		if !visible then return false end

		local nvert = #verts
		local j, c = nvert,false
		for i = 1, nvert do
			if (
				(
					( verts[i].y > my ) != ( verts[j].y > my)
				) && (
					mx < ( verts[j].x - verts[i].x ) * ( my - verts[i].y ) / ( verts[j].y - verts[i].y ) + verts[i].x )
				) then
				c = !c
			end
			j = i
		end
		return c

	end

	local function circle( x, y, radius, col, seg )
		seg = seg or 16
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is need for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.SetDrawColor( col )
		draw.NoTexture()
		surface.DrawPoly( cir )
	end
	function self:Circle( x, y, radius, col, seg, bsize, bcol )

		bsize = bsize or 0
		if bsize > 0 then
			circle( x, y, radius, bcol or Color( 0, 0, 0 ), seg )
		end
		circle( x, y, radius - bsize, col, seg )

	end
	function self:Box( corner, x, y, wide, high, col, thick, bcol )
		thick = thick or 0
		if corner > 0 then
			if thick > 0 then
				draw.RoundedBox( corner, x, y, wide, high, bcol or Color( 0, 0, 0 ) )
			end
			draw.RoundedBox( corner, x + thick, y + thick, wide - thick * 2, high - thick * 2, col )
		else
			if thick > 0 then
				surface.SetDrawColor( bcol or Color( 0, 0, 0 ) )
				surface.DrawRect( x, y, wide, high )
			end
			surface.SetDrawColor( col )
			surface.DrawRect( x + thick, y + thick, wide - thick * 2, high - thick * 2 )
		end
	end
	function self:OutText( text, font, x, y, col, ax, ay, thick, bcol )

		for x2 = x - thick, x + thick do
			for y2 = y - thick, y + thick do
				if x2 == x and y2 == y then continue end
				draw.DrawText( text, font, x2, y2, bcol or Color( 0, 0, 0 ), ax, ay )
			end
		end
		draw.DrawText( text, font, x, y, col, ax, ay )

	end
	function self:OnMousePressed( pressed )
		if self.PressedButton and self.MouseModule then
			local mod = self:GetModule( self.MouseModule )
			if !mod then return end
			if mod:GetDisarmed() then return end
			local sound = "keeptalkingnobodyexplodes/press-in.wav"

			local override, override2

			local args = {}

			if self.ButtonArgsObj then
				table.insert( args, self.ButtonArgsObj )
			end
			if self.CanHoldButton then
				table.insert( args, pressed )
			end
			table.Add( args, self.ButtonArgs )

			override, override2 = self.PressedButton( unpack( args ) )

			if !pressed then
				self.ButtonArgs = nil
				self.ButtonArgsObj = nil
				self.PressedButton = nil
				self.OnButton = false

				sound = "keeptalkingnobodyexplodes/press-release.wav"
				if override2 == false then
					sound = ""
				elseif type( override2 ) == "string" then
					sound = override2
				end
				if sound != "" then
					self:EmitSound( sound, 100, 100 + math.random( -4, 4 ) )
				end
				return
			end
			if override == false then
				sound = ""
			elseif type( override ) == "string" then
				sound = override
			end
			
			if sound != "" then
				self:EmitSound( sound, 100, 100 + math.random( -5, 5 ) )
			end
			if !self.CanHoldButton then
				self.ButtonArgs = nil
				self.ButtonArgsObj = nil
				self.PressedButton = nil
				self.OnButton = false
			end
		end
	end

end

hook.Add( "PlayerBindPress", "ktne_screen", function( ply, bind, pressed )

	if bind == "+use" and !ply:KeyDown( IN_ATTACK ) and ply == LocalPlayer() then
		local down = bin
		for k, v in pairs( ents.FindByClass( "mitt_explodes" ) ) do
			if v.mv then
				v.IsMouseDown = true
				v:OnMousePressed(true)
			end
		end
	end

end )

function ENT:PushButtons( mod )

	if self.ButtonsPushed then
		ErrorNoHalt( "WARNING: Buttons pushed before popped. Popping..." )
		self:PopButtons()
	end
	if !self.ButtonsSetUp then
		error( "buttons are not set up!" )
	end
	self.ActiveModule = mod
	self.ButtonModule = mod:GetPosition()
	self.ButtonsPushed = true
	self.mx, self.my, self.mv, self.MouseModule = self:GetMouse()
	self.OnButton = false

end

function ENT:PopButtons( hideCursor )

	if !self.ButtonsPushed then
		error( "attempt to pop buttons when not pushed!" )
	end
	local mx, my, visible, mod, mouseDown = self.mx, self.my, self.mv, self.MouseModule, LocalPlayer():KeyDown( IN_USE )
	if !self.OnButton then

		if self.CanHoldButton and self.IsMouseDown then // moved off button so release it
			self:OnMousePressed( false )
			self.IsMouseDown = false
		end

		self.CanHoldButton = nil
		self.ButtonArgs = nil
		self.PressedButton = nil
		self.ButtonArgsObj = nil
	elseif self.CanHoldButton then
		if !mouseDown and self.IsMouseDown then
			self.IsMouseDown = false // mouse released
			self:OnMousePressed( false )
		end
	end

	self.ActiveModule = nil
	self.ButtonsPushed = false

	self.ButtonModule = nil

end


local function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)

	local d = vX:DotProduct(vp)

	if (d <= 0.0) then return end

	local vt = vOrigin - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end

	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end

	return Vector(u / d, v / d, 0)
end

function ENT:MouseRayInteresct( pos, ang, size, eyepos, eyeang )
	local plane = pos + ( ang:Forward() * ( size / 2 ) ) + ( ang:Right() * ( size / -2 ) )

	local x = ( ang:Forward() * -( size ) )
	local y = ( ang:Right() * ( size ) )

	return RayQuadIntersect( eyepos, eyeang, plane, x, y )
end

function ENT:GetCursorPos( pos, ang, eyepos, eyeang )

	local size = self.ActiveModule and self.ActiveModule.ScreenSize or self.ModuleSize
	local scale = self.SegmentSpacing / size

	local uv = self:MouseRayInteresct( pos, ang, size, eyepos, eyeang )
	
	if uv then
		local x,y = (( 0.5 - uv.x ) * size), (( uv.y - 0.5 ) * size)
		x = x / scale
		y = y / scale

		if x < 0 or y < 0 or x > size or y > size then
			return
		end
		return (x), (y)
	end
end

function ENT:GetMouse()

	if self:GetPaused() and !self.DEBUG then return 0,0,false,0 end
	local eyepos = EyePos()
	local eyeang = EyeAngles():Forward()
	local norm = eyepos - self:GetPos()
	norm:Normalize()
	local FacingFront = self:GetUp():Dot( norm ) > 0
	local size = self.ActiveModule and self.ActiveModule.ScreenSize or self.ModuleSize
	local scale = self.SegmentSpacing / size

	for i = 1, 12 do
		if !self:GetModule( i ) then continue end
		if self:GetModule(i):GetDisarmed() then continue end

		local pos = self:GetModulePos( i )
		local ang = self:GetModuleAngles( i )

		local norm = pos - eyepos
		norm:Normalize()
		if ang:Up():Dot( norm ) > 0 then continue end

		pos = pos - ang:Forward() * size/2*scale - ang:Right() * size/2*scale
		local x, y = self:GetCursorPos( pos, ang, eyepos, eyeang )
		if x and y then
			return x, y, true, i
		end
	end

	return 0,0,false,0

end


