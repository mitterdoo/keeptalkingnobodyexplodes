MOD.NetworkTypes = {}

local function badType( val, default )
	local t = type( val )
	if t == "number" and val % 1 != 0 and default == "Int" then
		return true, "Float"
	elseif t != "string" and default == "String" or
	t != "boolean" and default == "Bool" or
	t != "Vector" and default == "Vector" or
	t != "Angle" and default == "Angle" or
	t != "Entity" and default == "Entity" then
		return true, t
	else
		return false
	end
end


function MOD:NetworkVar( vtype, name, size )

	print( "CREATING NET VAR", self.TechName, vtype, name, size )

	local bomb = self:GetBomb()

	self.NetworkTypes[ name ] = vtype	

	if SERVER then
		self[ "Set" .. name ] = function( self, value )
			local isBad, valType = badType( value, self.NetworkTypes[ name ] )
			if isBad then
				ErrorNoHalt( "Type mismatch! Expected " .. self.NetworkTypes[ name ] .. " got " .. valType .. "\n" )
				return
			end
			if IsValid( self:GetBomb() ) then
				self:GetBomb()[ "SetNW" .. self.NetworkTypes[ name ] ]( self:GetBomb(), self.UniqueID .. "_" .. name, value )
			end
		end
	end
	self[ "Get" .. name ] = function( self )

		if !IsValid( self:GetBomb() ) then
			return self.DefaultValues[ self.NetworkTypes[ name ] ]
		end
		return self:GetBomb()["GetNW" .. self.NetworkTypes[ name ] ]( self:GetBomb(), self.UniqueID .. "_" .. name )
		//return self.NetworkedVars[ name ] or self.DefaultValues[ self.NetworkTypes[ name ] ]

	end

	//self:SendVar( name )

end
