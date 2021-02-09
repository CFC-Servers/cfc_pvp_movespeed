CFCPvpMovespeed.isUndroppable = {
    weapon_physgun      = true,
    weapon_physcannon   = true,
    weapon_none         = true,
    gmod_tool           = true,
    gmod_camera         = true
}

CFCPvpMovespeed.commands = {
    drop = {
        ["!drop"] = true,
        ["/drop"] = true,
    },

    dropall = {
        ["!dropall"] = true,
        ["/dropall"] = true,
        ["/strip"]   = true,
    }
}

function CFCPvpMovespeed:dropPlyWeapon( ply )
    local currentWeapon = ply:GetActiveWeapon()

    if not IsValid( currentWeapon ) or self.isUndroppable[currentWeapon:GetClass()] then
        ply:ChatPrint( "This weapon is unable to be dropped!" )
        return
    end

    ply:DropWeapon( currentWeapon )

    currentWeapon.despawn = timer.Simple( 10, function()
        if not IsValid( currentWeapon ) then return end
        if IsValid( currentWeapon.Owner ) then return end

        currentWeapon:Remove()
    end )
end

function CFCPvpMovespeed:dropAllWeapons( ply )
    self:setSpeedFromWeight( ply, 0 )
    ply:StripWeapons()
end

function CFCPvpMovespeed:OnPlayerSay( ply, text )
    if not IsValid( ply ) then return end
    if not ply:Alive() then return end

    if self.commands.drop[text] then
        dropPlyWeapon( ply )
        return ""
    end

    if self.commands.dropall[text] then
        dropAllWeapons( ply )
        return ""
    end
end

hook.Remove( "PlayerSay", "CFC_PlyMS_HandlePlySay" )
hook.Add( "PlayerSay", "CFC_PlyMS_HandlePlySay", function( ... ) CFCPvpMovespeed:OnPlayerSay( ... ) end )

-- Networking
util.AddNetworkString( "CFC_PvpMovespeed_dropPlayerWeapon" )
util.AddNetworkString( "CFC_PvpMovespeed_dropAllWeapons" )

net.Receive( "CFC_PvpMovespeed_dropPlayerWeapon", function( len, ply )
    CFCPvpMovespeed:dropPlyWeapon( ply )
end )

net.Receive( "CFC_PvpMovespeed_dropAllWeapons", function( len, ply )
    CFCPvpMovespeed:dropAllWeapons( ply )
end )

