
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
hook.Remove( "PlayerSay", generateCFCHook("ChatCommands") )
hook.Add( "PlayerSay", generateCFCHook("ChatCommands"), onChat)
