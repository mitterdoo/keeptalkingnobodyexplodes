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

ENT.DecorationTables = ENT.DecorationTables or {}
local folder = "entities/mitt_explodes/decoration/"
local files, folders = file.Find( folder .. "*.lua", "LUA" )
//print( "NobodyExplodes Loading decorations..." )
for _, mod in ipairs( files ) do

	local techName = string.gsub( mod, "%..+", "" )

	_G.MOD = ENT.DecorationTables[ techName ] or {}
	AddCSLuaFile( folder .. mod )
	include( "sh_networking.lua" )
	include( "decoration/" .. mod )
	if !_G.MOD.Enabled then
		//print( "> Skipping disabled decoration '" .. mod .. "'")
		_G.MOD = nil
		continue
	else
		//print( "> Loaded " .. mod )
	end

	_G.MOD.TechName = techName
	ENT.DecorationTables[ techName ] = _G.MOD
	_G.MOD = nil
end
//print( "Finished!" )
