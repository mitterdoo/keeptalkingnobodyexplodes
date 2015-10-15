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

