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

MOD.Name			= "Memory"	
MOD.Difficulty		= 2				
MOD.Needy			= false			
MOD.Enabled			= true	
MOD.ForceWithTimer	= false		
MOD.ScreenSize		= 128
MOD.HoverOutline	= 2
// MOD.Rarity		= 2				



function MOD:OnStart() 

	self:NetworkVar( "Int", "Numbers" )
	self:NetworkVar( "Int", "Screen" )
	self:NetworkVar( "Int", "Stage" )

	if SERVER then
		self:SetStage(1)
		self:StartSequence()
	end


end

function MOD:Think() 

end

function MOD:OnDisarm()

end

function MOD:OnEnd() 

end


if SERVER then

	function MOD:NewScreen()

		self:SetNumbers(0)
		self:SetScreen(0)
		timer.Simple( 2, function()

			if !IsValid( self:GetBomb() ) then return end
			
			local nums = {1,2,3,4}
			local newNums = {}
			for i = 1, 4 do
				local v, k = table.Random( nums )
				table.insert( newNums, v )
				table.remove( nums, k )
			end
			self:SetNumbers( tonumber( table.concat( newNums ) ) )
			self:SetScreen( math.random( 1, 4 ) )

		end )

	end

	function MOD:StartSequence()

		self.Memory = {}
		self:NewScreen()
		self:SetStage(1)

	end


	function MOD:GetButtonToPress()

		local mem = self.Memory
		local st = self:GetStage()
		local num = self:GetScreen()
		local nums = string.Split( tostring( self:GetNumbers() ), "" )
		for k,v in pairs( nums ) do nums[k] = tonumber( v ) end

		if st == 1 then
			return ( num == 1 or num == 2 ) and 2 or
				num == 3 and 3 or
				num == 4 and 4
		elseif st == 2 then
			return num == 1 and table.KeyFromValue( nums, 4 ) or
				( num == 2 or num == 4 ) and mem[1].Pos or
				num == 3 and 1
		elseif st == 3 then
			return num == 1 and table.KeyFromValue( nums, mem[2].Label ) or
				num == 2 and table.KeyFromValue( nums, mem[1].Label ) or
				num == 3 and 3 or
				num == 4 and table.KeyFromValue( nums, 4 )
		elseif st == 4 then
			return num == 1 and mem[1].Pos or
				num == 2 and 1 or
				( num == 3 or num == 4 ) and mem[2].Pos
		else
			return num == 1 and table.KeyFromValue( nums, mem[1].Label ) or
				num == 2 and table.KeyFromValue( nums, mem[2].Label ) or
				num == 3 and table.KeyFromValue( nums, mem[4].Label ) or
				num == 4 and table.KeyFromValue( nums, mem[3].Label )
		end

	end

	function MOD:GetNet( button )

		if self:GetButtonToPress() == button then

			local nums = string.Split( tostring( self:GetNumbers() ), "" )
			for k,v in pairs( nums ) do nums[k] = tonumber( v ) end
			self.Memory[ self:GetStage() ] = {

				Pos = button,
				Label = nums[ button ]

			}
			self:SetStage( self:GetStage() + 1 )
			if self:GetStage() > 5 then
				self:Disarm()
				return
			end
			self:NewScreen()

		else
			self:GetBomb():Strike( self )
			self:StartSequence()
		end

	end

else
	
	local StageW = 24
	local StageH = 80
	local Padding = 4
	local C_GREEN = Color( 0,255,0 )
	local C_BG = Color( 255, 245, 150 )
	local Padding

	function MOD:Press( button )

		self:SendNet( button )

	end

	function MOD:Draw( w, h )

		Padding = 8
		surface.SetDrawColor( 50,50,50 )
		surface.DrawRect( w - StageW - Padding, h / 2 - StageH / 2, StageW, StageH )

		for i = -2, 2 do

			local x = w - StageW/2 - Padding
			local y = h/2 + -i * 15
			surface.SetDrawColor( self:GetStage() >= i + 4 and C_GREEN or color_black )
			surface.DrawRect( x - 8, y - 4, 16, 8 )


		end

		local ow, oh = w, h
		w, h = 84, StageH
		local x, y = Padding, oh / 2 - h/2
		surface.SetDrawColor(50,50,50)
		surface.DrawRect( x, y, w, h )
		Padding = 4

		// screen
		local CenterX = x + w/2
		surface.SetDrawColor( 0,0,20 )
		surface.DrawRect( x + Padding, y + Padding, w - Padding*2, 34 )
		local txt = self:GetScreen()
		if txt == 0 then return end
		draw.SimpleText( txt, "DermaLarge", CenterX, y + Padding + 34/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		// buttons

		local Spacing = 20
		local bw, bh = 16, 30
		surface.SetDrawColor( C_BG )
		local dist = Padding + 34

		local j = 0
		for i = -2, 2 do
			if i == 0 then continue end
			j = j + 1
			local ox, oy = x + w / 2, y + dist + ( h - dist )/2
			ox = ox + ( i + ( i < 0 and 0.5 or -0.5 ) ) * Spacing

			self:Button( ox - bw/2, oy - bh/2,
				bw, bh,
				C_BG,
				tostring( self:GetNumbers() ):sub( j,j ), "gothic_lg",color_black,
				4,
				nil,nil,
				false,false,
				self.Press,
				self,
				j
			)


		end

	end

end

