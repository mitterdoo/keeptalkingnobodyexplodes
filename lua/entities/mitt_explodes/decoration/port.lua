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

MOD.Name			= "Port"	// name of the decoration
MOD.Enabled			= true			// should this decoration be used in game

/*

*/

MOD.Ports = {
	"DVI-D",
	"Parallel",
	"PS/2",
	"RJ-45",
	"Serial",
	"Stereo RCA"
}

function MOD:OnStart() // called when the decoration is created

	self:NetworkVar( "String", "Port" )
	if SERVER then
		self:SetPort( table.Random( self.Ports ) )
	end

end

function MOD:Think() // called every think of the bomb entity

end

function MOD:OnEnd() // called when the module is removed

end

function MOD:Draw( w, h )

	draw.SimpleText( "PORT: " .. self:GetPort(), "ChatFont", w/2, h/2, Color( 255,0,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

end

