
twmlib = {}
twmlib.registered_twm = {}
function twmlib.next_interval()
	return tonumber(minetest.settings:get("twmlib.interval")) or 2
end
local mod_path = minetest.get_modpath(minetest.get_current_modname())

function twmlib.register_twm(twm_definition)
	for _, nodename in ipairs(twm_definition.nodenames) do
		if twmlib.registered_twm[nodename] == nil then
			twmlib.registered_twm[nodename] = {}
		end
		table.insert(twmlib.registered_twm[nodename], twm_definition)
	end
end


local range = (minetest.settings:get("active_block_range") or 3) * 16
local function loop()
	-- Take one player at random
	local players = minetest.get_connected_players()
	if #players == 0 then return end -- players not loaded yet
	local picked = players[math.random(1, #players)]
	-- Take a random position around
	local pos = picked:get_pos()
	if not pos then return end -- player not positioned yet
	pos.y = pos.y + math.random(-range, range)
	pos.x = pos.x + math.random(-range, range)
	pos.z = pos.z + math.random(-range, range)
	local rand_pos = vector.new(pos.x, pos.y, pos.z)
	local node = minetest.get_node(rand_pos)
	if node.name == "air" then
		-- go up or down a few times until something is found
		local dy = (math.random() > 0.5)
		if dy then
			dy = 1
		else
			dy = -1
		end
		local i = 0
		while i < range / 2 and node.name == "air" do
			rand_pos = vector.add(rand_pos, vector.new(0, dy, 0))
			node = minetest.get_node(rand_pos)
			i = i + 1
		end
	end
	if node.name == "air" or node.name == "ignore" then return end
	-- look for a registered twm for the node or group
	if twmlib.registered_twm[node.name] then
		-- trigger twm by node
		for _, def in ipairs(twmlib.registered_twm[node.name]) do
			if def.chance then
				if math.random(1, def.chance) == 1 then
					def.action(rand_pos, node)
				end
			else
				def.action(rand_pos, node)
			end
		end
	end
	local node_def = minetest.registered_nodes[node.name]
	for group, level in ipairs(node_def.groups) do
		local str_group = "group:" .. group
		if twmlib.registered_twm[str_group] then
			-- trigger twm by group
			for _, def in ipairs(twmlib.registered_twm[str_group]) do
				if def.chance then
					if math.random(1, def.chance) == 1 then
						def.action(rand_pos, node)
					end
				else
					def.action(rand_pos, node)
				end
			end
		end
	end
	minetest.after(twmlib.next_interval(), loop)
end
minetest.after(twmlib.next_interval(), loop)
