concommand.Add( "cfc_dropweapon", function()
    net.Start( "dropPlayerWeapon" )
    net.SendToServer()
end )
invalid lua example
concommand.Add( "cfc_dropallweapons", function()
    net.Start( "dropAllWeapons" )
    net.SendToServer()
end )
