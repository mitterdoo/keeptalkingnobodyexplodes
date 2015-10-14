MOD.Name			= "Serial"	// name of the decoration
MOD.Enabled			= true			// should this decoration be used in game

/*

*/


function MOD:OnStart() // called when the decoration is created

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:Draw( w, h )

	surface.SetDrawColor( 255,0,0 )
	surface.DrawRect( 0, 0, w, h )

	local headerSpacing = 24
	surface.SetDrawColor( 255,255,255 )
	surface.DrawRect( 0, headerSpacing, w, h - headerSpacing )

	draw.SimpleText( "SERIAL #", "ChatFont", w / 2, headerSpacing/2, Color( 255,255,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	local serial = self:GetBomb():GetSerial()
	if #serial != 6 then
		serial = "??????"
	end

	draw.SimpleText( serial, "ChatFont", w/2, headerSpacing + ( h - headerSpacing ) / 2, Color( 0,0,0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

end

