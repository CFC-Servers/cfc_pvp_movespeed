CFCPvpMovespeed = {
    -- default run and walk speed with 0 weapons
    baseRunSpeed = 400,
    baseWalkSpeed = 200,

    -- minimum run and walk speed ( must be greater than 0 )
    minRunSpeed = 70,
    minWalkSpeed = 35,

    -- Weapon weights, weapons not in the table have a weight of 1
    weaponWeights = {
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
        m9k_minigun       = 4,
    },

    cfcHookPrefix = "CFC_PlyMS_"
}

-- Helper Functions --
function CFCPvpMovespeed:generateCFCHook( hookname )
    return self.cfcHookPrefix .. hookname
end

function CFCPvpMovespeed.playerIsInBuild( ply )
    return ply:GetNWBool( "CFC_PvP_Mode", false )
end

function CFCPvpMovespeed.isValidPlayer( ply )
    return IsValid( ply ) and ply:IsPlayer()
end

function CFCPvpMovespeed.movementMultiplier( totalWeight )
    if totalWeight < 1 then return 1 end
    local multiplier = 1 - ( 1.9 ^ totalWeight  ) / 100
    return math.Clamp( multiplier, 0, 1 )
end

function CFCPvpMovespeed:setSpeedFromWeight( ply, totalWeight )
    local multiplier = movementMultiplier( totalWeight )

    local newRunSpeed = self.baseRunSpeed * multiplier
    local newWalkSpeed = self.baseWalkSpeed * multiplier

    ply:SetRunSpeed( math.max( newRunSpeed, minRunSpeed ) )
    ply:SetWalkSpeed( math.max( newWalkSpeed, minWalkSpeed ) )

    if newWalkSpeed < 100 then
        ply:ChatPrint( "You are holding too many weapons! Drop some to regain speed." )
        ply:SetCanWalk( false )
        return
    end

    ply:SetCanWalk( true )
end

function CFCPvpMovespeed.isPACWeapon( weapon )
    return string.sub( weapon:GetClass(), 1, 4 ) == "pac_"
end

function CFCPvpMovespeed:getWeaponWeight( weapon )
    if self.isPACWeapon( weapon ) then return 0 end

    return self.weaponWeights[weapon:GetClass()] or 1
end

function CFCPvpMovespeed:getPlayerWeight( ply )
    if self.playerIsInBuild( ply ) then return 0 end
    local weapons = ply:GetWeapons()
    local totalWeight = 0

    for _, weapon in pairs( weapons ) do
        totalWeight = totalWeight + self:getWeaponWeight( weapon )
    end

    return totalWeight
end

-- Hook Functions --
function CFCPvpMovespeed:OnEquip( wep, ply )
    if not isValidPlayer( ply ) then return end
    local totalWeight = self:getPlayerWeight( ply ) + self:getWeaponWeight( wep )

    self:setSpeedFromWeight( ply, totalWeight )
end

function CFCPvpMovespeed:OnDrop( ply, wep )
    if not isValidPlayer( ply ) then return end
    local totalWeight = self:getPlayerWeight( ply ) - self:getWeaponWeight( wep )

    self:setSpeedFromWeight( ply, totalWeight )
end

-- Hooks --
hook.Remove( "WeaponEquip", generateCFCHook( "HandleEquipMS" ) )
hook.Add( "WeaponEquip", generateCFCHook( "HandleEquipMS" ), function( ... )
    CFCPvpMovespeed:OnEquip( ... )
end )

hook.Remove( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ) )
hook.Add( "PlayerDroppedWeapon", generateCFCHook( "HandleDroppedWeaponMS" ), function( ... )
    CFCPvpMovespeed:OnDrop( ... )
end )
