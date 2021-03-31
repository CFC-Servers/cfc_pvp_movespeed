-- default run and walk speed with 0 weapons
local baseRunSpeed = 400
local baseWalkSpeed = 200

-- minimum run and walk speed ( must be greater than 0 )
local minRunSpeed = 70
local minWalkSpeed = 35

-- Weapon weights, weapons not in the table have a weight of 1
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
    m9k_fists         = 0,
    m9k_m98b          = 2,
    ins2_atow_rpg7    = 3,
    m9k_matador       = 3,
    m9k_m202          = 3,
    m9k_rpg7          = 3,
    m9k_minigun       = 6,
}
pvpMoveSpeed = {}

-- Helper Functions --
local cfcHookPrefix = "CFC_PlyMS_"
local function generateCFCHook( hookname )
    return cfcHookPrefix .. hookname
end

local function getPlayerPvpMode( ply )
    return ply:GetNWBool( "CFC_PvP_Mode", false )
end

local function playerIsInBuild( ply )
    return not getPlayerPvpMode( ply )
end

local function isValidPlayer( ply )
    return IsValid( ply ) and ply:IsPlayer()
end

local function movementMultiplier( totalWeight )
    if totalWeight < 1 then return 1 end
    local multiplier = 1 - ( 1.9 ^ totalWeight  ) / 100
    return math.Clamp( multiplier, 0, 1 )
end

local function setSpeedFromWeight( ply, totalWeight )
    local multiplier = movementMultiplier( totalWeight )

    local newRunSpeed = baseRunSpeed * multiplier
    local newWalkSpeed = baseWalkSpeed * multiplier
    ply:SetRunSpeed( math.max( newRunSpeed, minRunSpeed ) )
    ply:SetWalkSpeed( math.max( newWalkSpeed, minWalkSpeed ) )

    if newWalkSpeed < 100 then
        ply:ChatPrint( "You are holding too many weapons! Drop some to regain speed." )
        ply:SetCanWalk( false )
    else
        ply:SetCanWalk( true )
    end
end
pvpMoveSpeed.setSpeedFromWeight = setSpeedFromWeight

local function isPACWeapon( weapon )
    return string.sub( weapon:GetClass(), 1, 4 ) == "pac_"
end

local function getWeaponWeight( weapon )
    if isPACWeapon( weapon ) then return 0 end

    return weaponWeights[weapon:GetClass()] or 1
end
pvpMoveSpeed.getWeaponWeight = getWeaponWeight

local function getPlayerWeight( ply )
    if playerIsInBuild( ply ) then return 0 end
    local weapons = ply:GetWeapons()
    local totalWeight = 0
    for _, weapon in pairs( weapons ) do
        totalWeight = totalWeight + getWeaponWeight( weapon )
    end
    return totalWeight
end
pvpMoveSpeed.getPlayerWeight = getPlayerWeight

-- Hook Functions --
local function onEquip( wep, ply )
    if not isValidPlayer( ply ) then return end
    if hook.Run( generateCFCHook( "CanChangeMoveSpeed" ), ply ) == false then return end
    local totalWeight = getPlayerWeight( ply ) + getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end

local function onDrop( ply, wep )
    if not isValidPlayer( ply ) then return end
    if hook.Run( generateCFCHook( "CanChangeMoveSpeed" ), ply ) == false then return end
    local totalWeight = getPlayerWeight( ply ) - getWeaponWeight( wep )

    setSpeedFromWeight( ply, totalWeight )
end

local function onForcedWeigh( ply )
    if not isValidPlayer( ply ) then return end
    if hook.Run( generateCFCHook( "CanChangeMoveSpeed" ), ply ) == false then return end
    local totalWeight = getPlayerWeight( ply )

    setSpeedFromWeight( ply, totalWeight )
end

-- Hooks --
hook.Remove( "WeaponEquip", generateCFCHook( "HandleEquipMS" ) )
hook.Add( "WeaponEquip", generateCFCHook( "HandleEquipMS" ), onEquip )

hook.Remove( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ) )
hook.Add( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ), onDrop )

hook.Remove( generateCFCHook( "WeighPlayer" ), generateCFCHook( "ForcedWeigh" ) )
hook.Add( generateCFCHook( "WeighPlayer" ), generateCFCHook( "ForcedWeigh" ), onForcedWeigh )

-- Powerup Hooks --

hook.Remove( "CFC_Powerups_PowerupRemoved", generateCFCHook( "PowerupRemoved" ) )
hook.Add( "CFC_Powerups_PowerupRemoved", generateCFCHook( "PowerupRemoved" ), function( ply, powerupId )
    if powerupId ~= "powerup_speed" then return end
    if not isValidPlayer( ply ) then return end
    if not ply:Alive() then return end

    hook.Run( generateCFCHook( "WeighPlayer" ), ply )
end )

hook.Remove( generateCFCHook( "CanChangeMoveSpeed" ), generateCFCHook( "AccountForSpeedPowerup" ) )
hook.Add( generateCFCHook( "CanChangeMoveSpeed" ), generateCFCHook( "AccountForSpeedPowerup" ), function( ply )
    if not PowerupManager then return end
    if PowerupManager.hasPowerup( ply, "powerup_speed" ) then return false end
end )
