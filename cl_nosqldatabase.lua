
local w, h = ScrW(), ScrH()

local noSQL = {
	playerLevel = 0,
	drawTimeLeveledUp = 0,
	newPlayerLevel = 0,
	curXPAmount = 0,
	newXPAmount = 0,
	newXPbase = 0,
	maxBarLength = w * 0.3,
	maxBarHeight = h * 0.02,
	wPos = w * 0.35,
	hPos = 0,
	color = Color( 40, 40, 40, 255 ),
}



net.Receive( "updateLevelStats", function()
	noSQL.curXPAmount = net.ReadFloat()
end )

net.Receive( "sendLevelStats", function()
	noSQL.newPlayerLevel = net.ReadFloat()
	noSQL.newXPbase = net.ReadFloat()
	noSQL.curXPAmount = net.ReadFloat()
	noSQL.newXPAmount = net.ReadFloat()

end )


net.Receive( "foundItem", function()
	itemRaretyColor = net.ReadVector()
	itemRarety = net.ReadString()
	itemFound = net.ReadString()
	chat.AddText( Color( 245, 115, 37, 255 ), "[ noSQL ]", Color (  220, 220, 255, 255 ), "You Found a ", Color( itemRaretyColor.x, itemRaretyColor.y, itemRaretyColor.z, 255 ), "[ "..itemRarety.. " ] ", Color( 220, 220, 255, 255 ), itemFound  )
end )

net.Receive( "playerLeveledUp", function()
	noSQL.newPlayerLevel = net.ReadFloat()
	noSQL.newXPbase = net.ReadFloat()
	noSQL.curXPAmount = net.ReadFloat()
	noSQL.newXPAmount = net.ReadFloat()
	

	if( ( noSQL.newXPAmount - noSQL.curXPAmount ) >= 1000 ) then
	local chatNewXPAmount = math.floor( ( ( noSQL.newXPAmount - noSQL.curXPAmount ) / 1000 ) )
		chat.AddText( Color( 245, 115, 37, 255 ), "[ noSQL ]", Color( 220, 220, 255, 255 ), "you reached level: "..noSQL.newPlayerLevel.. "!" )
		chat.AddText( Color( 245, 115, 37, 255 ), "[ noSQL ]", Color (  220, 220, 255, 255 ), "You will need " ..string.format("%.0f", tostring( chatNewXPAmount ) ).. "K to level up again!"  )
	else
		chat.AddText( Color( 245, 115, 37, 255 ), "[ noSQL ]", Color( 220, 220, 255, 255 ), "you reached level: "..noSQL.newPlayerLevel.. "!" )
		chat.AddText( Color( 245, 115, 37, 255 ), "[ noSQL ]", Color (  220, 220, 255, 255 ), "You will need " ..( noSQL.newXPAmount - noSQL.curXPAmount ).. " to level up again!"  )
	end
end )

local length = 0

local barBase = {
	{ x = noSQL.wPos, y = noSQL.hPos }, 
	{ x = noSQL.wPos +  noSQL.maxBarLength, y = noSQL.hPos  },
	{ x = noSQL.wPos + ( noSQL.maxBarLength - ( w * 0.05 ) ), y = noSQL.hPos + ( h * 0.025 ) },
	{ x = noSQL.wPos + ( w * 0.05 ), y = noSQL.hPos + ( h * 0.025 ) },
	} 

hook.Add( "HUDPaint", "displayCurentLevel", function()
	local newAmount = noSQL.newXPAmount - noSQL.newXPbase
	local newAmount2 = noSQL.curXPAmount - noSQL.newXPbase
	
	local ourCalc =  math.min( (  noSQL.maxBarLength * ( newAmount2 / newAmount ) ), noSQL.maxBarLength )
	length = math.Approach( length, ourCalc, FrameTime() * 120 )

	surface.SetDrawColor( noSQL.color ) 
	draw.NoTexture()
	surface.DrawPoly( barBase )
	
		local animatedBar = { 
	{ x = noSQL.wPos, y = noSQL.hPos }, 
	{ x = math.min( noSQL.wPos + ( length  ), noSQL.wPos +  noSQL.maxBarLength ) , y = noSQL.hPos  },
	{ x = math.min( noSQL.wPos + ( length + ( w * 0.05 ) ), noSQL.wPos + ( noSQL.maxBarLength  - ( w * 0.05 ) )  ) , y = noSQL.hPos + ( h * 0.025 ) }, 
	{ x = noSQL.wPos + ( w * 0.05 ), y = noSQL.hPos + ( h * 0.025 ) },
	} 
	
	surface.SetDrawColor( 255, 155, 37, 255 )
	draw.NoTexture()
	surface.DrawPoly( animatedBar )
	
	draw.SimpleText( "Level: "..noSQL.newPlayerLevel.." | "..string.format("%.0f", tostring( ( math.floor( ( noSQL.newXPAmount - noSQL.curXPAmount ) / 1000	 ) ) ) ) .. "k", "TargetID", noSQL.wPos + ( noSQL.maxBarLength / 2 ) , ( noSQL.maxBarHeight / 2 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end )