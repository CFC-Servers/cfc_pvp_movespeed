-- Includes --
include( "autorun/shared/sh_pvp_movespeed.lua" )
AddCSLuaFile( "autorun/shared/sh_pvp_movespeed.lua" )

--List of weapons that will not be affected of the players movement speed
local noneffectedWeapons = {}
noneffectedWeapons.weapon_physgun    = true
noneffectedWeapons.weapon_physcannon = true
noneffectedWeapons.none              = true
noneffectedWeapons.laserpointer      = true
noneffectedWeapons.remotecontroller  = true
noneffectedWeapons.gmod_tool         = true
noneffectedWeapons.gmod_camera       = true
noneffectedWeapons.weapon_357      	 = true
noneffectedWeapons.weapon_ar2      	 = true
noneffectedWeapons.weapon_crossbow 	 = true
noneffectedWeapons.weapon_crowbar  	 = true
noneffectedWeapons.weapon_pistol   	 = true
noneffectedWeapons.weapon_shotgun  	 = true
noneffectedWeapons.weapon_smg1     	 = true
noneffectedWeapons.weapon_medkit   	 = true

-- Helper Functions --
local function getPlayerPvpMode( ply )
	return ply:GetNWBool( "CFC_PvP_Mode", false )
end

local function playerIsInBuild( ply )
	return !getPlayerPvpMode( ply )
end

-- Hook Functions --
local function onEquipped( wep, ply )
	if not playerIsInBuild( ply ) then return end
end

-- Hooks --
hook.Remove("WeaponEquip", generateCFCHook("HandleEquipMS"))
hook.Add("WeaponEquip", generateCFCHook("HandleEquipMS"), onEquipped)