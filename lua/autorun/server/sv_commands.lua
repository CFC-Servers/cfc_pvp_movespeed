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

local dropCooldown = 1

local function isOnCooldown( ply )
    if not ply.WeaponDropCooldown then
        ply.WeaponDropCooldown = 0
        return false
    end

    if ply.WeaponDropCooldown > CurTime() then
        ply:PrintMessage( 4, "You cannot drop your weapon(s) yet!" )
        return true
    end
    ply.WeaponDropCooldown = CurTime() + dropCooldown
end

local function dropPlyWeapon( ply )
    if isOnCooldown( ply ) then return end

    local currentWeapon = ply:GetActiveWeapon()

    if not IsValid( currentWeapon ) or isUndroppable[currentWeapon:GetClass()] then
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

local function dropAllWeapons( ply )
    if isOnCooldown( ply ) then return end

    pvpMoveSpeed.setSpeedFromWeight( ply, 0 )

    for _, weapon in ipairs( ply:GetWeapons() ) do
        ply:StripWeapon( weapon:GetClass() )
    end
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

hook.Add( "PlayerSay", "CFC_PlyMS_HandlePlySay", onPlayerSay )

concommand.Add( "cfc_dropweapon", dropPlyWeapon )
concommand.Add( "cfc_dropallweapons", dropAllWeapons )
