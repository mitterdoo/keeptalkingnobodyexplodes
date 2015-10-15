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
	MOD:NetworkVar( string type, string name ) works exactly like ENT:NetworkVar, except there is no index 2nd argument. creates the Get and Set functions.

*/


function MOD:OnStart() // called when the module is created (call MOD:NetworkVar here)

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnDisarm() // called when the module is disarmed. WILL NOT BE CALLED THE INSTANT IT IS DISARMED ON CLIENT

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

