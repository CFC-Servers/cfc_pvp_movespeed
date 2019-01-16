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
local nonEffectedWeapons = {}
nonEffectedWeapons.weapon_physgun    = true
nonEffectedWeapons.weapon_physcannon = true
nonEffectedWeapons.none              = true
nonEffectedWeapons.laserpointer      = true
nonEffectedWeapons.remotecontroller  = true
nonEffectedWeapons.gmod_tool         = true
nonEffectedWeapons.gmod_camera       = true
nonEffectedWeapons.weapon_357        = true
nonEffectedWeapons.weapon_ar2        = true
nonEffectedWeapons.weapon_crossbow   = true
nonEffectedWeapons.weapon_crowbar    = true
nonEffectedWeapons.weapon_pistol     = true
nonEffectedWeapons.weapon_shotgun    = true
nonEffectedWeapons.weapon_smg1       = true
nonEffectedWeapons.weapon_medkit     = true
nonEffectedWeapons.weapon_frag       = true
nonEffectedWeapons.weapon_rpg        = true

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

local function movementMultiplier( weaponCount )
    if weaponCount < 1 then return 1 end
    return math.Clamp(1 - (1.9^( weaponCount))/100, 0, 1)
end

local function setSpeedFromWeaponCount( ply, weaponCount )
    local multiplier = movementMultiplier( weaponCount )

    local runSpeed = baseRunSpeed * multiplier
    local walkSpeed = baseWalkSpeed * multiplier
    ply:SetRunSpeed( math.max( runSpeed, minRunSpeed ) )
    ply:SetWalkSpeed( math.max( walkSpeed, minWalkSpeed ) )
end

local function getWeaponWeight( weapon )
    -- the weight/significance of a weapon (1 for affecting weight 0 for not affecting weight)
    if nonEffectedWeapons[weapon:GetClass()] then return 0 end
    return 1
end

local function getWeaponCount( ply ) 
    if playerIsInBuild( ply ) then return 0 end
    local weapons = ply:GetWeapons()
    local weaponCount = 0
    for _, weapon in pairs( weapons ) do
        weaponCount = weaponCount + getWeaponWeight( weapon )
    end
    return weaponCount
end

-- Hook Functions --
local function onEquip( wep, ply )
    if not IsValid( ply ) then return end
    local weaponCount = getWeaponCount( ply ) + getWeaponWeight( wep )

    setSpeedFromWeaponCount( ply, weaponCount )
end

local function onDrop( ply, wep )
    if not IsValid( ply ) then return end
    local weaponCount = getWeaponCount( ply ) - getWeaponWeight( wep )

    setSpeedFromWeaponCount( ply, weaponCount )
end

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquip)

hook.Remove("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"))
hook.Add("PlayerDroppedWeapon", generateCFCHook("HandleDroppedWeaponMS"), onDrop)
