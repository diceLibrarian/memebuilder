
-- ███    ██  ██████  ██████  ███████     ███    ██  █████  ███    ███ ███████
-- ████   ██ ██    ██ ██   ██ ██          ████   ██ ██   ██ ████  ████ ██
-- ██ ██  ██ ██    ██ ██   ██ █████       ██ ██  ██ ███████ ██ ████ ██ █████
-- ██  ██ ██ ██    ██ ██   ██ ██          ██  ██ ██ ██   ██ ██  ██  ██ ██
-- ██   ████  ██████  ██████  ███████     ██   ████ ██   ██ ██      ██ ███████

local function handle_node_name_player(player)
	local player_name = player:get_player_name()
	
	-- Don't bother if it's disabled for this player
	if not worldedit_hud_helper.info[player_name].enabled then
		return
	end
	
	local node_name = worldedit_hud_helper.raycast(player)
	
	if worldedit_hud_helper.info[player_name].node_name ~= node_name then
		player:hud_change(
			worldedit_hud_helper.info[player_name].id_node_name,
			"text",
			node_name
		)
	end
	
	worldedit_hud_helper.info[player_name].node_name = node_name
end

local function handle_node_name(dt)
	for _,player in ipairs(minetest.get_connected_players()) do
		handle_node_name_player(player)
	end
end

minetest.register_globalstep(handle_node_name)


-- ██████   ██████  ████████  █████  ████████ ██  ██████  ███    ██
-- ██   ██ ██    ██    ██    ██   ██    ██    ██ ██    ██ ████   ██
-- ██████  ██    ██    ██    ███████    ██    ██ ██    ██ ██ ██  ██
-- ██   ██ ██    ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██
-- ██   ██  ██████     ██    ██   ██    ██    ██  ██████  ██   ████

local function calc_rotation_text(rotation)
	if rotation <= math.pi / 4 or rotation >= (7*math.pi)/4 then
		return "+Z"
	elseif rotation > math.pi / 4 and rotation <= (3*math.pi)/4 then
		return "-X"
	elseif rotation > (3*math.pi)/4 and rotation <= (5*math.pi)/4 then
		return "-Z"
	else
		return "+X"
	end
end

local function handle_rotation_player(player)
	local player_name = player:get_player_name()
	
	-- Don't bother if it's disabled for this player
	if not worldedit_hud_helper.info[player_name].enabled then
		return
	end
	
	local rotation = player:get_look_horizontal()
	local old_rotation = worldedit_hud_helper.info[player_name].rotation
	
	-- Bad practice! Lua doesn't have a continue statement though (O.o),
	-- so we've got to make do :-/
	if rotation ~= old_rotation then
		local rotation_text = calc_rotation_text(rotation)
		
		if old_rotation == nil or (old_rotation ~= nil and rotation_text ~= calc_rotation_text(old_rotation)) then
			player:hud_change(
				worldedit_hud_helper.info[player_name].id_rotation,
				"text",
				rotation_text
			)
		end
	end
	
	worldedit_hud_helper.info[player:get_player_name()].rotation = rotation
end

local function handle_rotation(dt)
	for _,player in ipairs(minetest.get_connected_players()) do
		handle_rotation_player(player)
	end
end

minetest.register_globalstep(handle_rotation)
