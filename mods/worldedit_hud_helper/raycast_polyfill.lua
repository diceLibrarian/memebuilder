
function worldedit_hud_helper.raycast(player)
	local look_dir = player:get_look_dir()
	
	local cur_pos = {}
	local player_pos = player:get_pos()
	player_pos.y = player_pos.y + 1.5 -- Calculate from the eye position
	
	for i = 1,100 do
		local j = i/10
		
		cur_pos.x = (look_dir.x*j) + player_pos.x
		cur_pos.y = (look_dir.y*j) + player_pos.y
		cur_pos.z = (look_dir.z*j) + player_pos.z
		
		local node_name
		node_name = minetest.get_node(cur_pos).name
		if node_name ~= "air" and node_name ~= "ignore" and not string.match(node_name, "wielded_light:") then
			return node_name
		end
	end
	
	return ""
end
