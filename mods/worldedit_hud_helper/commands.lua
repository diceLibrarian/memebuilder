
minetest.register_chatcommand("/hud", {
	params = "",
	description = "Toggles the helper heads-up display.",
	func = function(player_name, params_text)
		worldedit_hud_helper.info[player_name].enabled = not worldedit_hud_helper.info[player_name].enabled
		
		local player = minetest.get_player_by_name(player_name)
		local message = "HUD "
		
		if worldedit_hud_helper.info[player_name].enabled then
			worldedit_hud_helper.initialise_hud(player)
			message = message .. "shown"
		else
			worldedit_hud_helper.hide_hud(player)
			message = message .. "hidden"
		end
		
		worldedit_hud_helper.player_notify(player_name, message)
	end
})

minetest.register_chatcommand("/hudoffset", {
	params = "[<offset_in_pixels>]",
	description = "Sets the vertical offset of the HUD in pixels. Default: 0, If not specified, then the value is return to it's default value.",
	func = function(player_name, params_text)
		local new_offset = tonumber(params_text) or 0
		local player = minetest.get_player_by_name(player_name)
		
		worldedit_hud_helper.update_hud_offset(player, new_offset)
		
		worldedit_hud_helper.player_notify(player_name, "HUD offset set to "..new_offset.." pixels (default: 0).")
	end
})
