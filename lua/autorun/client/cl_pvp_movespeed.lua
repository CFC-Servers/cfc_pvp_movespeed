-- Sends to server to drop current weapon
concommand.Add( "cfc_dropweapon", function()
    net.Start( "dropPlayerWeapon" )
    net.SendToServer()
end )

concommand.Add( "cfc_dropallweapons", function()
    net.Start( "dropAllWeapons" )
    net.SendToServer()
end )
