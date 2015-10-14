MOD.Name			= "Complicated Wires"	// name of the module
MOD.Difficulty		= 1				// difficulty of the module
MOD.Needy			= false			// is a needy module
MOD.Enabled			= false			// should this module be used in game
MOD.ForceWithTimer	= false			// if this module requires the timer in view, make this true (e.g. button)

/*

	functions you can call on modules:
	MOD:GetBomb()		returns the bomb entity
	MOD:IsTimer()		returns if the module is the timer

*/


function MOD:OnStart() // called when the module is created

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnDisarm() // called when the module is disarmed

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:Draw( w, h )

end

function MOD:ScreenClicked( x, y )

end
