MOD.Name			= "Skeleton"	// name of the decoration
MOD.Enabled			= false			// should this decoration be used in game
// MOD.Rarity		= 2				// // if MOD.Rarity exists, the bomb will call math.random( 1, Rarity ) and add the module if it returns 1

/*
	functions you can call:

	MOD:GetBomb()	returns bomb entity
	MOD:IsSerial()	returns if this decoration is the serial #

*/


function MOD:OnStart() // called when the decoration is created

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnEnd() // called when the decoration is removed

end

function MOD:Draw( w, h )

end

