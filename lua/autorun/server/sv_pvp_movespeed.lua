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

local undroppableWeapons = {}
undroppableWeapons.weapon_physgun    = true
undroppableWeapons.weapon_physcannon = true
undroppableWeapons.none              = true
undroppableWeapons.gmod_tool         = true
undroppableWeapons.gmod_camera       = true

local chatDropPhrases = {}
chatDropPhrases["!drop"] = true
chatDropPhrases["!d"]    = true
chatDropPhrases["/drop"] = true
chatDropPhrases["/d"]    = true

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

local minMult = 0.2
local function movementMultiplier( weaponCount )
    local N = 1 - (1.9^( weaponCount ))/100
    return math.Clamp( N, 0.5, 1 )
end

local function setSpeed(ply, multiplier) 
    -- set speed multiplier, 0 - 1
    ply:SetRunSpeed( math.Clamp( baseRunSpeed*multiplier, minRunSpeed, baseRunSpeed ) )
    ply:SetWalkSpeed( math.Clamp( baseWalkSpeed*multiplier,minWalkSpeed, baseWalkSpeed ) )
end

function adjustMovementSpeed(ply) 
    if playerIsInBuild( ply ) then 
        setSpeed( ply, 1 ) 
        return
    end
    
    local weapons = ply:GetWeapons()
    local wepCount = 0
    
    -- count weapons
    for _, weapon in pairs( weapons ) do
        if nonEffectedWeapons[weapon:GetClass()] == nil then
            wepCount = wepCount + 1
        end
    end
    
    local multiplier = movementMultiplier( wepCount ) 
    setSpeed(ply, multiplier)
end

local function dropWeapon( ply )
    ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
end

local function dropAndAdjust( ply, weapon )
    local class = weapon:GetClass()
    if undroppableWeapons[class] then 
        ply:ChatPrint("You are unable to drop \"" .. class .. "\".")
        return 
    end

    dropWeapon( ply )
    adjustMovementSpeed( ply )
end

-- Hook Functions --
local function onEquipped( wep, ply )
    if not IsValid( ply ) then return end
    adjustMovementSpeed( ply )
end

local function onChat( ply, msg )
    msg = string.lower( msg )
    if chatDropPhrases[msg] then
        if not ply:Alive() then return "" end
        local wep = ply:GetActiveWeapon()
        if not IsValid( wep ) then return "" end 

        dropAndAdjust( ply, wep )
        return ""
    end
end

-- Concommands --
concommand.Add("dropweapon", function( ply, cmd, args )
    local wep = ply:GetActiveWeapon()
    if not IsValid( wep ) then return end

    dropAndAdjust( ply, wep )
end)

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquipped)

hook.Remove( "PlayerSay", generateCFCHook("ChatCommands") )
hook.Add( "PlayerSay", generateCFCHook("ChatCommands"), onChat)