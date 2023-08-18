-- default run and walk speed with 0 weapons
local normalRunSpeed = 400
local normalWalkSpeed = 200
local slowWalkSpeed = 100 -- Default GMod speed when holding +walk, not configurable.

-- minimum run and walk speed ( must be greater than 0 )
local minRunSpeed = 70
local minWalkSpeed = 35
local walkSpeedAlert = 100 -- If the player's walk speed is below this due to weapon weight, they will be alerted
local walkSpeedAlertCooldown = 0.5 -- Prevents spam from the above message (e.g. external addon sets both run and move speed while ply has high weight => double print)

local defaultWeight = 0
local weaponWeights = {
    weapon_rpg        = 3,
    m9k_m98b          = 2,
    ins2_atow_rpg7    = 4,
    m9k_matador       = 3,
    m9k_m202          = 3,
    m9k_rpg7          = 3,
    m9k_minigun       = 6,
    cw_m249_official  = 3,
    m9k_m60  = 3,
    m9k_pkm  = 3,
    m9k_m1918bar  = 3,
    m9k_m249lmg  = 3,
    tfa_l4d2mw_riotshield = 3,
    m9k_ares_shrike  = 3,
    weapon_lfsmissilelauncher = 4,
}
pvpMoveSpeed = {}


local plyMeta = FindMetaTable( "Player" )
pvpMoveSpeed.wrappedFuncs = {
    Player = {
        SetRunSpeed = plyMeta.SetRunSpeed,
        SetWalkSpeed = plyMeta.SetWalkSpeed,
    }
}

local plyWraps = pvpMoveSpeed.wrappedFuncs.Player


-- Helper Functions --
local cfcHookPrefix = "CFC_PlyMS_"
local function generateCFCHook( hookname )
    return cfcHookPrefix .. hookname
end

local function isValidPlayer( ply )
    return IsValid( ply ) and ply:IsPlayer()
end

local function movementMultiplier( totalWeight )
    if totalWeight < 1 then return 1 end
    local multiplier = 1 - ( 1.9 ^ totalWeight  ) / 100
    return math.Clamp( multiplier, 0, 1 )
end

local function getBaseRunSpeed( ply )
    return ply.CFC_PlyMS_BaseRunSpeed or normalRunSpeed
end
pvpMoveSpeed.getBaseRunSpeed = getBaseRunSpeed

local function getBaseWalkSpeed( ply )
    return ply.CFC_PlyMS_BaseWalkSpeed or normalWalkSpeed
end
pvpMoveSpeed.getBaseWalkSpeed = getBaseWalkSpeed

local function alertAboutWeightSlowness( ply )
    local now = RealTime()
    local canAlertTime = ply.CFC_PlyMS_SlownessAlertReadyTime or 0

    if now < canAlertTime then return end

    ply:ChatPrint( "You are holding too many weapons! /drop some to regain speed." )
    ply.CFC_PlyMS_SlownessAlertReadyTime = now + walkSpeedAlertCooldown
end

local function setSpeedFromWeight( ply, totalWeight )
    local multiplier = movementMultiplier( totalWeight )
    local baseRunSpeed = getBaseRunSpeed( ply )
    local baseWalkSpeed = getBaseWalkSpeed( ply )

    local newRunSpeed = baseRunSpeed * multiplier
    local newWalkSpeed = baseWalkSpeed * multiplier
    plyWraps.SetRunSpeed( ply, math.max( newRunSpeed, minRunSpeed ) )
    plyWraps.SetWalkSpeed( ply, math.max( newWalkSpeed, minWalkSpeed ) )

    local slowerThanSlowWalk = newWalkSpeed < slowWalkSpeed
    ply:SetCanWalk( not slowerThanSlowWalk ) -- Prevent +walk from letting the player move faster when overencumbered, without having to manage a third speed type

    local verySlow = newWalkSpeed < walkSpeedAlert
    local slowDueToWeight = verySlow and baseWalkSpeed >= walkSpeedAlert

    if slowDueToWeight then
        alertAboutWeightSlowness( ply )
    end
end
pvpMoveSpeed.setSpeedFromWeight = setSpeedFromWeight

local function isPACWeapon( weapon )
    return string.sub( weapon:GetClass(), 1, 4 ) == "pac_"
end

local function getWeaponWeight( weapon )
    if isPACWeapon( weapon ) then return 0 end

    return weaponWeights[weapon:GetClass()] or defaultWeight
end
pvpMoveSpeed.getWeaponWeight = getWeaponWeight

local function getPlayerWeight( ply )
    if ply.IsInBuild and ply:IsInBuild() then return 0 end
    local weapons = ply:GetWeapons()
    local totalWeight = 0
    for _, weapon in pairs( weapons ) do
        totalWeight = totalWeight + getWeaponWeight( weapon )
    end
    return totalWeight
end
pvpMoveSpeed.getPlayerWeight = getPlayerWeight


-- Wrappers --
function plyMeta:SetRunSpeed( speed )
    local weight = pvpMoveSpeed.getPlayerWeight( self )

    self.CFC_PlyMS_BaseRunSpeed = speed or normalRunSpeed
    pvpMoveSpeed.setSpeedFromWeight( self, weight )
end

function plyMeta:SetWalkSpeed( speed )
    local weight = pvpMoveSpeed.getPlayerWeight( self )

    self.CFC_PlyMS_BaseWalkSpeed = speed or normalWalkSpeed
    pvpMoveSpeed.setSpeedFromWeight( self, weight )
end


-- New Player:() Functions --

-- Sets run and walk speed at the same time
function plyMeta:SetMoveSpeed( runSpeed, walkSpeed )
    local weight = pvpMoveSpeed.getPlayerWeight( self )

    self.CFC_PlyMS_BaseRunSpeed = runSpeed or normalRunSpeed
    self.CFC_PlyMS_BaseWalkSpeed = walkSpeed or normalWalkSpeed
    pvpMoveSpeed.setSpeedFromWeight( self, weight ) -- Avoid double-calling this by not using :SRS() and :SWS()
end

-- Sets run and walk speed based on a multiplier of the default speed
function plyMeta:SetMoveSpeedMultiplier( multiplier )
    multiplier = math.max( multiplier or 1, 0 )
    self:SetMoveSpeed( normalRunSpeed * multiplier, normalWalkSpeed * multiplier )
end


-- Hook Functions --
local function onEquip( wep, ply )
    if not isValidPlayer( ply ) then return end
    local totalWeight = getPlayerWeight( ply ) + getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end

local function onDrop( ply, wep )
    if not isValidPlayer( ply ) then return end
    local totalWeight = getPlayerWeight( ply ) - getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end


-- Hooks --
hook.Remove( "WeaponEquip", generateCFCHook( "HandleEquipMS" ) )
hook.Add( "WeaponEquip", generateCFCHook( "HandleEquipMS" ), onEquip )

hook.Remove( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ) )
hook.Add( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ), onDrop )
