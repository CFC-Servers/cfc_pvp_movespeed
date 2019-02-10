-- Includes --
include( "autorun/shared/sh_pvp_movespeed.lua" )
AddCSLuaFile( "autorun/shared/sh_pvp_movespeed.lua" )

-- default run and walk speed with 0 weapons
local baseRunSpeed = 400
local baseWalkSpeed = 200

-- minimum run and walk speed (must be greater than 0)
local minRunSpeed = 70
local minWalkSpeed = 35

--Weapon weights, weapons not in the table have a weight of 1
local weaponWeights = {
    weapon_physgun    = 0,
    weapon_physcannon = 0,
    none              = 0,
    laserpointer      = 0,
    remotecontroller  = 0,
    gmod_tool         = 0,
    gmod_camera       = 0,
    weapon_357        = 0,
    weapon_ar2        = 0,
    weapon_crossbow   = 0,
    weapon_crowbar    = 0,
    weapon_pistol     = 0,
    weapon_shotgun    = 0,
    weapon_smg1       = 0,
    weapon_medkit     = 0,
    weapon_frag       = 0,
    weapon_rpg        = 0,
    weapon_fists      = 0,
    m9k_fists         = 0
}

local isUndroppable = {
    weapon_physgun      = true,
    weapon_physcannon   = true,
    weapon_none         = true,
    gmod_tool           = true,
    gmod_camera         = true
}

local isDropCommand = {
    "!drop" = true,
    "/drop" = true,
}

-- Helper Functions --
local cfcHookPrefix = "CFC_PlyMS_"
local function generateCFCHook( hookname )
    return cfcHookPrefix .. hookname
end

local function getPlayerPvpMode( ply )
    return ply:GetNWBool( "CFC_PvP_Mode", false )
end

local function playerIsInBuild( ply )
    return !getPlayerPvpMode( ply )
end

local function movementMultiplier( totalWeight )
    if totalWeight < 1 then return 1 end
    local multiplier = 1 - ( 1.9 ^ totalWeight  )/ 100
    return math.Clamp(multiplier, 0, 1)
end

local function setSpeedFromWeight( ply, totalWeight )
    local multiplier = movementMultiplier( totalWeight )

    local newRunSpeed = baseRunSpeed * multiplier
    local newWalkSpeed = baseWalkSpeed * multiplier
    ply:SetRunSpeed( math.max( newRunSpeed, minRunSpeed ) )
    ply:SetWalkSpeed( math.max( newWalkSpeed, minWalkSpeed ) )

    if newWalkSpeed < 100 then
        ply:ChatPrint("You are holding too many weapons! Drop some to regain speed.")
        ply:SetCanWalk( false )
    else
        ply:SetCanWalk( true )
    end
end

local function getWeaponWeight( weapon )
    return weaponWeights[weapon:GetClass()] or 1
end

local function getPlayerWeight( ply ) 
    if playerIsInBuild( ply ) then return 0 end
    local weapons = ply:GetWeapons()
    local totalWeight = 0
    for _, weapon in pairs( weapons ) do
        totalWeight = totalWeight + getWeaponWeight( weapon )
    end
    return totalWeight
end

local function dropPlyWeapon( ply )
    local currentWeapon = ply:GetActiveWeapon():GetClass()
    if isUndroppable[currentWeapon] then
        ply:ChatPrint("This weapon is unable to be dropped!")
        return
    end

    ply:StripWeapon( currentWeapon )

    local gun = ents.Create( currentWeapon )
    gun:SetModel( gun:GetWeaponWorldModel() )
    gun:SetPos( ply:LocalToWorld( ply:OBBCenter() ) + (ply:GetForward()*15) )
    gun:Spawn()
    gun.despawn = timer.Simple( 10, function()
        if not IsValid( gun ) then return end

        gun:Remove()
    end)
end

-- Hook Functions --
local function onEquip( wep, ply )
    if not IsValid( ply ) then return end
    local totalWeight = getPlayerWeight( ply ) + getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end

local function onDrop( ply, wep )
    if not IsValid( ply ) then return end
    local totalWeight = getPlayerWeight( ply ) - getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end

local function onPlayerSay( ply, text )
    if not IsValid( ply ) then return end
    if not ply:Alive() then return end
    
    if isDropCommand[text] then 
        dropPlyWeapon( ply )
        return
    end 
end

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquip)

hook.Remove("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"))
hook.Add("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"), onDrop)

hook.Remove("PlayerSay", generateCFCHook("HandlePlySay"))
hook.Add("PlayerSay", generateCFCHook("HandlePlySay"), onPlayerSay)

--Networking
util.AddNetworkString("dropPlayerWeapon")

net.Receive("dropPlayerWeapon", function( len, ply )
    dropPlyWeapon( ply )
end)