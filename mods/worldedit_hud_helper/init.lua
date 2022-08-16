--- worldedit_hud_helper
-- @module worldedit_hud_helper
-- @release 0.1
-- @copyright 2018 Starbeamrainbowlabs
-- @license Mozilla Public License, 2.0 (MPL-2.0)
-- @author Starbeamrainbowlabs

worldedit_hud_helper = {
	info = {}
}

function worldedit_hud_helper.log_message(level, msg)
	minetest.log(level, "[worldedit_hud_helper] " .. msg)
end

local mod_path = minetest.get_modpath("worldedit_hud_helper")

dofile(mod_path .. "/common.lua")
dofile(mod_path .. "/raycast_polyfill.lua")
dofile(mod_path .. "/hud.lua")
dofile(mod_path .. "/hud_info.lua")
dofile(mod_path .. "/commands.lua")
dofile(mod_path .. "/io.lua")


worldedit_hud_helper.load()
