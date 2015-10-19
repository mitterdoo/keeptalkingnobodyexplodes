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

MOD.Name			= "Complicated Wires"
MOD.Difficulty		= 1
MOD.Needy			= false
MOD.Enabled			= true
MOD.ForceWithTimer	= false
MOD.HoverOutline	= 2
// MOD.Rarity		= 2

MOD.Enums = {
	RED = 2^0,
	BLUE = 2^1,
	WHITE = 2^2,
	STAR = 2^3,
	LED = 2^4,
	CUT = 2^5
}

function MOD:OnStart()

	for i = 1, 6 do
		self:NetworkVar( "Int", "Wire" .. i )
	end
	self:NetworkVar( "Int", "WireCount" )
	if SERVER then
		self:StartServer()
	end

end

function MOD:Think()

end

function MOD:OnDisarm()

end

function MOD:OnEnd()

end


function MOD:GetWire( wire, noTable, onlyEnums )

	local wires = self["GetWire" .. wire](self)
	if onlyEnums then return wires end
	if noTable then
		local red,blue,white,star,led,cut = false,false,false,false,false,false
		if wires >= self.Enums.CUT then
			wires = wires - self.Enums.CUT
			cut = true
		end
		if wires >= self.Enums.LED then
			wires = wires - self.Enums.LED
			led = true
		end
		if wires >= self.Enums.STAR then
			wires = wires - self.Enums.STAR
			star = true
		end
		if wires >= self.Enums.WHITE then
			wires = wires - self.Enums.WHITE
			white = true
		end
		if wires >= self.Enums.BLUE then
			wires = wires - self.Enums.BLUE
			blue = true
		end
		if wires >= self.Enums.RED then
			wires = wires - self.Enums.RED
			red = true
		end
		return red,blue,white,star,led,cut
	end
	local tab = {}
	for i = 5, 0, -1 do
		if wires >= 2^i then
			tab[ 2^i ] = true
			wires = wires - 2^i
		end
	end
	return tab

end


if SERVER then

	MOD.VennDiagram = {

		// what has to be true?
		// order: RED, BLUE, STAR, LED
		CUT = {
			{false,false,false,false},
			{true,false,true,false},
			{false,false,true,false},
		},
		NOCUT = {
			{false,false,false,true},
			{true,true,true,true},
			{false,true,true,false},
		},
		SERIAL = {
			{true,false,false,false},
			{false,true,false,false},
			{true,true,false,false},
			{true,true,false,true}
		},
		PORT = {
			{true,true,true,false},
			{false,true,false,true},
			{false,true,true,true}
		},
		BATTERY = {
			{true,false,false,true},
			{true,false,true,true},
			{false,false,true,true}
		}

	}


	function MOD:SetWire( wire, enums )

		self["SetWire" .. wire]( self, enums )

	end

	function MOD:CutWire( wire )

		self:SetWire( wire, self:GetWire( wire, nil, true ) + self.Enums.CUT )

	end

	function MOD:StartServer()

		local num = math.random( 3, 6 )
		self:SetWireCount( num )
		local pile = {1,2,3,4,5,6}
		local inds = {}
		for i = 1, num do
			local v,k = table.Random( pile )
			table.insert( inds, v )
			table.remove( pile, k )
		end
		pile = nil
		local CuttableWires = 0
		for k, ind in pairs( inds ) do
			local LoopBreak = 0
			local ShouldForce = math.random( 1, 6 - CuttableWires ) != 1 and CuttableWires == 0
			local colorsToUse = {
				{true,false,false},
				{true,true,false},
				{true,false,true},

				{false,true,true},
				{false,false,true},
				{false,true,false}
			}
			while true do
				LoopBreak = LoopBreak + 1
				if LoopBreak > 100000 then print( "OVERFLOW" ) break end

				local Picked = table.Random( colorsToUse )

				local Red = Picked[1] and self.Enums.RED or 0
				local Blue = Picked[2] and self.Enums.BLUE or 0
				local White = Picked[3] and self.Enums.WHITE or 0
				local Star = math.random( 0,1 ) == 1 and self.Enums.STAR or 0
				local LED = math.random( 0,1 ) == 1 and self.Enums.LED or 0
				if !self:ShouldCutWire( Red>0,Blue>0,Star>0,LED>0 ) and ShouldForce then
					continue
				end

				self:SetWire( ind, Red + Blue + White + Star + LED )
				if self:ShouldCutWire( Red>0, Blue>0, Star>0, LED>0 ) then
					CuttableWires = CuttableWires + 1
				end
				break
			end

		end
		self.CuttableWires = CuttableWires

	end

	function MOD:GetNet( wire )

		local Red,Blue,White,Star,LED = self:GetWire( wire,true )
		self:CutWire( wire )
		if self:ShouldCutWire( Red,Blue,Star,LED ) then
			self.CuttableWires = self.CuttableWires - 1
			if self.CuttableWires <= 0 then
				self:Disarm()
			end
		else
			self:GetBomb():Strike( self )
		end

	end


	function MOD:ShouldCutWire( Red,Blue,Star,LED )

		for Type, v in pairs( self.VennDiagram ) do
			if Type == "SERIAL" and !self:GetBomb():SerialIsEven() or
				Type == "PORT" and !self:GetBomb():DoesPortExist( "Parallel" ) or
				Type == "BATTERY" and self:GetBomb():GetBatteryCount()<2 then
				continue
			end
			for k, criteria in pairs( v ) do

				if criteria[1] == Red and criteria[2] == Blue and criteria[3] == Star and criteria[4] == LED then
					if Type == "NOCUT" then
						return false
					else
						return true
					end
				end

			end

		end

		return false

	end

