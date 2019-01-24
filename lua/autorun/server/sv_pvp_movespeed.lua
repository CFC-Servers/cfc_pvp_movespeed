-- Includes --
include( "autorun/shared/sh_pvp_movespeed.lua" )
AddCSLuaFile( "autorun/shared/sh_pvp_movespeed.lua" )

-- default run and walk speed with 0 weapons
local baseRunSpeed = 400
local baseWalkSpeed = 200

-- minimum run and walk speed (must be greater than 0)
local minRunSpeed = 70
local minWalkSpeed = 35

--List of weapons that will not be affected of the players movement speed
local nonEffectedWeapons = {
    weapon_physgun    = true,
    weapon_physcannon = true,
    none              = true,
    laserpointer      = true,
    remotecontroller  = true,
    gmod_tool         = true,
    gmod_camera       = true,
    weapon_357        = true,
    weapon_ar2        = true,
    weapon_crossbow   = true,
    weapon_crowbar    = true,
    weapon_pistol     = true,
    weapon_shotgun    = true,
    weapon_smg1       = true,
    weapon_medkit     = true,
    weapon_frag       = true,
    weapon_rpg        = true,
    weapon_fists      = true,
    m9k_fists         = true
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
    -- the weight/significance of a weapon (1 for affecting weight 0 for not affecting weight)
    if nonEffectedWeapons[weapon:GetClass()] then return 0 end
    return 1
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

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquip)

hook.Remove("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"))
hook.Add("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"), onDrop)
