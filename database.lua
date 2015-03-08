


// Let's make sure this shit exists.
hook.Add( 'Initialize', 'noSQL', function()
	util.AddNetworkString( "playerLeveledUp" )
	util.AddNetworkString( "sendLevelStats" )
	util.AddNetworkString( "updateLevelStats" )
	util.AddNetworkString( "foundItem" )
	util.AddNetworkString( "sendInventory" )
	
	
	if ( !file.IsDir("noSQL","DATA") ) then
		file.CreateDir("noSQL")
	end 
end )

function GM:PlayerLeveldUp( pl, newLevel, baseXP, currentXP, newRequirements  )
	net.Start( "playerLeveledUp" )
		net.WriteFloat( newLevel )
		net.WriteFloat( baseXP )
		net.WriteFloat( currentXP )
		net.WriteFloat( newRequirements )
	net.Send( pl )
end


function GM:PlayerFoundItem( pl, color, rarety, item  )
	net.Start( "foundItem" )
		net.WriteVector( color )
		net.WriteString( rarety )
		net.WriteString( item )
	net.Send( pl )
end


hook.Add( "OnNPCKilled", "test", function( npc, pl, weapon )
	if( IsValid( pl ) && pl:IsPlayer() ) then 
		pl:GiveXP( math.random( 50, 100 ) )
		if ( math.random( 1, 5 ) == 2 ) then
			if ( math.random( 1, 3 ) == 1 ) then
				pl:AddItemToDataBase( "rare", "empty shells" )
				GAMEMODE:PlayerFoundItem( pl, Vector( 255, 0, 0 ), "rare", "empty shells"  )
			end
			if ( math.random( 1, 3 ) == 3 ) then
				pl:AddItemToDataBase( "special", "cloth" )
				GAMEMODE:PlayerFoundItem( pl, Vector( 0, 255, 0 ), "special", "Piece of cloth"  )
			end
		end
	end
end )

function GM:UpdatePlayerStats( pl, currentXP, newRequirements )
	net.Start( "updateLevelStats" )
		net.WriteFloat( currentXP )
	net.Send( pl )
end

function GM:SendPlayerLevelData( pl, newLevel, baseXP, currentXP, newRequirements )
	net.Start( "sendLevelStats" )
		net.WriteFloat( newLevel )
		net.WriteFloat( baseXP )
		net.WriteFloat( currentXP )
		net.WriteFloat( newRequirements )
	net.Send( pl )
end

//So this shit exists, but does it for the player?
hook.Add( 'PlayerInitialSpawn', 'noSQL Read Data', function( pl )
	GAMEMODE:ReadData( pl )
	GAMEMODE:SendPlayerLevelData( pl, pl:GetCurrentLevel(), pl:GetBaseXP(), pl:GetCurrentXP(), pl:GetRequiredNextLevel() )
end )

//Empty data here :v
function GM:GetBlankStats( pl )
	local data = {
		[ 'namePlayer' ] = pl:Nick(),
		[ 'steamIDPlayer' ] = pl:SteamID(),
		[ 'playTimePlayer' ] = 0,
		[ 'inventory' ] = 
		{
			[ 'generic' ] =
			{
				[ 'ghostitem' ] = 1,
			},
			[ 'special' ] =
			{
				[ 'ghostitem' ] = 1,
			},
			[ 'rare' ] =
			{
				[ 'ghostitem' ] = 1,
			},
		},
		[ 'achievements' ] =
		{
		},
		[ 'title' ] = "NEWBY",
		[ 'money' ] = 0,
		[ 'level' ] = 
		{
			[ 'curentLevel' ] = 0,
			[ 'curentXP' ] = 0,
			[ 'requiredNextLevel' ] = 250,
			[ 'baseXP' ] = 0, //for hud's and stuff
			[ 'tempXPStorage' ] = 0,
		},
		
	}
		
	
	return data
end

function GM:WriteBlank( pl )

	local path = "noSQL/player_"..string.Replace( string.sub( pl:SteamID(), 1 ), ":", "-" )..".txt"
	local data = util.TableToJSON( self:GetBlankStats( pl ) )

		file.Write( path, data )

end


