ENT.DecorationTables = {}
local folder = "entities/mitt_explodes/decoration/"
local files, folders = file.Find( folder .. "*.lua", "LUA" )
print( "NobodyExplodes Loading decorations..." )
for _, mod in ipairs( files ) do
	_G.MOD = {}
	AddCSLuaFile( folder .. mod )
	include( "sh_networking.lua" )
	include( "decoration/" .. mod )
	if !_G.MOD.Enabled then
		print( "> Skipping disabled decoration '" .. mod .. "'")
		_G.MOD = nil
		continue
	else
		print( "> Loaded " .. mod )
	end

	local techName = string.gsub( mod, "%..+", "" )
	_G.MOD.TechName = techName
	ENT.DecorationTables[ techName ] = _G.MOD
	_G.MOD = nil
end
print( "Finished!" )
