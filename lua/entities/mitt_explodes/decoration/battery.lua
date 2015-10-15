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

MOD.Name			= "Battery"	// name of the decoration
MOD.Enabled			= true		// should this decoration be used in game
MOD.Rarity			= 3			// 1 in X chance this will appear

/*

*/


function MOD:OnStart() // called when the decoration is created

	self:NetworkVar( "String", "Type" )
	self:NetworkVar( "Int", "Count" )

	if SERVER then
		self:SetType( math.random( 0, 1 ) == 1 and "AA" or "D" )
		self:SetCount( self:GetType() == "AA" and 2 or 1 )
	end

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnEnd() // called when the module is removed

end

local C_BATTERY = Color( 196, 67, 61 )
local C_GOLD = Color( 238, 172, 33 )
local C_FRAME = Color( 30, 71, 128 )
local C_METAL = Color( 150,150,150 )
local C_BLACK = Color( 0, 0, 0 )
local C_IND = Color( 0,255,0 )

local sw, sh = 76, 44 // socket size
local Border = 4
local bw = 60 // battery height
local Strip = 4 // golden strip width
local mw, mh = 2, 12 // metal connector size
local iw, ih = 2, 20 // green indicator size

function MOD:Draw( w, h )

	draw.RoundedBox( 4, w/2 - sw/2, h/2 - sh/2, sw, sh, C_FRAME )
	draw.RoundedBox( 4, w/2 - sw/2 + Border, h/2 - sh/2 + Border, sw - Border*2, sh - Border*2, C_BLACK )
	surface.SetDrawColor( C_IND )
	surface.DrawRect( w / 2 + sw / 2 - Border/2 - iw/2, h/2 - ih/2, iw, ih )

	local count = self:GetCount()

	local h2 = 30 / count - ( count - 1 )

	for i = 1, count do

		local split = 0
		if count > 1 then
			split = i == 1 and -8 or 8
		end
		surface.SetDrawColor( C_BATTERY )
		surface.DrawRect( w / 2 - bw/2, h / 2 + split - h2 / 2, bw, h2 )
		surface.SetDrawColor( C_GOLD )
		surface.DrawRect( w / 2 - bw/2, h / 2 + split - h2 / 2, Strip, h2 )
		surface.DrawRect( w / 2 + bw/2 - Strip, h / 2 + split - h2 / 2, Strip, h2 )
		surface.DrawRect( w / 2 + bw/2 - Strip*2 - 1, h / 2 + split - h2 / 2, Strip, h2 )

		surface.SetDrawColor( C_METAL )
		surface.DrawRect( w / 2 - bw/2 - mw, h / 2 + split - mh / 2, mw, mh )
		surface.DrawRect( w / 2 + bw/2, h / 2 + split - mh / 2, mw, mh )

	end

end

