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

MOD.Name			= "Button"	// name of the module
MOD.Difficulty		= 1				// difficulty of the module
MOD.Needy			= false			// is a needy module
MOD.Enabled			= true			// should this module be used in game
MOD.ForceWithTimer	= true			// if this module requires the timer in view, make this true (e.g. button)

/*

	functions you can call on modules:
	MOD:GetBomb()		returns the bomb entity
	MOD:IsTimer()		returns if the module is the timer

*/

MOD.Colors = {
	Color( 255,40,40 ),
	Color( 40,40,255 ),
	Color( 255,255,40),
	Color( 255,255,255 )
}
MOD.TextColors = {
	Color( 255,255,255 ),
	Color( 255,255,255 ),
	Color( 0,0,0 ),
	Color( 0,0,0 )
}
MOD.Enums = {
	RED = 1,
	BLUE = 2,
	YELLOW = 3,
	WHITE = 4
}
MOD.Text = {
	"DETONATE",
	"PRESS",
	"HOLD",
	"ABORT"
}

function MOD:OnStart() // called when the module is created

	self:NetworkVar( "Int", "Color" )
	self:NetworkVar( "Int", "Strip" )
	self:NetworkVar( "String", "Text" )
	if SERVER then

		self:SetColor( math.random( 1, 4 ) )
		self:SetText( table.Random( self.Text ) )

	end

end

if SERVER then

	function MOD:GetNet( pressed )
		pressed = tobool( pressed )
		if pressed == tobool( self.IsPressed ) then return end
		self.IsPressed = pressed

		if pressed then
			self.LastPress = CurTime()
		elseif self.LastPress then
			local delta = CurTime() - self.LastPress
			if delta >= 0.5 then
				// 	held
				// were we supposed to do this?
				if self:ShouldHoldDown() then
					// yes. now math strip with time on clock
					local col = self:GetStrip()
					local cols = self.Enums
					local bomb = self:GetBomb()
					if col == cols.BLUE and bomb:DoesClockHaveDigit( 4 ) or
						col == cols.WHITE and bomb:DoesClockHaveDigit( 1 ) or
						col == cols.YELLOW and bomb:DoesClockHaveDigit( 5 ) or
						bomb:DoesClockHaveDigit( 1 ) then

						// disarm!!!!!
						self:Disarm()
					else
						bomb:Strike( self )
					end

				else
					// you fucked up
					self:GetBomb():Strike( self )
				end
				self:SetStrip(0)
			else
				// 	released immediately
				// were we supposed to do that
				if !self:ShouldHoldDown() then
					// yes. that's all we gotta do, so disarm
					self:Disarm()
				else
					// fuck off
					self:GetBomb():Strike( self )
				end
			end
			self.LastPress = nil
		end

	end


	function MOD:ShouldHoldDown()

		local col = self:GetColor()
		local cols = self.Enums
		local text = self:GetText()
		local bomb = self:GetBomb()

		if text == "ABORT" and col == cols.BLUE then
			return true
		elseif bomb:GetBatteryCount() > 1 and text == "DETONATE" then
			return false
		elseif col == cols.WHITE and bomb:DoesIndicatorExist( "CAR", true ) then
			return true
		elseif bomb:GetBatteryCount() > 2 and bomb:DoesIndicatorExist( "FRK", true ) then
			return false
		elseif col == cols.YELLOW then
			return true
		elseif col == cols.RED and text == "HOLD" then
			return false
		else
			return true
		end

	end


end

function MOD:Think() // called every think of the bomb entity

	if SERVER then

		if self.LastPress and CurTime() - self.LastPress >= 0.5 and self:GetStrip() == 0 then
			self:SetStrip( math.random( 1,4 ) )
		end

	end

end

function MOD:OnDisarm() // called when the module is disarmed

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:Press( pressed )

	self:SendNet( pressed and 1 or 0 )
	return "keeptalkingnobodyexplodes/bb-press-in.wav","keeptalkingnobodyexplodes/bb-press-release.wav"

end

function MOD:Draw( w, h )

	self:GetBomb():CircleButton( w / 8 * 3, h/2,
		40, 32,
		self.Colors[ self:GetColor() ] or Color(0,0,0),
		self:GetText(), "gothic", self.TextColors[ self:GetColor() ],
		4,
		nil, false, true, self.Press, self )

	local w2, h2 = 16, 60
	local Padding = 12
	if self:GetStrip() > 0 then
		surface.SetDrawColor( self.Colors[ self:GetStrip() ] )
	else
		surface.SetDrawColor( 0,0,0 )
	end
	
	surface.DrawRect( w - w2 - Padding, h / 2 - h2/2, w2, h2 )

end

function MOD:ScreenClicked( x, y )

end
