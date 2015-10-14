MOD.Name			= "Indicator"
MOD.Enabled			= true

/*

*/
MOD.Labels = {
	"SND",
	"CLR",
	"CAR",
	"IND",
	"FRQ",
	"SIG",
	"NSA",
	"MSA",
	"TRN",
	"BOB",
	"FRK"
}

function MOD:PickLabel()

	if !IsValid( self:GetBomb() ) then return "ERR" end

	local used = {}

	local list = self:GetBomb().Decorations
	for k, dec in pairs( list ) do
		if dec.TechName == self.TechName and dec != self then
			used[ dec:GetLabel() ] = true
		end
	end

	local picked = table.Random( self.Labels )

	return used[picked] and self:PickLabel() or picked

end

function MOD:OnStart() // called when the decoration is created

	self:NetworkVar( "String", "Label" )
	self:NetworkVar( "Bool", "Lit" )

	if SERVER then
		self:SetLabel( self:PickLabel() )
		self:SetLit( math.random(0,1) == 1 )
	end

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnEnd() // called when the module is removed

end

local C_BORDER = Color( 0x9D, 0x51, 0x4E )
local C_BG = Color( 0x25, 0x13, 0x12 )

local C_LIT = Color( 255,255,255 )
local C_UNLIT = Color( 80,80,80 )

local function circle( x, y, radius, col, seg )

	seg = seg or 8
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

function MOD:Draw( w, h )

	local w2, h2 = w/3*2, h/2
	draw.RoundedBox( 4, w/2 - w2/2, h/2 - h2/2, w2, h2, C_BORDER )

	local Padding = 4
	local w3, h3 = w2 * 0.6, h2 / 3 * 2
	draw.RoundedBox( 0, w/2 + w2/2 - w3 - Padding, h/2 - h3/2, w3, h3, C_BG )

	local x, y = w/2 + w2/2 - Padding - w3/2, h/2
	draw.SimpleText( self:GetLabel(), "Trebuchet18", x, y, Color( 255,255,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local space = w2 - w3

	circle( w/2 - w2 / 2 + space/2, h/2, h3/2, self:GetLit() and C_LIT or C_UNLIT, 10 )

end