else

	local C_RED = Color( 255,50,50 )
	local C_BLUE = Color( 50,50,255 )
	local C_WHITE = Color( 255,255,255 )
	local C_LIT = Color( 255,255,255 )
	local C_UNLIT = Color( 20,20,20 )
	local C_CONNECTOR = Color( 30,30,30 )
	local C_TEXT = Color( 255,255,255 )
	local C_PAPER = Color( 140, 110, 78 )
	local C_INVIS = Color( 0,0,0,0 )
	local starMat = Material( "keeptalkingnobodyexplodes/keypad/3-hollowstar.png" )

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


	function MOD:Cut( wire )
		self:SendNet( wire )
		return "keeptalkingnobodyexplodes/snip.wav"
	end

	function MOD:DrawWire( x, y, wire, Red,Blue,White,Star,LED,Cut )

		local ConnectorSize = 16
		local h = 104

		if wire then
			local FirstColor,SecondColor = color_black,color_black
			if Red and !Blue and !White then
				FirstColor = C_RED
				SecondColor = C_RED
			elseif Red and Blue and !White then
				FirstColor = C_RED
				SecondColor = C_BLUE
			elseif Red and !Blue and White then
				FirstColor = C_RED
				SecondColor = C_WHITE
			elseif !Red and Blue and !White then
				FirstColor = C_BLUE
				SecondColor = C_BLUE
			elseif !Red and Blue and White then
				FirstColor = C_BLUE
				SecondColor = C_WHITE
			elseif !Red and !Blue and White then
				FirstColor = C_WHITE
				SecondColor = C_WHITE
			end
			self:Button( x - 2, y - h/2, 4, h, 
				C_INVIS,
				nil,nil,nil,nil,nil,nil,
				Cut,false,
				self.Cut,
				self,
				wire
			)
			local Gap = Cut and 16 or 0
			surface.SetDrawColor( FirstColor )
			surface.DrawRect( x - 2, y - h/2, 2, h/2 - Gap )
			surface.DrawRect( x - 2, y + Gap, 2, h/2 - Gap )
			surface.SetDrawColor( SecondColor )
			surface.DrawRect( x, y - h/2, 2, h/2 - Gap )
			surface.DrawRect( x, y + Gap, 2, h/2 - Gap )
		end

		surface.SetDrawColor( C_CONNECTOR )
		surface.DrawRect( x - ConnectorSize/2, y - h/2 - ConnectorSize/2, ConnectorSize,ConnectorSize )
		surface.SetDrawColor( C_CONNECTOR )
		surface.DrawRect( x - ConnectorSize/2, y + h/2 - ConnectorSize/2, ConnectorSize,ConnectorSize )
		surface.SetDrawColor( C_PAPER )
		local bor = 2
		surface.DrawRect( x - ConnectorSize/2 + bor, y + h/2 - ConnectorSize/2 + bor, ConnectorSize - bor*2,ConnectorSize - bor*2 )

		circle( x, y - h/2, ConnectorSize/3, color_black )
		circle( x, y - h/2, ConnectorSize/3 - 1, LED and C_LIT or C_UNLIT )

		if Star then
			surface.SetMaterial( starMat )
			surface.SetDrawColor( 255,255,255 )
			surface.DrawTexturedRect( x - ConnectorSize/2, y + h/2 - ConnectorSize/2, ConnectorSize,ConnectorSize )
		end



	end

	function MOD:Draw( w, h )

		local Spacing = 17
		local wire = 0
		for i = -3, 3 do
			if i == 0 then continue end
			i = i < 0 and i + 0.5 or i - 0.5
			wire = wire + 1
			if self:GetWire( wire, nil, true ) == 0 then 
				self:DrawWire( w/2 + Spacing * i ,h/2 )
				continue
			end
			self:DrawWire( w/2 + Spacing * i ,h/2, wire, self:GetWire(wire,true) )
		end

	end

end


