
function worldedit_hud_helper.player_notify(player_name, message)
	minetest.chat_send_player(player_name, "WorldEdit -!- " .. message, false)
end
