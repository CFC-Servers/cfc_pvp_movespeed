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
    ins2_atow_rpg7    = 4,
    m9k_matador       = 3,
    m9k_m202          = 3,
    m9k_rpg7          = 3,
    m9k_minigun       = 6,
    tfa_l4d2mw_riotshield = 3,
    weapon_lfsmissilelauncher = 4,
}

local plyMeta = FindMetaTable( "Player" )
plyMeta.o_SetRunSpeed = plyMeta.o_SetRunSpeed or plyMeta.SetRunSpeed
local o_SetRunSpeed = plyMeta.o_SetRunSpeed
plyMeta.o_SetWalkSpeed = plyMeta.o_SetWalkSpeed or plyMeta.SetWalkSpeed
local o_SetWalkSpeed = plyMeta.o_SetWalkSpeed

-- Helper Functions --
local function movementMultiplier( weight )
    if weight < 1 then return 1 end
    local multiplier = 1 - ( 1.9 ^ weight  ) / 100
    return math.Clamp( multiplier, 0, 1 )
end

local function getBaseRunSpeed( ply )
    return ply.CFC_PlyMS_BaseRunSpeed or normalRunSpeed
end

local function getBaseWalkSpeed( ply )
    return ply.CFC_PlyMS_BaseWalkSpeed or normalWalkSpeed
end

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
    o_SetRunSpeed( ply, math.max( newRunSpeed, minRunSpeed ) )
    o_SetWalkSpeed( ply, math.max( newWalkSpeed, minWalkSpeed ) )

    local slowerThanSlowWalk = newWalkSpeed < slowWalkSpeed
    ply:SetCanWalk( not slowerThanSlowWalk ) -- Prevent +walk from letting the player move faster when overencumbered, without having to manage a third speed type

    local verySlow = newWalkSpeed < walkSpeedAlert
    local slowDueToWeight = verySlow and baseWalkSpeed >= walkSpeedAlert

    if slowDueToWeight then
        alertAboutWeightSlowness( ply )
    end
end

local function getWeaponWeight( weapon )
    if string.sub( weapon:GetClass(), 1, 4 ) == "pac_" then return 0 end

    return weaponWeights[weapon:GetClass()] or defaultWeight
end

local function getPlayerWeight( ply )
    if ply.IsInBuild and ply:IsInBuild() then return 0 end
    local activeWeapon = ply:GetActiveWeapon()
    local totalWeight = 0
    if IsValid( activeWeapon ) then
        totalWeight = getWeaponWeight( activeWeapon )
    end
    return totalWeight
end


-- Wrappers --
function plyMeta:SetRunSpeed( speed )
    local weight = getPlayerWeight( self )

    self.CFC_PlyMS_BaseRunSpeed = speed or normalRunSpeed
    setSpeedFromWeight( self, weight )
end

function plyMeta:SetWalkSpeed( speed )
    local weight = getPlayerWeight( self )

    self.CFC_PlyMS_BaseWalkSpeed = speed or normalWalkSpeed
    setSpeedFromWeight( self, weight )
end


-- New Player:() Functions --

-- Sets run and walk speed at the same time
function plyMeta:SetMoveSpeed( runSpeed, walkSpeed )
    local weight = getPlayerWeight( self )

    self.CFC_PlyMS_BaseRunSpeed = runSpeed or normalRunSpeed
    self.CFC_PlyMS_BaseWalkSpeed = walkSpeed or normalWalkSpeed
    setSpeedFromWeight( self, weight ) -- Avoid double-calling this by not using :SRS() and :SWS()
end

-- Sets run and walk speed based on a multiplier of the default speed
function plyMeta:SetMoveSpeedMultiplier( multiplier )
    multiplier = math.max( multiplier or 1, 0 )
    self:SetMoveSpeed( normalRunSpeed * multiplier, normalWalkSpeed * multiplier )
end


-- Hook Functions --
local function onWeaponSwitch( ply, _, wep )
    setSpeedFromWeight( ply, getWeaponWeight( wep ) )
end

-- Hooks --
hook.Remove( "PlayerSwitchWeapon", "CFC_PlyMS_PlayerSwitchWeapon" )
hook.Add( "PlayerSwitchWeapon", "CFC_PlyMS_PlayerSwitchWeapon", onWeaponSwitch )
