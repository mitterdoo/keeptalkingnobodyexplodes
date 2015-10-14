MOD.Name			= "Skeleton"	// name of the module
MOD.Difficulty		= 1				// difficulty of the module
MOD.Needy			= false			// is a needy module
MOD.Enabled			= false			// should this module be used in game
MOD.ForceWithTimer	= false			// if this module requires the timer in view, make this true (e.g. button)
// MOD.Rarity		= 2				// if MOD.Rarity exists, the bomb will call math.random( 1, Rarity ) and add the module if it returns 1

/*

	functions you can call on modules:
	MOD:GetBomb()		returns the bomb entity
	MOD:IsTimer()		returns if the module is the timer

*/


function MOD:OnStart() // called when the module is created

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnDisarm() // called when the module is disarmed WILL NOT BE CALLED IMMEDIA

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:Draw( w, h )

end

if SERVER then

	// called when the server receives a valid net message from the player
	// receives one 32-bit integer as each argument.
	function MOD:GetNet()

	end
	// you should also keep the module logic here so any script kiddies can't be a function call away from a bot.

end

// for sending a net message from the client(i.e. a button press), use self:SendNet( args ) with 32-bit integers for each argument only
// the server will verify the message comes from the bomb's player and other things too like if the player is in range.

