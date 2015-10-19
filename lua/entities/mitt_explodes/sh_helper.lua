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

// this is where most functions you will want to call will be
// 

if SERVER then

	function ENT:StartTimer( from )

		from = from or self:GetTime( true )
		self:SetStartTime( CurTime() )
		self:SetEndTime( CurTime() + from )
		self:SetMaxTime( from )
		self:SetPausedTime( 0 )
		self:SetPaused( false )

	end

	function ENT:PauseTimer()

		self:SetPausedTime( self:GetTime( true ) )
		self:SetPaused( true )

	end

	function ENT:ResumeTimer()

		self:SetPaused( false )
		self:SetStartTime( CurTime() )
		self:SetEndTime( CurTime() + self:GetPausedTime() )
		self:SetMaxTime( self:GetPausedTime() )
		self:SetPausedTime(0)

	end


	function ENT:SetTimerSpeed( speed )

		local cur = self:GetTime( true )
		if cur == 0 then return end
		self:SetStartTime( CurTime() )
		self:SetEndTime( CurTime() + cur * self.TimerSpeeds[ speed ] )
		self:SetMaxTime( cur )

	end

	function ENT:Strike( mod )

		if self:GetHardcore() then

			self:BlowUp()
			return

		end
		local strikes = self:GetStrikes()
		strikes = strikes + 1
		if strikes == 3 then
			self:BlowUp()
			return
		end

		self:SetLastStrike( CurTime() )
		self:SetLastStrikeModule( mod and mod:GetPosition() or 0 )
		self:SetStrikes( strikes )
		self:EmitSound( self.SndPath .. "strike.wav", 100, 100 )
		self:SetTimerSpeed( strikes + 1)

	end

	function ENT:GenerateSerial()

		local Serial = ""
		for i = 1, 5 do
			local rnd = math.random()
			if rnd < 1/3 then
				Serial = Serial .. math.random( 0,9 )
			else
				Serial = Serial .. string.char( math.random( 65,90 ) )
			end
		end
		Serial = Serial .. math.random(0,9)

		self:SetSerial( Serial )
		return Serial

	end

	function ENT:BlowUp()

		self:PauseTimer()

		local ent = ents.Create( "prop_physics" )
		ent:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
		ent:SetPos( self:GetPos() )
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():EnableMotion(false)
		timer.Simple( 0, function()
			ent:TakeDamage( 9999, self, self )
		end )

		self:Remove()


	end

	function ENT:Defuse()

		self:PauseTimer()
		self:SetDefused( true )
		self:SetDefuseTime( CurTime() )
		self:EmitSound( self.SndPath .. "bomb_defused.wav", 100,100 )
		timer.Simple( 1, function()

			if IsValid( self ) then
				self:EmitSound( self.SndPath .. "GameOver_Fanfare.ogg", 100, 100 )
			end

		end)

	end

end


// gets the value of what CurTime() will be when the timer displays the Target time on the clock in seconds
function ENT:GetCurTimeAtIndicatedTime( Target )

	local Speed = ( self:GetEndTime() - self:GetStartTime() ) / self:GetMaxTime()
	return self:GetEndTime() - Target * Speed

end

// does the indicator with this label exist (and is it lit?)
// label is required, if nothing in 'lit' arg, it will return if there is an indicator with the label
// if the lit arg is true or false, it will return if there is an indicator that is lit or not
function ENT:DoesIndicatorExist( label, lit )

	for k, v in pairs( self.Decorations ) do
		if v.TechName == "indicator" then

			if v:GetLabel() == label then

				if lit != nil and v:GetLit() == lit or v == nil then
					return true
				end

			end

		end
	end

	return false

end


// type is a string
function ENT:DoesPortExist( type )

	for k,v in pairs( self.Decorations ) do
		if v.TechName == "port" then

			if v.Ports[ v:GetPort() ] == type then
				return true
			end

		end
	end
	return false

end

function ENT:GetBatteryCount()

	local count = 0
	for k, v in pairs( self.Decorations ) do
		if v.TechName == "battery" then

			count = count + v:GetCount()

		end

	end
	return count

end

function ENT:GetTime( numOnly )

	local time
	if self:GetPaused() then
		time = self:GetPausedTime()
	else
		local percent = math.TimeFraction( self:GetStartTime(), self:GetEndTime(), CurTime() )
		percent = 1 - math.Clamp( percent, 0, 1 )

		time = percent * self:GetMaxTime()
	end

	if numOnly then return time end
	if time >= 60 then
		time = math.floor( time )
		time = string.FormattedTime( time, "%02i:%02i" )
	else
		time = math.floor( time * 100 ) / 100
		time = string.format( "%02i.%02i",
			math.floor( time ),
			time % 1 * 100
		)
	end
	return time

end

function ENT:GetModulesToDisarm()

	local disarm = {}
	for k, v in pairs( self.Modules ) do
		if !v.NotRequired and !v:GetDisarmed() then
			table.insert( disarm, v )
		end
	end
	return disarm
end
function ENT:GetModulesDisarmed()

	local disarmed = {}
	for k, v in pairs( self.Modules ) do
		if v:GetDisarmed() then
			table.insert( disarmed, v )
		end
	end
	return disarmed

end

function ENT:SerialHasVowels()

	local serial = string.lower( self:GetSerial() )
	for i = 1, #serial do
		if string.find( "aeiou", serial[i] ) then

			return true

		end
	end
	return false

end

function ENT:SerialIsEven()

	return tonumber( self:GetSerial()[6] ) % 2 == 0

end
function ENT:SerialIsOdd()

	return tonumber( self:GetSerial()[6] ) % 2 == 1

end


function ENT:DoesClockHaveDigit( digit )

	return tobool( string.find( tostring( self:GetTime() ), tostring( digit ) ) )

end