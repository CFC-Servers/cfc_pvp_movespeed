local isUndroppable = {
    weapon_physgun      = true,
    weapon_physcannon   = true,
    weapon_none         = true,
    gmod_tool           = true,
    gmod_camera         = true
}

local commands = {}
commands.drop = {
    ["!drop"] = true,
    ["/drop"] = true,
}
commands.dropall = {
    ["!dropall"] = true,
    ["/dropall"] = true,
    ["/strip"]   = true,
}

local function dropPlyWeapon( ply )
    local currentWeapon = ply:GetActiveWeapon()
    if isUndroppable[currentWeapon:GetClass()] then
        ply:ChatPrint("This weapon is unable to be dropped!")
        return
    end

    ply:DropWeapon( currentWeapon )
    
    currentWeapon.despawn = timer.Simple( 10, function()
        if not IsValid( currentWeapon ) then return end
        if IsValid( currentWeapon.Owner ) then return end

        currentWeapon:Remove()
    end)
end

local function dropAllWeapons( ply )
    setSpeedFromWeight( ply, 0 )
    ply:StripWeapons() 
end

local function onPlayerSay( ply, text )
    if not IsValid( ply ) then return end
    if not ply:Alive() then return end
    
    if commands.drop[text] then 
        dropPlyWeapon( ply )
    elseif commands.dropall[text] then
        dropAllWeapons( ply )
    else 
        return
    end
    return ""
end

hook.Remove("PlayerSay", "CFC_PlyMS_HandlePlySay")
hook.Add("PlayerSay", "CFC_PlyMS_HandlePlySay", onPlayerSay)

--Networking
util.AddNetworkString("dropPlayerWeapon")
util.AddNetworkString("dropAllWeapons")

net.Receive("dropPlayerWeapon", function( len, ply )
    dropPlyWeapon( ply )
end)

net.Receive("dropAllWeapons", function( len, ply )
    dropAllWeapons( ply )
end)

