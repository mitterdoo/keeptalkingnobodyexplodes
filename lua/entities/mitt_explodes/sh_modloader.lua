ENT.ModuleTables = {}
local folder = "entities/mitt_explodes/modules/"
local files, folders = file.Find( folder .. "*.lua", "LUA" )
print( "NobodyExplodes Loading modules..." )
for _, mod in ipairs( files ) do
	_G.MOD = {}
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

	local techName = string.gsub( mod, "%..+", "" )
	_G.MOD.TechName = techName
	ENT.ModuleTables[ techName ] = _G.MOD
	_G.MOD = nil
end
print( "Finished!" )
