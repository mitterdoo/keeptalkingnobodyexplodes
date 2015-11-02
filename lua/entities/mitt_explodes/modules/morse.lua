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

MOD.Name			= "Morse Code"
MOD.Difficulty		= 3	
MOD.Needy			= false
MOD.Enabled			= true
MOD.ForceWithTimer	= false
// MOD.Rarity		= 2	
MOD.Frequencies = {
	3.505,
	3.515,
	3.522,
	3.532,
	3.535,
	3.542,
	3.545,
	3.552,
	3.555,
	3.565,
	3.572,
	3.575,
	3.582,
	3.592,
	3.595,
	3.600
}
MOD.TickRate = 0.3
MOD.Buttons = {
	LEFT = 1,
	RIGHT = 2,
	TRANSMIT = 3,
}
MOD.HoverOutline = 2


function MOD:OnStart()

	self:NetworkVar( "String", "Morse" )
	self:NetworkVar( "Int", "Frequency" )
	if SERVER then
		self:StartServer()
	else
		self:StartClient()
	end

end


function MOD:OnDisarm()

end

function MOD:OnEnd()

end


if SERVER then

	MOD.Morse = {
		A = '.-',
		B = '-...',
		C = '-.-.',
		D = '-..',
		E = '.',
		F = '..-.',
		G = '--.',
		H = '....',
		I = '..',
		J = '.---',
		K = '-.-',
		L = '.-..',
		M = '--',
		N = '-.',
		O = '---',
		P = '.--.',
		Q = '--.-',
		R = '.-.',
		S = '...',
		T = '-',
		U = '..-',
		V = '...-',
		W = '.--',
		X = '-..-',
		Y = '-.--',
		Z = '--..'
	}
	MOD.Words = {
		'SHELL',
		"HALLS",
		"SLICK",
		"TRICK",
		"BOXES",
		"LEAKS",
		"STROBE",
		"BISTRO",
		"FLICK",
		"BOMBS",
		"BREAK",
		"BRICK",
		"STEAK",
		"STING",
		"VECTOR",
		"BEATS"
	}

	function MOD:StartServer()
		local morse = ""

		self.Word = table.Random( self.Words )
		for i = 1, #self.Word do
			local c = self.Word:sub( i,i )
			morse = morse .. self.Morse[c] .. ( i < #self.Word and "/" or "" )
		end
		self:SetMorse( morse )
		self:SetFrequency( math.random( 1, 16 ) )

	end

	function MOD:GetNet(button)

		if button == self.Buttons.LEFT and self:GetFrequency() > 1 then
			self:SetFrequency( self:GetFrequency() - 1 )
		elseif button == self.Buttons.RIGHT and self:GetFrequency() < 16 then
			self:SetFrequency( self:GetFrequency() + 1 )
		elseif button == self.Buttons.TRANSMIT then
			if self:GetFrequency() == self:GetFrequencyToTransmitTo() then
				self:Disarm()
			else
				self:GetBomb():Strike( self )
			end
		end

	end
	function MOD:GetFrequencyToTransmitTo()

		return table.KeyFromValue( self.Words, self.Word )

	end

else

	function MOD:sleep( time )
		self.Next = CurTime() + time
	end

	function MOD:StartClient()

		self.Ind = 1

	end

	function MOD:Think()

		if self.Next and CurTime() < self.Next then return end

		local morse = self:GetMorse()
		local tick = self.TickRate
		if self.Ind > #morse then
			self.Ind = 1
			self:sleep( tick * 7 )
		else
			local chr = morse:sub( self.Ind,self.Ind )
			if chr == "/" then
				self:sleep( tick*3 )
				self.Ind = self.Ind + 1
			elseif chr == "." then
				if !self.Part then
					self.Part = 1
					self.Lit = true
					self:sleep( tick )
				elseif self.Part == 1 then
					self.Lit = false
					self:sleep( tick )
					self.Part = nil
					self.Ind = self.Ind + 1
				end

			elseif chr == "-" then
				if !self.Part then
					self.Part = 1
					self.Lit = true
					self:sleep( tick*3 )
				elseif self.Part == 1 then
					self.Lit = false
					self:sleep( tick )
					self.Part = nil
					self.Ind = self.Ind + 1
				end
			end

		end

	end

	local C_LIT = Color( 255,175,0 )
	local C_UNLIT = Color( 128, 88, 0 )

	local C_GRAY = Color( 30,30,30 )
	local C_BG = Color( 100,100,100 )
	local C_RED = Color( 255,80,80 )
	local C_REALRED = Color( 255,0,0 )
	local C_BUTTONBG = Color( 255, 245, 150 )
	local Padding = 4

	function MOD:Press( button )
		self:SendNet( button )
	end

	function MOD:Draw( w, h )

		surface.SetDrawColor( color_black )

		local lw, lh = 32, 16
		surface.DrawRect( 10, 10, lw, lh )
		surface.DrawRect( 6, 10 + lh/2 - 1, w-6, 2 )
		surface.DrawRect( 6, 0, 2, 10 + lh/2 - 1 )
		surface.SetDrawColor( self.Lit and C_LIT or C_UNLIT )
		local Border = 3
		surface.DrawRect( 10 + Border, 10 + Border, 32 - Border*2, 16 - Border*2 )

		surface.SetDrawColor( C_BG )
		local ow, oh = w, h
		w, h = 110, 60
		local x, y = ow/2 - w/2, 40
		surface.DrawRect( x, y, w, h )


		local TunerWidth = w - Padding*2
		surface.SetDrawColor( color_black )
		surface.DrawRect( x + Padding, y + Padding, TunerWidth, 20 )
		surface.SetDrawColor( color_white )
		surface.DrawRect( x + Padding + Border, y + Padding + Border, TunerWidth - Border*2, 20 - Border*2 )
		local lineSpacing = 6
		local times = 16
		local lineHeight = 4

		surface.SetDrawColor( C_RED )
		for i = 1, times do
			local offset = i - 8.5

			local ox = x + w / 2 + offset * lineSpacing
			local oy = i % 2 == 0 and y + Padding + Border or y + Padding - Border + 20 - lineHeight
			surface.DrawRect( ox, oy, 1, lineHeight )

		end

		TunerWidth = 80
		local size = TunerWidth / 17 * self:GetFrequency() - TunerWidth / 2
		local ox = x + w / 2 + size
		local oy = y + Padding + 20 - Border - lineHeight*2
		surface.SetDrawColor( C_REALRED )
		surface.DrawRect( ox - 1, oy, 2, lineHeight*2)

		surface.SetDrawColor( color_black )
		surface.DrawRect( x + w / 2 - TunerWidth / 2, y + h - 26, TunerWidth, 20 )
		draw.SimpleText( ( self.Frequencies[ self:GetFrequency() ] or "3.555" ) .. " MHz",
			"Trebuchet18",
			x + w / 2, y + h - 16, C_LIT,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
		)
		local bw, bh = 12, 20
		self:Button( 
			x + 1, y + h - 26,
			bw, bh,
			C_GRAY,
			"«","default", color_white,
			2,
			1,color_black,
			false,false,
			self.Press,
			self,
			self.Buttons.LEFT
		)
		self:Button( 
			x + w - 1 - bw, y + h - 26,
			bw, bh,
			C_GRAY,
			"»","default", color_white,
			2,
			1,color_black,
			false,false,
			self.Press,
			self,
			self.Buttons.RIGHT
		)
		

		local bw, bh = 20, 20
		self:Button( 

			x + w/2 - bw/2, y + h + 2,
			bw, bh,
			C_BUTTONBG,
			"TX",
			"gothic_sm",
			color_black,
			4,
			2, color_black,
			false,false,
			self.Press,
			self,
			self.Buttons.TRANSMIT

		)

	end

end
