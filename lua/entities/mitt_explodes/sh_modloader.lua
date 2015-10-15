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
ENT.ModuleTables = ENT.ModuleTables or {}
local folder = "entities/mitt_explodes/modules/"
local files, folders = file.Find( folder .. "*.lua", "LUA" )
print( "NobodyExplodes Loading modules..." )
for _, mod in ipairs( files ) do

	local techName = string.gsub( mod, "%..+", "" )

	print( ENT.ModuleTables[ techName ] )
	_G.MOD = ENT.ModuleTables[ techName ] or {}
	AddCSLuaFile( folder .. mod )
	include( "sh_networking.lua" )
	include( "modules/" .. mod )
	if !_G.MOD.Enabled then
		print( "> Skipping disabled module '" .. mod .. "'")
		_G.MOD = nil
		continue
	else
		print( "> Loaded " .. mod )
	end

	_G.MOD.TechName = techName
	ENT.ModuleTables[ techName ] = _G.MOD
	_G.MOD = nil
end
print( "Finished!" )