function GM:ReadData( pl )
	local path = "noSQL/player_"..string.Replace( string.sub( pl:SteamID(), 1 ), ":", "-" )..".txt"
	if ( !file.Exists( path , "DATA") ) then
		GAMEMODE:WriteBlank( pl )
		for _, v in pairs( player.GetAll() ) do 
			if IsValid( v ) then
				v:ChatPrint( "Welcome "..pl:Nick().." as he has joined for the first time!" )
			end
		end
	end
	fileData = util.JSONToTable( file.Read( path ) )
	pl.DataTable = table.Copy( fileData )
	
	for k, v in pairs( pl.DataTable ) do
		if( k == 'title' ) then
			pl.m_CurrentTitle = v
		end
		if( k == 'money' ) then
			pl.m_CurrentMoney = v
		end
		if ( k == 'inventory' ) then
			pl.m_Inventory = v
		end
		if ( k == 'level' ) then
			for p, j in pairs( v ) do
				if( p == 'tempXPStorage' ) then
					pl.m_TempXPStorage = j
				end
				if ( p == 'curentLevel' ) then
					pl.m_CurrentLevel = j
				end
				if ( p == 'curentXP' ) then
					pl.m_CurentXP = j
				end
				if ( p == 'requiredNextLevel' ) then
					pl.m_RequiredNextLevel = j
				end
				if ( p == 'baseXP' ) then
					pl.m_baseXP = j
				end
			end
		end
	end
	
end

function GM:SetNewTitle( pl, title )
	pl:SetPlayerTitle( title ) 
end

function GM:SaveData( pl )
	local path = "noSQL/player_"..string.Replace( string.sub( pl:SteamID(), 1 ), ":", "-" )..".txt"
		local data = {
			[ 'namePlayer' ] = pl:Nick(),
			[ 'steamIDPlayer' ] = pl:SteamID(),
			[ 'playTimePlayer' ] = 0,
			[ 'inventory' ] = pl:GetInventory(),
			[ 'achievements' ] =
				{
				},
			[ 'title' ] = pl:GetTitle() || "NEWBY",
			[ 'money' ] = 0,
			[ 'level' ] = 
				{
					[ 'curentLevel' ] = pl:GetCurrentLevel(),
					[ 'curentXP' ] = pl:GetCurrentXP(),
					[ 'requiredNextLevel' ] = pl:GetRequiredNextLevel(),
					[ 'baseXP' ] = pl:GetBaseXP(), //for hud's and stuff
					[ 'tempXPStorage' ] = 0,
				},
		}
		
	local newData =  util.TableToJSON( data )
	file.Write( path, newData )
end



function GM:GetTableLength( dbTable )
	local count = 0
		for k, v in pairs( dbTable ) do
			count = count + 1
		end
		
	if ( count > 1 ) then
		return true
	end
	return false
end

concommand.Add( 'testDB', function( pl, cmd, args )
	for k, v in pairs( player.GetAll() ) do
		if ( !IsValid( v ) ) then continue end
		if ( v:Nick() == args[ 1 ] ) then
			local path = "noSQL/player_"..string.Replace( string.sub( pl:SteamID(), 1 ), ":", "-" )..".txt"
				PrintTable( util.JSONToTable( file.Read( path ) ) )
			break;
		end
	end

end )

concommand.Add( "AddItemToDB", function( pl, cmd, args )
	pl:AddItemToDataBase( args[ 1 ], args[ 2 ] )
end )

concommand.Add( "RemoveItemFromDB", function( pl, cmd, args )
	pl:RemoveItemFromDataBase( args[ 1 ], args[ 2 ]  )
end )

concommand.Add( "giveXP", function( pl, cmd, args )
	if( args[ 1 ] && IsValid( pl ) ) then
		print( args[ 1 ] )
		pl:GiveXP( tonumber( args[ 1 ] ) )
	end
end )

concommand.Add( "readfile", function( pl )
	GAMEMODE:ReadData( pl )
end )

concommand.Add( "saveData", function( pl )
	GAMEMODE:SaveData( pl )
end )

concommand.Add( "setTitle", function( pl, cmd, args )
	GAMEMODE:SetNewTitle( pl, args[ 1 ] )
end )

