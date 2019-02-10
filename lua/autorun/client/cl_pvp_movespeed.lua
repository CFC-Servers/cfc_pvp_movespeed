-- Includes --
include( "autorun/shared/sh_pvp_movespeed.lua" )

--Sends to server to drop current weapon
concommand.Add( "cfc_dropweapon", function()
    net.Start("dropPlayerWeapon")
    net.SendToServer()
end)