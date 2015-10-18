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

MOD.Name			= "Who's On First"	
MOD.Difficulty		= 2
MOD.Needy			= false
MOD.Enabled			= true
MOD.ForceWithTimer	= false
MOD.ScreenSize		= 256
// MOD.Rarity		= 2


MOD.ButtonWords = {
	"READY",
	"FIRST",
	"NO",
	"BLANK",
	"NOTHING",
	"YES",
	"WHAT?",
	"UHHH",
	"LEFT",
	"RIGHT",
	"MIDDLE",
	"OKAY",
	"WAIT",
	"PRESS",
	"YOU",
	"YOU ARE",
	"YOUR",
	"YOU'RE",
	"UR",
	"U",
	"UH HUH",
	"UH UH",
	"WHAT?",
	"DONE",
	"NEXT",
	"HOLD",
	"SURE",
	"LIKE"
}

MOD.ScreenWords = {
	"YES","FIRST","DISPLAY","OKAY","SAYS","NOTHING",
	"","BLANK","NO","LED","LEAD","READ",
	"RED","REED","LEED","HOLD ON","YOU","YOU ARE",
	"YOUR","YOU'RE","UR","THERE","THEY'RE","THEIR",
	"THEY ARE","SEE","C","CEE"
}

function MOD:OnStart()

	self:NetworkVar( "String", "Contents" )
	self:NetworkVar( "Int", "Stage" )

	if SERVER then
		self:NewScreen()
	end

end

function MOD:OnDisarm() 

end

function MOD:OnEnd()

end



function MOD:FromData( chr )

	chr = string.lower( chr )
	if chr == "0" then
		return 27
	elseif chr == "1" then
		return 28
	end
	local num = string.byte( chr ) - 96
	if num < 1 or num > 26 then
		ErrorNoHalt( "expected alphabet character, got " .. chr )
		return 1
	end
	return num

end

function MOD:ToData( num )

	if num == 27 then
		return "0"
	elseif num == 28 then
		return "1"
	end
	local chr = string.char( num + 96 )
	return chr

end

function MOD:GetScreen( str )

	if #self:GetContents() == 0 then return end
	local i = self:FromData( self:GetContents():sub( 1,1 ) )
	return str and self.ScreenWords[ i ] or i

end
function MOD:GetButton( button, str )

	if #self:GetContents() == 0 then return end
	local i = self:FromData( self:GetContents():sub( button+1,button+1 ) )
	return str and self.ButtonWords[ i ] or i

end


