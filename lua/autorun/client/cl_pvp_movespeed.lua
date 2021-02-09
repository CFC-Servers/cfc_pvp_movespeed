-- Sends to server to drop current weapon
concommand.Add( "cfc_dropweapon", function()
    net.Start( "CFC_PvpMovespeed_dropPlayerWeapon" )
    net.SendToServer()
end )

concommand.Add( "cfc_dropallweapons", function()
    net.Start( "CFC_PvpMovespeed_dropAllWeapons" )
    net.SendToServer()
end )
