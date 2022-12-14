# CFC PvP Movespeed
Adjusts player movespeed based on how many SWEPs are equipped

# Overview 
A Garry's Mod addon that adjusts players movement speed based on the amount of weapons they have equiped. This was done to discourage carrying large amount of weapons at one time.  
This addons also adds commands that allow players to remove and drop their weapons.

# Changing weapon weights 
All weapons have a weight of `1` by default, you can change this default weight by adding your weapon to the weaponWeights table
in [lua/autorun/server/sv_pvp_movespeed.lua](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_pvp_movespeed.lua)


### Weight calculations
A players weight is the weight of all their weapons added together. This number is passed to the function `movementMultiplier`  in 
[lua/autorun/server/sv_pvp_movespeed.lua](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_pvp_movespeed.lua) 
to calculate a movement speed multiplier

# Chat Commands
- `/dropall` deletes all weapons from the players inventory and resets their movespeed
  - Can also be ran via the `cfc_dropallweapons` concmd.
- `/drop` drop the held weapon on the ground where it can be picked up again or it will despawn after 10 seconds
  - Can also be ran via the `cfc_dropweapon` concmd.

# Setup
Clone the addon into your gmod servers addon directory 

# Compatibility / Added Functions
- Other addons that use `:SetRunSpeed()` or `:SetWalkSpeed()` will automatically be accounted for, setting the player's base run/walk speeds.
- `Player:SetMoveSpeed( runSpeed, walkSpeed )`
  - `runSpeed` - Base run speed to use. (Default: `normalRunSpeed = 400` )
  - `walkSpeed` - Base walk speed to use. (Default: `normalWalkSpeed = 200` )
  - Sets both run and walk speeds at the same time.
- `Player:SetMoveSpeedMultiplier( multiplier )`
  - `multiplier` - Movespeed multiplier to use. (Default: `1`)
  - Sets base run and walk speeds to `normalSpeed * multiplier`
