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

MOD.Name			= "Keypad"	
MOD.Difficulty		= 1		
MOD.Needy			= false	
MOD.Enabled			= true
MOD.ForceWithTimer	= false	
MOD.Rarity			= 2

MOD.Resources = MOD.Resources or {[0]=Material("nonexistant/texture" )}
local path = "materials/keeptalkingnobodyexplodes/keypad/"
	local files = file.Find( path .. "*-*.png", "GAME" )
	for i = 1, 31 do
		local file
		for k,v in pairs( files ) do
			local sub = i < 10 and 1 or 2
			if v:find( i .. "%-.+" ) and v:sub( 1,sub ) == tostring( i ) then
				file = v
				break
			end
		end
		if file then
			local fullPath = path .. file

			if SERVER then
				MOD.Resources[ i ] = fullPath
				resource.AddFile( fullPath )
			else
				local str = string.gsub( fullPath, "material/", "" )
				MOD.Resources[ i ] = Material( str )
			end

		end
	end


if SERVER then

	MOD.Columns = {

		{28,13,30,12,7,9,23},
		{16,28,23,26,3,9,20},
		{1,8,26,5,15,30,3},
		{11,21,31,7,5,20,4},
		{24,4,31,22,21,19,2},
		{11,16,27,14,24,18,6}

	}

	function MOD:GetNet( button )

		if self:IsCorrectButtonToPush( button ) then
			self:SetButton( button, true )
			self:SetButtonsComplete( self:GetButtonsComplete() + 1 )
			if self:GetButtonsComplete() == 4 then
				self:Disarm()
			end
		else
			self:GetBomb():Strike( self )
			self:SetWrongButton( button )
			self:SetWrongTime( CurTime() )
		end

	end

	function MOD:IsCorrectButtonToPush( button )

		local tab = self:GetButtons( true )
		button = tab[button]
		local Next = self:GetButtonsComplete() + 1
		return button == self.Sequence[ Next ]

	end

	function MOD:ServerStart()

		local ColNum = math.random( 1, 6 )
		local Column = table.Copy( self.Columns[ColNum] )
		local Sequence = {}
		for i = 1, 4 do
			local v, k = table.Random( Column )
			table.insert( Sequence, v )
			table.remove( Column, k )
		end
		local Ordered = {}
		local NewSeq = table.Copy( Sequence )
		for i = 1, #self.Columns[ColNum] do
			local v = self.Columns[ ColNum ][i]
			local k = table.KeyFromValue( Sequence, v )
			if k then
				table.insert( Ordered, v )
				table.remove( Sequence, k )
			end
		end

		self.Sequence = Ordered

		self:SetButtons( NewSeq )

	end

	function MOD:SetButtons( buttons )

		local num = buttons[1]
		num = bit.lshift( num, 5 )
		num = bit.bxor( num, buttons[2] )

		num = bit.lshift( num, 5 )
		num = bit.bxor( num, buttons[3] )

		num = bit.lshift( num, 5 )
		num = bit.bxor( num, buttons[4] )

		self:SetButtonsInternal( num )

	end

end

function MOD:GetButtons( tab )

	local num = self:GetButtonsInternal()
	local band = math.BinToInt( "11111" )
	if !tab then
		local a,b,c,d = 0,0,0,0
		
		d = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		c = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		b = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		a = num

		return a,b,c,d
	else
		local tab = {}
		
		tab[4] = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		tab[3] = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		tab[2] = bit.band( num, band )
		num = bit.rshift( num, 5 )
		
		tab[1] = num

		return tab
	end


end

function MOD:OnStart()

	self:NetworkVar( "Int", "ButtonsInternal" ) // a 24-bit integer containing which symbol each button contains
	self:NetworkVar( "Int", "ButtonsComplete" )
	self:NetworkVar( "Int", "WrongButton" )
	self:NetworkVar( "Float", "WrongTime" )
	self:NetworkVar( "Bool", "Button1" )
	self:NetworkVar( "Bool", "Button2" )
	self:NetworkVar( "Bool", "Button3" )
	self:NetworkVar( "Bool", "Button4" )
	if SERVER then
		self:ServerStart()
	end

end
function MOD:GetButton( x )

	return self["GetButton" .. x](self)

end
function MOD:SetButton( x, y )

	self["SetButton" .. x](self, y)

end

function MOD:Think()

end

function MOD:OnDisarm()

end

function MOD:OnEnd()

end
if CLIENT then

	local Margin = 8
	local C_BG = Color( 255, 245, 200 )
	local C_GREEN = Color( 0,255,0 )
	local C_RED = Color( 255,0,0 )

	function MOD:Press( ind )

		self:SendNet( ind )

	end

	function MOD:DrawButton( x, y, size, i, symbol, lit )

		local x, y, w, h = x - size/2 + Margin, y - size/2 + Margin, size - Margin*2, size - Margin*2
		self:GetBomb():Button( x, y,
			w, h,
			C_BG, 
			nil, nil, nil,
			0,
			4,
			color_black,
			lit,
			false,
			self.Press,
			self,
			i
		)

		surface.SetMaterial( self.Resources[ symbol ] )
		surface.SetDrawColor( 255,255,255 )
		surface.DrawTexturedRect( x + Margin, y + Margin + 4, w - Margin*2, h - Margin*2 )

		local col = self:GetWrongButton() == i and CurTime() - self:GetWrongTime() < 0.25 and C_RED or lit and C_GREEN or color_black
		surface.SetDrawColor( col )
		surface.DrawRect( x + size/2 - Margin - 8, y + 6, 16, 4 )

	end


	function MOD:Draw( w, h )

		local Spacing = w/5
		local a,b,c,d = self:GetButtons()
		self:DrawButton( w/2 - Spacing, h/2 - Spacing, w/2, 1, a, self:GetButton( 1 ) )
		self:DrawButton( w/2 + Spacing, h/2 - Spacing, w/2, 2, b, self:GetButton( 2 ) )
		self:DrawButton( w/2 - Spacing, h/2 + Spacing, w/2, 3, c, self:GetButton( 3 ) )
		self:DrawButton( w/2 + Spacing, h/2 + Spacing, w/2, 4, d, self:GetButton( 4 ) )

	end

end
