
local filepath_data = minetest.get_worldpath().."/worldedit_hud_helper_data.tsv"

-- Splits a string using a given delimiter.
-- @source	https://stackoverflow.com/a/7615129/1460422
-- @param	inputstr	string	The string to split.
-- @param	sep			string	The delimiter.
-- @returns	string[]	A table of substrings split out of the input string.
local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end


--- Serialises and saves the settings for all players to disk.
-- Settings are saved to a file in the world's directory called
-- 'worldedit_hud_helper_data.tsv'.
-- @returns	nil
function worldedit_hud_helper.save()
	local result = {
		table.concat({
			"player_name",
			"enabled",
			"node_name_offset_y",
			"rotation_offset_y"
		}, "\t")
	}

	for player_name, player_info in pairs(worldedit_hud_helper.info) do
		print("DEBUG player_name", player_name)
		local next = table.concat({
			player_name,
			tostring(player_info.enabled),
			tostring(player_info.node_name_offset_y),
			tostring(player_info.rotation_offset_y),
		}, "\t")
		print("DEBUG next", next)
		table.insert(result, next)
	end

	local handle = io.open(filepath_data, "w+")
	handle:write(table.concat(result, "\n"))
	handle:close()
end

--- Calls worldedit_hud_helper.save(), but pushes the call to the end of the
-- function queue.
function worldedit_hud_helper.save_defer()
	minetest.after(0, function()
		worldedit_hud_helper.save()
	end)
end

--- Loads all the settings for all players from disk.
-- CAUTION: This should only be called ONCE on server start when no players are
-- connected!
-- Note that this does NOT reinitialise any player's HUDs, since it is expected
-- that they are not connected yet when this function is called.
-- Note also that if no settings have yet been saved to disk (i.e. the settings
-- file doesn't exist), then this function silently returns.
-- @returns	nil
function worldedit_hud_helper.load()
	local handle = io.open(filepath_data, "r")
	if handle == nil then return end

	local i = 0
	for line in handle:lines() do
		if i > 0 then
			local parts = split(line)
			local player_name = parts[1]
			local player_info = worldedit_hud_helper.initialise_info(player_name)
			
			player_info.enabled = parts[2]
			player_info.node_name_offset_y = parts[3]
			player_info.rotation_offset_y = parts[4]
		end
		
		i = i + 1
	end
	
	minetest.log("info", "[worldedit_hud_helper] Loaded per-world settings for "..i.." players.")
end