if SERVER then


	MOD.Lists = {
		{
			6,12,23,11,9,14,10,4,1,3,2,8,5,13,
		},
		{
			9,12,6,11,3,10,5,8,13,1,4,23,14,2,
		},
		{
			4,8,13,2,23,1,10,6,5,9,14,12,3,11,
		},
		{
			13,10,12,11,4,14,1,5,3,23,9,8,6,2,
		},
		{
			8,10,12,11,6,4,3,14,9,23,13,2,5,1,
		},
		{
			12,10,8,11,2,23,14,1,5,6,9,4,3,13,
		},
		{
			8,23,9,5,1,4,11,3,12,2,13,6,14,10,
		},
		{
			1,5,9,23,12,6,10,3,14,4,8,11,13,2,
		},
		{
			10,9,2,3,11,6,4,23,8,13,14,1,12,5,
		},
		{
			6,5,1,14,3,13,23,10,11,9,8,4,12,2,
		},
		{
			4,1,12,23,5,14,3,13,9,11,10,2,8,6,
		},
		{
			11,3,2,6,8,5,13,12,9,1,4,14,23,10,
		},
		{
			8,3,4,12,6,9,2,14,23,13,5,1,10,11,
		},
		{
			10,11,6,1,14,12,5,8,4,9,2,23,3,13,
		},
		{
			27,16,17,18,25,21,19,26,7,15,22,28,24,20,
		},
		{
			17,25,28,21,7,24,22,26,15,20,18,27,19,16,
		},
		{
			22,16,21,17,25,19,27,20,18,15,7,26,28,24,
		},
		{
			15,18,19,25,22,16,20,17,7,21,27,24,28,26,
		},
		{
			24,20,19,21,7,27,17,26,18,28,25,22,16,15,
		},
		{
			21,27,25,7,18,19,22,24,20,15,28,26,16,17,
		},
		{
			21,17,16,15,24,26,22,25,27,28,18,19,20,7,
		},
		{
			19,20,16,18,25,22,24,15,21,28,17,27,26,7,
		},
		{
			15,26,18,17,20,24,22,28,16,21,19,25,7,27,
		},
		{
			27,21,25,7,17,19,18,26,28,15,20,16,22,24,
		},
		{
			7,21,22,17,26,27,25,28,24,16,19,18,20,15,
		},
		{
			16,20,24,22,15,19,27,7,18,25,26,21,17,28,
		},
		{
			16,24,28,18,15,26,21,19,27,20,7,25,17,22,
		},
		{
			18,25,20,19,26,24,22,7,21,15,28,27,16,17,
		},
	}
	MOD.ButtonPositions = {
		3,2,6,2,6,3,
		5,4,6,3,6,4,
		4,5,5,6,4,6,
		4,4,1,6,5,4,
		  3,6,2,6
	}
	function MOD:GetButtonPos()

		if #self:GetContents() == 0 then return end
		local i = self:FromData( self:GetContents():sub( 1,1 ) )
		return self.ButtonPositions[ i ]

	end

	function MOD:SetScreen( i )

		local str = self:GetContents()
		self:SetContents( self:ToData( i ) .. str:sub( 2 ) )

	end
	function MOD:SetButton( button, i )

		local str = self:GetContents()
		self:SetContents( str:sub( 1, button ) .. self:ToData( i ) .. str:sub( button+2 ) )

	end


	function MOD:DoesButtonExist( button )

		for i = 1, 6 do
			if self:GetButton(i) == button then
				return i
			end
		end
		return false

	end

	function MOD:ShouldPushButton( button )

		local toRead = self:GetButtonPos()
		local buttons = {

			self:GetButton(1),
			self:GetButton(2),
			self:GetButton(3),
			self:GetButton(4),
			self:GetButton(5),
			self:GetButton(6),

		}

		// what word are we using
		local CurScreen = self:GetScreen()
		local pos = self.ButtonPositions[ CurScreen ]
		local word = buttons[ pos ]

		// find the table
		local List = self.Lists[ word ]
		for i = 1, #List do
			local exists = self:DoesButtonExist( List[i] )
			if exists then
				return button == exists
			end
		end

		return false


	end

	function MOD:NewScreen()

		self.DisableButtons = true
		self:SetContents("")
		timer.Simple( 2, function()

			if !IsValid( self:GetBomb() ) then return end
			self.DisableButtons = nil
			self:SetScreen( math.random( 1, 28 ) )
			local tab = table.Random( self.Lists )
			local range = math.random( 6, 14 )
			local used = {}
			local i = 0
			while i < 6 do

				i = i + 1
				local k = math.random( 1, range )
				if used[k] then
					i = i - 1
					continue
				end
				self:SetButton( i, tab[k] )
				used[k] = true

			end

		end )

	end


	function MOD:GetNet( button )

		if self.DisableButtons then return end
		button = math.Clamp( button, 1, 6 )
		if self:ShouldPushButton( button ) then
			self:SetStage( self:GetStage() + 1 )
			if self:GetStage() == 3 then
				self:Disarm()
				return
			end
			self:NewScreen()
		else
			self:GetBomb():Strike( self )
			self:NewScreen()
		end

	end

else

	local StageW = 24*2
	local StageH = 80*2
	local Padding = 16
	local C_GREEN = Color( 0,255,0 )
	local C_BG = Color( 255, 245, 150 )

	function MOD:Press( button )
		self:SendNet( button )

	end

	function MOD:Draw( w, h )

		Padding = 16
		surface.SetDrawColor( 50,50,50 )
		surface.DrawRect( w - StageW - Padding, h / 2 - StageH / 2, StageW, StageH )

		for i = -1, 1 do

			local x = w - StageW/2 - Padding
			local y = h/2 + -i * 60
			surface.SetDrawColor( self:GetStage() >= i + 2 and C_GREEN or color_black )
			surface.DrawRect( x - 16, y - 8, 32, 16 )

		end
		local ow, oh = w, h
		w, h = 84*2, 116*2
		local x, y = Padding, oh / 2 - h/2
		surface.SetDrawColor(70,70,70)
		surface.DrawRect( x, y, w, h )

		Padding = 8
		// screen
		local CenterX = x + w/2
		surface.SetDrawColor( 0,0,20 )
		surface.DrawRect( x + Padding, y + Padding, w - Padding*2, 68 )
		local txt = self:GetScreen(true) or ""
		draw.SimpleText( txt, "Trebuchet24", CenterX, y + Padding + 68/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		// buttons
		if self:GetContents() == "" then return end // no buttons no draw
		local dist = y + Padding + 68
		local CenterY = ( h - dist ) / 2 + dist


		local bw, bh = 38*2, 16*2

		for i = 1, 6 do
			local ox = x + w/2 + ( i % 2 == 1 and w/-4 or w/4 )
			local oy = CenterY + ( math.ceil( i/2 ) - 2 ) * 40
			self:Button( ox - bw/2, oy - bh/2, bw, bh,
				C_BG,
				self:GetButton( i, true ), "gothic", color_black,
				4,
				nil,nil,
				false,false,
				self.Press,
				self,
				i
			)
		end

	end

end

