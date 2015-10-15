/*
The MIT License (MIT)

Copyright (c) 2015 mitterdoo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
*/
MOD.Name			= "Timer"	// name of the module
MOD.Difficulty		= 1				// difficulty of the module
MOD.Needy			= false			// is a needy module
MOD.Enabled			= true			// should this module be used in game
MOD.ForceWithTimer	= false			// if this module requires the timer in view, make this true (e.g. button)
MOD.NotRequired		= true

/*

	functions you can call on modules:
	MOD:GetBomb()		returns the bomb entity
	MOD:IsTimer()		returns if the module is the timer

*/

MOD.Segments = {
	[0] = { 1,1,1,1,1,1,0 },
	[1] = { 0,1,1,0,0,0,0 },
	[2] = { 1,1,0,1,1,0,1 },
	[3] = { 1,1,1,1,0,0,1 },
	[4] = { 0,1,1,0,0,1,1 },
	[5] = { 1,0,1,1,0,1,1 },
	[6] = { 1,0,1,1,1,1,1 },
	[7] = { 1,1,1,0,0,0,0 },
	[8] = { 1,1,1,1,1,1,1 },
	[9] = { 1,1,1,1,0,1,1 },
}


function MOD:OnStart() // called when the module is created

	self.LastTick = 0

end

function MOD:Think() // called every think of the bomb entity


end

function MOD:OnDisarm() // called when the module is disarmed

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:IsSegmentLit( seg, num )

	return self.ShouldLight and self.Segments[ num ][seg] == 1

end

local c_on = Color( 255,0,0 )
local c_off = Color( 20,15,15 )
local SegNum = 0

MOD.SegW = 20
MOD.SegH = 60

function MOD:DrawNum( num, x, y )

	local width, height = self.SegW, self.SegH
	
	local vw, vh = 4, 24
	local hw, hh = 18, 6

	for i = -1, 1 do
		// 1 8 4
		local ox, oy = x, y + height/2 * i

		local seg = i == -1 and 1 or i == 0 and 7 or 4
		surface.SetDrawColor( self:IsSegmentLit( seg, num ) and c_on or c_off )
		surface.DrawRect( ox - hw/2, oy - hh/2, hw, hh )

		if i == 0 then continue end
		// 6 2
		local ox, oy = x + width / 2 * i, y - height / 4
		seg = i == -1 and 6 or 2
		surface.SetDrawColor( self:IsSegmentLit( seg, num ) and c_on or c_off )
		surface.DrawRect( ox - vw/2, oy - vh/2, vw, vh )

		// 5 3
		oy = y + height / 4
		seg = i == -1 and 5 or 3
		surface.SetDrawColor( self:IsSegmentLit( seg, num ) and c_on or c_off )
		surface.DrawRect( ox - vw/2, oy - vh/2, vw, vh )

	end

end
local Padding = 4
function MOD:Draw( w, h )

	local num = self:GetBomb():GetTime( true )
	local time = self:GetBomb():GetTime()
	local A = time:sub(1,1)
	local B = time:sub(2,2)
	local C = time:sub(4,4)
	local D = time:sub(5,5)
	A = tonumber( A )
	B = tonumber( B )
	C = tonumber( C )
	D = tonumber( D )

	local sw, sh = self.SegW, self.SegH + 16

	surface.SetDrawColor( 0,0,0 )
	local BGWidth = w * 0.92
	surface.DrawRect( w / 2 - BGWidth / 2,h / 2 - sh / 2 - Padding,BGWidth,sh + Padding*2 )

	self.ShouldLight = num > 0 or RealTime() % 0.25 > 0.125
	self:DrawNum( A, w / 20 * 3, h/2 )
	self:DrawNum( B, w / 20 * 7.5, h/2 )
	self:DrawNum( C, w / 20 * 12.5, h/2 )
	self:DrawNum( D, w / 20 * 17, h/2 )

	if !self:GetBomb():GetHardcore() then
		local y = h / 8
		surface.SetDrawColor( 0,0,0 )
		surface.DrawRect( w / 2 - 16, y - 8, 32, 16 )
		draw.SimpleText( "X X", "DebugFixed", w/2, y, c_off, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		local text = ""
		if self:GetBomb():GetStrikes() == 1 then
			text = "X  "
		elseif self:GetBomb():GetStrikes() == 2 then
			text = "X X"
		end
		if #text > 0 then
			draw.SimpleText( text, "DebugFixed", w/2, y, c_on, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

	// colon/period

	local colon = num % 1 > 0.5 or self:GetBomb():GetPaused()
	local period = colon
	if num < 60 then
		colon = false
		period = true and self.ShouldLight
	end

	local size = 4
	local y = h/2 - sh / 2 / 5 * 4
	surface.SetDrawColor( colon and c_on or c_off )
	surface.DrawRect( w / 2 - size/2, y - size/2, size, size )
	y = h/2 + sh / 2 / 5 * 4
	surface.SetDrawColor( period and c_on or c_off )
	surface.DrawRect( w / 2 - size/2, y - size/2, size, size )


	//if num > 0 or RealTime() % 0.25 > 0.125 then
		//draw.SimpleText( tostring( self:GetBomb():GetTime() ), "DermaLarge", w/2, h/2, Color( 255,0,0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	//end

end

function MOD:ScreenClicked( x, y )

end
