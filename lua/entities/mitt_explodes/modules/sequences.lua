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

MOD.Name			= "Wire Sequences"
MOD.Difficulty		= 3
MOD.Needy			= false
MOD.Enabled			= false
MOD.ForceWithTimer	= false
// MOD.Rarity		= 2

MOD.Enums = {
	RED = 1,
	BLUE = 2,
	BLACK = 3,
	A = 4,
	B = 5,
	C = 6
}
local function from( num, count )
	local args = {}
	for i = count or 6, 1,-1 do
		args[i] = num % 10
		num = math.floor( num / 10 )
	end
	return args
end


function MOD:OnStart()

	self:NetworkVar( "Int", "Wires" )
	self:NetworkVar( "Int", "CutWires" )
	self:NetworkVar( "Int", "Stage" )
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


if SERVER then

	function MOD:GetNet()

	end

	local function to( args, count )
		local num = 0
		for i = 1, count do
			local v = args[i]
			num = num * 10
			num = num + v
		end
		return num
	end

	function MOD:GotoStage( stage )

		self:SetStage( stage )
		self:SetWires(0)
		self:SetCutWires(0)
		timer.Simple( 1, function()
			if !IsValid( self:GetBomb() ) then return end

			local map = self.Map[ self:GetStage() + 1 ]
			local wires = {0,0,0,0,0,0}
			local cut = {0,0,0}
			for k, wire in pairs( map ) do
				wires[(k-1)*2+1] = wire[1]
				wires[(k-1)*2+2] = wire[2]
				cut[k] = wire[3]
			end
			self:SetWires( to( wires ) )
			self:SetCutWires( to( cut ), 3 )

		end)

	end

	function MOD:StartServer()

		local Map = {}
		for i = 1, 4 do
			local wires = {}
			local Positions = {self.Enums.A, self.Enums.B, self.Enums.C}
			local Bag = { // the bag to take a handful out of
				self.Enums.RED,
				self.Enums.RED,
				self.Enums.RED,
				self.Enums.BLUE,
				self.Enums.BLUE,
				self.Enums.BLUE,
				self.Enums.BLACK,
				self.Enums.BLACK,
				self.Enums.BLACK
			}
			for i = 1, math.random( 1, 3 ) do
				local v,k = table.Random( Bag )
				local v2,k2 = table.Random( Positions )
				wires[v2] = {
					v, // wire color
					math.random( self.Enums.A, self.Enums.C ), // wire connected to 
					false // wire is cut
				}
				table.remove( Bag, k )
				table.remove( Positions, k2 )
			end
			Map[i] = wires
		end
		self.Map = Map

	end

else

	function MOD:Press()

		print( "PRESSED!" )

	end

	local cw, ch = 64, 64

	function MOD:DrawWire( num, col, to, cut )



	end

	function MOD:Draw( w, h )

		self:PolyButton( {
				{ x = 0, y = h/2 },
				{ x = 128, y = 32 },
				{ x = 128, y = 32 + 32 },
				{ x = 0, y = h/2 + 32 },

			}, Color( 255,0,255 ),
			false,false,
			self.Press,
			self
		)

	end

end


