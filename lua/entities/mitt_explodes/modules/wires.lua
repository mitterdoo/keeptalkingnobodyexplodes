MOD.Name			= "Wires"	// name of the module
MOD.Difficulty		= 1				// difficulty of the module
MOD.Needy			= false			// is a needy module
MOD.Enabled			= true			// should this module be used in game
MOD.ForceWithTimer	= false			// if this module requires the timer in view, make this true (e.g. button)

/*

	functions you can call on modules:
	MOD:GetBomb()		returns the bomb entity
	MOD:IsTimer()		returns if the module is the timer

*/

MOD.ColorEnums = {
	RED = 1,
	BLUE = 2,
	YELLOW = 3,
	WHITE = 4,
	BLACK = 5
}
MOD.Colors = {
	Color( 255,0,0 ),
	Color( 0,0,255 ),
	Color( 255,255,0 ),
	Color( 255,255,255 ),
	Color( 0,0,0 )
}
function MOD:SetWire( wire, val )
	self[ "SetWire" .. wire ]( self, val )
end
function MOD:GetWire( wire )
	return self["GetWire" .. wire ](self)
end

function MOD:SetCutWires( tab )

	local cut = ""
	for i = 1, 6 do
		cut = cut .. ( tab[i] and "1" or "0" )
	end
	self:SetCutWiresInternal( math.BinToInt( cut ) )

end
function MOD:GetCutWires()

	local cut = {}
	local str = math.IntToBin( self:GetCutWiresInternal() )
	while #str < 6 do
		str = "0" .. str
	end
	if #str > 6 then
		str = str:sub( -6 )
	end

	for i = 1, 6 do
		cut[i] = str:sub(i,i) == "1"
	end
	return cut

end
function MOD:IsWireCut( x )
	return self:GetCutWires()[x]
end
function MOD:CutWire( x )

	local wires = self:GetCutWires()
	wires[x] = true
	self:SetCutWires( wires )

	if x != self:GetWireToCut() then
		self:GetBomb():Strike( self )
	else
		self:Disarm()
	end

end

function MOD:OnStart() // called when the module is created

	self:NetworkVar( "Int", "WireCount" )
	self:NetworkVar( "Int", "CutWiresInternal" )

	if SERVER then
		self:SetWireCount( math.random( 3,6 ) )
		//self:SetWireCount(6)
	end

	for i = 1, 6 do
		self:NetworkVar( "Int", "Wire" .. i )
	end

	if SERVER then

		local open = {1,2,3,4,5,6}
		for i = 1, self:GetWireCount() do
			local v, k = table.Random( open )
			self:SetWire( v, table.Random( self.ColorEnums ) )
			table.remove( open, k )
		end

	end

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnDisarm() // called when the module is disarmed


end

function MOD:OnEnd() // called when the module is removed

end


function MOD:GetNWire( num, ind )

	local count = 0
	for i = 1, 6 do
		if self:GetWire( i ) > 0 then
			count = count + 1
			if count == num then
				return ind and i or self:GetWire(i)
			end
		end
	end

end
function MOD:GetNColorWire( color, num, ind )

	local count = 0
	for i = 1, 6 do
		if self:GetWire( i ) == color then
			count = count + 1
			if count == num then
				return ind and i or self:GetWire(i)
			end
		end
	end
end

function MOD:GetNumOfColor( color )

	local count = 0
	for i = 1, 6 do
		if self:GetWire( i ) == color then
			count = count + 1
		end
	end
	return tonumber( tostring( count ) )

end

if SERVER then

	function MOD:GetNet( wire )

		self:CutWire( wire )

	end

	function MOD:GetWireToCut()

		local Count = self:GetWireCount()
		local Colors = self.ColorEnums

		if Count == 3 then
			if self:GetNumOfColor( Colors.RED ) == 0 then
				return self:GetNWire( 2, true )
			elseif self:GetNWire( 3 ) == Colors.WHITE then
				return self:GetNWire(3,true)
			elseif self:GetNumOfColor( Colors.BLUE ) > 1 then
				return self:GetNColorWire( Colors.BLUE, self:GetNumOfColor( Colors.BLUE ), true )
			else
				return self:GetNWire(3,true)
			end
		elseif Count == 4 then
			if self:GetNumOfColor( Colors.RED ) > 1 and self:GetBomb():SerialIsOdd() then
				return self:GetNColorWire( Colors.RED, self:GetNumOfColor( Colors.RED ), true )
			elseif self:GetNWire( 4 ) == Colors.YELLOW and self:GetNumOfColor( Colors.RED ) == 0 then
				return self:GetNWire( 1, true )
			elseif self:GetNumOfColor( Colors.BLUE ) == 1 then
				return self:GetNWire( 1, true )
			elseif self:GetNumOfColor( Colors.YELLOW ) > 1 then
				return self:GetNWire( 4, true )
			else
				return self:GetNWire( 2, true )
			end
		elseif Count == 5 then
			if self:GetNWire( 5 ) == Colors.BLACK and self:GetBomb():SerialIsOdd() then
				return self:GetNWire( 4, true )
			elseif self:GetNumOfColor( Colors.RED ) == 1 and self:GetNumOfColor( Colors.YELLOW ) > 1 then
				return self:GetNWire( 1, true )
			elseif self:GetNumOfColor( Colors.BLACK ) == 0 then
				return self:GetNWire( 2, true )
			else
				return self:GetNWire( 1, true )
			end
		elseif Count == 6 then
			if self:GetNumOfColor( Colors.YELLOW ) == 0 and self:GetBomb():SerialIsOdd() then
				return self:GetNWire( 3, true )
			elseif self:GetNumOfColor( Colors.YELLOW ) == 1 and self:GetNumOfColor( Colors.WHITE ) > 1 then
				return self:GetNWire( 4, true )
			elseif self:GetNumOfColor( Colors.RED ) == 0 then
				return self:GetNWire( 6, true )
			else
				return self:GetNWire( 4, true )
			end
		end

	end

end

if CLIENT then

	local Spacing = 15
	function MOD:Press( i )

		self:SendNet( i )
		return "weapons/c4/c4_plant.wav"

	end
	function MOD:Draw( w, h, mx, my, visible )

		for i = 1, 6 do

			if self:GetWire(i) == 0 then continue end
			local offset = ( i - 3 ) * 2 - 1
			local y = h / 2 + offset * Spacing/2


			local col = self.Colors[ self:GetWire( i ) ] or Color( 0,0,0 )

			if self:IsWireCut( i ) then
				surface.SetDrawColor( col )
				local w2 = w / 8 * 3.5
				surface.DrawRect( 0, y - 2, w2, 4 )
				surface.DrawRect( w - w2, y - 2, w2, 4 )
			else

				self:GetBomb():Button( 0, y - 2, w, 4, table.Copy( col ), nil, nil, nil, 0, nil, 0, false, self.Press, self, i )
			end

		end

	end

end

function MOD:ScreenClicked( x, y )

end
