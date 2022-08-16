local default_node_name_offset_y = -100
local default_rotation_offset_y = -135

--- Initialises a brand-new info table for the given player name.
-- @param	player_name	string	The name of the player to initialise a new info table for.
-- @returns	table		The newly generated info table for convenience (note that tables are passed by reference in Lua).
function worldedit_hud_helper.initialise_info(player_name)
	worldedit_hud_helper.info[player_name] = {
		-- Persistable
		enabled = true,
		node_name_offset_y = default_node_name_offset_y,
		rotation_offset_y = default_rotation_offset_y,
		
		-- Dynamic
		node_name = nil,
		rotation = nil
	}
	return worldedit_hud_helper.info[player_name]
end

--- Initialises the HUD for a given player.
-- May be called multiple times. 
-- If called more than once, this has the effect of cycling the HUD registration
-- with Minetest for the given player.
-- @param	player		Player	The player object (as returned by minetest.get_player_by_name(player_name: string)).
-- @returns	nil
function worldedit_hud_helper.initialise_hud(player)
	local player_name = player:get_player_name()
	local player_info = worldedit_hud_helper.info[player_name]
	
	if not player_info then
		player_info = worldedit_hud_helper.initialise_info(player_name)
	end
	
	player_info.id_node_name = player:hud_add({
		hud_elem_type	= "text",
		text			= "",
		number			= 0xFFFFFF,
		position		= { x = 0.5, y = 1 },
		offset			= { x = 0, y = player_info.node_name_offset_y },
		
		alignment		= { x = 0, y = 0 }, -- Align to the centre
		scale			= { x = 150, y = 30 }
	})
	
	player_info.id_rotation = player:hud_add({
		hud_elem_type	= "text",
		text			= "",
		number			= 0xFFFFFF,
		position		= { x = 0.5, y = 1 },
		offset			= { x = 0, y = player_info.rotation_offset_y },
		
		alignment		= { x = 0, y = 0 }, -- Align to the centre
		scale			= { x = 150, y = 30 }
	})
	
end

--- Hides the HUD for a player without deleting their registration & settings.
-- @param	player		Player	The player object (as returned by minetest.get_player_by_name(player_name: string)).
-- @returns	nil
function worldedit_hud_helper.hide_hud(player)
	local player_info = worldedit_hud_helper.info[player:get_player_name()]
	
	
	player:hud_remove(player_info.id_node_name)
	player:hud_remove(player_info.id_rotation)
	
	player_info.node_name = nil
	player_info.rotation = nil
	
	worldedit_hud_helper.save_defer()
end

--- Deletes the HUD for a player.
-- Caution: This will also wipe all customised settings with no way to recover
-- them!
-- @param	player		Player	The player object (as returned by minetest.get_player_by_name(player_name: string)).
function worldedit_hud_helper.delete_hud(player)
	worldedit_hud_helper.info[player:get_player_name()] = nil
	
	worldedit_hud_helper.save_defer()
end

--- Updates the HUD offset in pixels.
-- Larger numbers move the HUD further upwards on the screen.
-- Default: 0.
-- @param	player		Player	The player object (as returned by minetest.get_player_by_name(player_name: string)).
-- @param	new_offset	number	The new offset, as an integer.
-- @returns	bool		Whether the update was successful or not. A HUD must be initialised for that player for it up have its offset updated.
function worldedit_hud_helper.update_hud_offset(player, new_offset)
	if not new_offset then new_offset = 0 end
	
	local player_info = worldedit_hud_helper.info[player:get_player_name()]
	
	if not player_info then return false end
	
	-- Update the new offset
	player_info.node_name_offset_y = default_node_name_offset_y + -new_offset
	player_info.rotation_offset_y = default_rotation_offset_y + -new_offset
	
	-- Restart the HUD
	worldedit_hud_helper.hide_hud(player)
	worldedit_hud_helper.initialise_hud(player)
	
	-- Save the new setting(s) to disk
	worldedit_hud_helper.save_defer()
	
	return true
end


minetest.register_on_joinplayer(worldedit_hud_helper.initialise_hud)
-- Don't delete the HUD when the player leaves anymore, since we now persist it to disk
-- minetest.register_on_leaveplayer(worldedit_hud_helper.delete_hud)
