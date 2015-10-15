/*
The MIT License (MIT)

Copyright (c) 2015 mitterdoo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
*/
MOD.Name			= "Morse Code"	// name of the module
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
