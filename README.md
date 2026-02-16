# CFC PvP Movespeed
Adjusts player movespeed based on their currently active weapon's weight

# Overview 
A Garry's Mod addon that adjusts players movement speed based on the weight of their currently active weapon. Heavier weapons slow down the player, discouraging the use of heavy weaponry without strategic trade-offs.  
This addon also adds commands that allow players to remove and drop their weapons.

# Changing weapon weights 
All weapons have a weight of `1` by default, you can change this default weight by adding your weapon to the weaponWeights table
in [lua/autorun/server/sv_pvp_movespeed.lua](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_pvp_movespeed.lua)


### Weight calculations
A player's weight is determined by their currently active weapon. This weight value is passed to the function `movementMultiplier` in 
[lua/autorun/server/sv_pvp_movespeed.lua](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_pvp_movespeed.lua) 
to calculate a movement speed multiplier. When players switch weapons, their speed updates accordingly.

# Chat Commands
- `/dropall` or `/strip` - Deletes all weapons from the player's inventory and resets their movespeed.
  - Can also be ran via the `cfc_dropallweapons` console command.
- `/drop` - Drops the currently held weapon on the ground where it can be picked up again, or it will despawn after 10 seconds.
  - Can also be ran via the `cfc_dropweapon` console command.
- Chat command aliases can be modified in [lua/autorun/server/sv_commands.lua](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_commands.lua)

# Setup
Clone the addon into your gmod servers addon directory 

# Compatibility
- Other addons that use `:SetRunSpeed()` or `:SetWalkSpeed()` will automatically be accounted for, setting the player's base run/walk speeds.
  - The original, unwrapped functions can be found at `Player.o_SetRunSpeed` and `Player.o_SetWalkSpeed` in the player metatable.
  - Note that [the config](https://github.com/CFC-Servers/cfc_pvp_movespeed/blob/master/lua/autorun/server/sv_pvp_movespeed.lua) sets minimum walk and run speeds, so you'll need to use the **unwrapped** functions if you want to force someone's speed to 0. The player's speed will revert once they switch weapons when using this method, however.
- If one of your addons defines `Player:IsInBuild()`, it will be used to disable weapon weights on buildmode players.

# Added Functions
- `Player:SetMoveSpeed( runSpeed, walkSpeed )`
  - `runSpeed` - Base run speed to use. (Default: `normalRunSpeed = 400` )
  - `walkSpeed` - Base walk speed to use. (Default: `normalWalkSpeed = 200` )
  - Sets both run and walk speeds at the same time.
- `Player:SetMoveSpeedMultiplier( multiplier )`
  - `multiplier` - Movespeed multiplier to use. (Default: `1`)
  - Sets base run and walk speeds to `normalSpeed * multiplier`
