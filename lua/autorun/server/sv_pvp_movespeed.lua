-- Includes --
include( "autorun/shared/sh_pvp_movespeed.lua" )
AddCSLuaFile( "autorun/shared/sh_pvp_movespeed.lua" )

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

-- Helper Functions --
local function getPlayerPvpMode( ply )
	return ply:GetNWBool( "CFC_PvP_Mode", false )
end

local function playerIsInBuild( ply )
	return !getPlayerPvpMode( ply )
end

local function movementMultiplier(weaponCount) 
    -- calculate movement speed multiplier
end
local function adjustMovementSpeed(ply) 

	local weapons = ply:GetWeapons(ply)
	local wepCount = 0
	for k, weapon in pairs(weapons) do
		if nonEffectedWeapons[weapon:GetClass()] == nil then
            wepCount =  wepCount+1
            
        end
	end
    multiplier = movementMultiplier(wepCount) 
    ply:SetRunSpeed(400*multiplier)
    ply:SetWalkSpeed(200*multiplier) 
end
-- Hook Functions --
local function onEquipped( wep, ply )
	if not playerIsInBuild( ply ) then return end
    adjustMovementSpeed( ply )
end

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquipped)

