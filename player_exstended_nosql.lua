
local meta = FindMetaTable( "Player" )

-- Return if there's nothing to add on to
if (!meta) then return end



function meta:GetCurrentLevel()
	return self.m_CurrentLevel
end

function meta:GetCurrentXP()
	return self.m_CurentXP
end

function meta:GetRequiredNextLevel()
	return self.m_RequiredNextLevel
end

function meta:GetBaseXP()
	return self.m_baseXP
end

function meta:GiveXP( amount )
	if ( ( self.m_CurentXP + amount ) >= self.m_RequiredNextLevel ) then
		self.m_TempXPStorage = ( self.m_CurentXP + amount )
		self.m_CurrentLevel = self.m_CurrentLevel + 1
		self.m_baseXP = self.m_RequiredNextLevel
		self.m_RequiredNextLevel = self.m_RequiredNextLevel + ( math.floor ( self.m_RequiredNextLevel * 0.4 ) )
			if( self.m_TempXPStorage >= self.m_RequiredNextLevel ) then
				self:GiveXP( self.m_TempXPStorage )
				return
			end
			self.m_CurentXP = self.m_CurentXP + amount
			GAMEMODE:PlayerLeveldUp( self, self.m_CurrentLevel, self.m_baseXP, self.m_CurentXP, self.m_RequiredNextLevel  )
	else
		self.m_CurentXP = self.m_CurentXP + amount
		GAMEMODE:UpdatePlayerStats( self, self.m_CurentXP )
	end
	self.m_TempXPStorage = 0
end


function meta:AddItemToDataBase( rarety, object )

	for k, v in pairs( self.m_Inventory ) do
		if ( k == rarety ) then
			for p, j in pairs( v ) do
				if ( p == 'ghostitem' ) then
					v[ p ] = v[ object ]
					v[ object ] = 1 
					break
				end
				if ( p == object ) then
					v[ object ] = j+1
					break
				end
				v[ object ] = 1
			end
		end
	end
	GAMEMODE:SaveData( self )
end

function meta:RemoveItemFromDataBase( rarety, object )
local oldTable = table.Copy( self.m_Inventory[ rarety ] )
table.Empty( self.m_Inventory[ rarety ] )
	if( GAMEMODE:GetTableLength( oldTable ) ) then
		for k, v in pairs( oldTable ) do
			if ( k == object ) then continue end
			self.m_Inventory[ rarety ][ k ] = v
		end
	else
		for k, v in pairs( oldTable ) do
			self.m_Inventory[ rarety ][ k ] = self.m_Inventory[ rarety ][ 'ghostitem' ]
			self.m_Inventory[ rarety ][ 'ghostitem' ] = 1
		end
	end
	GAMEMODE:SaveData( self )
end

function meta:GetInventory()
	return self.m_Inventory
end

function meta:GetTitle()
	return self.m_CurrentTitle
end

function meta:SetPlayerTitle( title ) 
	self.m_CurrentTitle = title
end