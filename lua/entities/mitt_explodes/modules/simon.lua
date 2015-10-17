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

MOD.Name			= "Simon Says"
MOD.Difficulty		= 2			
MOD.Needy			= false		
MOD.Enabled			= true	
MOD.ForceWithTimer	= false		
// MOD.Rarity		= 2
MOD.Sound			= Sound( "plats/elevbell1.wav" )

MOD.Colors = {
	Color( 0,0,255 ),
	Color( 255,255,0 ),
	Color( 0,255,0 ),
	Color( 255,0,0 ),
}
MOD.Enums = {
	BLUE = 1,
	YELLOW = 2,
	GREEN = 3,
	RED = 4
}

function MOD:OnStart() 

	self:NetworkVar( "Int", "LitColor" )
	self:NetworkVar( "Int", "Stage" )

	if SERVER then

		self:StartServer()

	end

end

function MOD:LightUp( button )

	if button == self:GetLitColor() then
		self:SetLitColor(0)
		timer.Simple( 0.1, function()
			self.LitTime = CurTime()
			self:SetLitColor( button )
		end )
	else
		self.LitTime = CurTime()
		self:SetLitColor( button )
	end

end

function MOD:Think() 

	if SERVER then

		if self:GetDisarmed() then

			if self.LitTime and CurTime() - self.LitTime > 0.5 or !self.LitTime then
				self.LitTime = nil
				self:SetLitColor(0)
			end
			return
		end

		local pat = self.Pattern
		if self.LitTime and CurTime() - self.LitTime > 0.5 then
			self.LitTime = nil
			self:SetLitColor(0)
		end

		if self:GetStage() == 0 then
			if self.LastAction and CurTime() - self.LastAction >= 3 or !self.LastAction then
				self:LightUp( pat[1] )
				self.LastAction = CurTime()
			end
		else

			local Next = self.NextSignal
			if CurTime() < Next then return end
			if !self.CurColor then

				self.CurColor = 1
				self.NextSignal = CurTime() + 1

				self:LightUp( pat[1] )

				table.Empty( self.Progress )

			else

				self.CurColor = self.CurColor + 1
				if self.CurColor >= self:GetStage() + 1 then
					self.CurColor = nil
					self.NextSignal = CurTime() + 3
					return
				end

				self:LightUp( pat[self.CurColor] )

				self.NextSignal = CurTime() + 1

			end

		end

	else

		if self:GetLitColor() > 0 and self:GetLitColor() != self.LastLitColor then
			self.LastLitColor = self:GetLitColor()
			self.LightTime = CurTime()
			if self:GetStage() > 0 then
				self:GetBomb():EmitSound( self.Sound, 100, 90 + 10*self:GetLitColor() )
			end
		elseif self:GetLitColor() != self.LastLitColor then
			self.LastLitColor = self:GetLitColor()
		end

	end

end

function MOD:OnDisarm()

end

function MOD:OnEnd() 

end


if SERVER then

	MOD.Map = { // Map > HasVowels > ColorToMap = MappedColor
		[true] = {
			[MOD.Enums.RED] = {
				MOD.Enums.BLUE,
				MOD.Enums.YELLOW,
				MOD.Enums.GREEN
			},
			[MOD.Enums.BLUE] = {
				MOD.Enums.RED,
				MOD.Enums.GREEN,
				MOD.Enums.RED,
			},
			[MOD.Enums.GREEN] = {
				MOD.Enums.YELLOW,
				MOD.Enums.BLUE,
				MOD.Enums.YELLOW,
			},
			[MOD.Enums.YELLOW] = {
				MOD.Enums.GREEN,
				MOD.Enums.RED,
				MOD.Enums.BLUE,
			},
		},
		[false] = {
			[MOD.Enums.RED] = {
				MOD.Enums.BLUE,
				MOD.Enums.RED,
				MOD.Enums.YELLOW,
			},
			[MOD.Enums.BLUE] = {
				MOD.Enums.YELLOW,
				MOD.Enums.BLUE,
				MOD.Enums.GREEN,
			},
			[MOD.Enums.GREEN] = {
				MOD.Enums.GREEN,
				MOD.Enums.YELLOW,
				MOD.Enums.BLUE,
			},
			[MOD.Enums.YELLOW] = {
				MOD.Enums.RED,
				MOD.Enums.GREEN,
				MOD.Enums.RED,
			},

		}
	}

	function MOD:MapColor( col )

		local st = self:GetBomb():GetStrikes()
		local vow = self:GetBomb():SerialHasVowels()

		return self.Map[ vow ][ col ][st + 1]

	end

	function MOD:StartServer()

		local Pattern = {}
		for i = 1, math.random( 4, 6 ) do
			table.insert( Pattern, math.random( 1, 4 ) )
		end

		self.Pattern = Pattern

	end
	
	function MOD:GetNet( button )

		button = math.Clamp( button, 1, 4 )
		self:LightUp( button )
		self.NextSignal = CurTime() + 4
		self.CurColor = nil
		if self:GetStage() == 0 then
			self.Progress = { button }
			self:SetStage(1)
			self.LastSignal = CurTime() + 2
		else
			table.insert( self.Progress, button )
		end

		if button != self:MapColor( self.Pattern[ #self.Progress ] ) then
			table.Empty( self.Progress )
			self.NextSignal = CurTime() + 2
			self:GetBomb():Strike( self )
		elseif #self.Progress == self:GetStage() then
			self:SetStage( self:GetStage() + 1 )
			self.NextSignal = CurTime() + 2
			if #self.Pattern == self:GetStage() then
				self:Disarm()
				self:SetStage(0)
			end
		end

	end

else

	local C_UNLIT = {
		Color( 0,0,100 ),
		Color( 100,100,0 ),
		Color( 0,100,0 ),
		Color( 100,0,0 )
	}
	function MOD:Press( button )
		self:SendNet( button )
	end
	function MOD:Draw( w, h )

		local size,vert = 24,4
		local lit = self.LightTime and CurTime() - self.LightTime <= 0.5 and self:GetLitColor() or 0

		local Space = 28

		self:CircleButton( w / 2, h / 2 - Space,
			size,vert,
			lit == 1 and self.Colors[1] or C_UNLIT[1],
			nil,nil,nil,
			2, color_black,
			false,
			false,
			self.Press,
			self,
			1
		)
		self:CircleButton( w / 2 + Space, h / 2,
			size,vert,
			lit == 2 and self.Colors[2] or C_UNLIT[2],
			nil,nil,nil,
			2, color_black,
			false,
			false,
			self.Press,
			self,
			2
		)

		self:CircleButton( w / 2, h / 2 + Space,
			size,vert,
			lit == 3 and self.Colors[3] or C_UNLIT[3],
			nil,nil,nil,
			2, color_black,
			false,
			false,
			self.Press,
			self,
			3
		)
		self:CircleButton( w / 2 - Space, h / 2,
			size,vert,
			lit == 4 and self.Colors[4] or C_UNLIT[4],
			nil,nil,nil,
			2, color_black,
			false,
			false,
			self.Press,
			self,
			4
		)

	end
end
