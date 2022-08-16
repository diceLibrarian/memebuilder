--
-- Load support for MT game translation.
local S = minetest.get_translator("bucket")

-- Default Liquid Namespace
Liquid_name = {}
Liquid_name.water = {}
Liquid_name.lava = {}

-- Default water and lava
Liquid_name.water.source = "default:water_source"
Liquid_name.water.flowing = "default:water_flowing"
Liquid_name.water.river_source = "default:river_water_source"
Liquid_name.water.river_flowing = "default:river_water_flowing"
Liquid_name.lava.source = "default:lava_source"
Liquid_name.lava.flowing = "default:lava_flowing"

--bucket waret and lava
Liquid_name.bucket_prefix = "bucket_"		--Prefix for bucket waters definition

-- default bucket water names - not used
Liquid_name.water.bucket_source = "bucket:bucket_water_source"
Liquid_name.water.bucket_flowing = "bucket:bucket_water_flowing"
Liquid_name.lava.bucket_source = "bucket:bucket_lava_source"
Liquid_name.lava.bucket_flowing = "bucket:bucket_lava_flowing"
Liquid_name.water.bucket_river_source = "bucket:bucket_river_water_source"
Liquid_name.water.bucket_river_flowing = "bucket:bucket_river_water_flowing"

-- Liquid flowing range definitions (Default)
local bucket_water_range = 1
local bucket_lava_range = 1
-- load settingtypes
bucket_water_range = minetest.settings:get("bucket_water_flowing_range") or bucket_water_range
bucket_lava_range = minetest.settings:get("bucket_lava_flowing_range") or bucket_lava_range

-- ABM interval for revert bucket water/lava type to original
local bucket_liquid_abm = tonumber(minetest.settings:get("bucket_liquid_abm") or 1)


-- Registred nodes according to aliases
local water_source_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.water.source]))
local water_flowing_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.water.flowing]))
local lava_source_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.lava.source]))
local lava_flowing_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.lava.flowing]))

-- NEW liquid definitions "bucket" liquid
-- run to gegister ner bucket water type
function bucket.register_bucket_water(source, flowing, name, renewable)
	
	local water_mod = source:split":"[1]			--get source mod name
	local b_prefix = Liquid_name.bucket_prefix
	
	-- check source mod of bucket definition
	if water_mod == "default" or water_mod == "bucket" then
		water_mod = "bucket"		-- if defined in this mod
	else
		b_prefix = b_prefix..water_mod.."_"		--defined from ther mod
	end
	
	-- Define new bucket water names
	local source_name = b_prefix..source:split":"[2]
	local flowing_name = b_prefix..flowing:split":"[2]
	
	-- names wit mod prefix
	Liquid_name.water[source_name]=water_mod..":"..source_name
	Liquid_name.water[flowing_name]=water_mod..":"..flowing_name
	
	-- Source water definition has to be used and changed fot bucket water definition
	local water_source_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[source]))
	water_source_def.description = S("Bucket Water Source")
	water_source_def.liquid_alternative_flowing = Liquid_name.water[flowing_name]
	water_source_def.liquid_alternative_source = Liquid_name.water[source_name]
	water_source_def.liquid_renewable = renewable
	water_source_def.liquid_origin = source		-- NEW - information for ABM to get back to the original liquid after contact with it.
	water_source_def.groups.bucket_liquid = 1

	-- For dynamic_liquid support
	if minetest.get_modpath("dynamic_liquid") then
		-- node is detroyed by lava, Lava source blocks will turn these blocks into steam.
		water_source_def.groups.dynamic_lava_source_destroys = 1
		-- node cools lava
		water_source_def.groups.dynamic_cools_lava_source = 1
		water_source_def.groups.dynamic_cools_lava_flowing = 1
	end

	-- Flowing water definition has to be used and changed fot bucket water definition
	local water_flowing_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[flowing]))
	water_flowing_def.description = S("Flowing Bucket Water")
	water_flowing_def.liquid_alternative_flowing = Liquid_name.water[flowing_name]
	water_flowing_def.liquid_alternative_source = Liquid_name.water[source_name]
	water_flowing_def.liquid_range = bucket_water_range
	water_flowing_def.liquid_renewable = false
	water_flowing_def.liquid_origin = flowing		-- NEW - information for ABM to get back to the original liquid after contact with it.
	water_flowing_def.groups.bucket_liquid = 1

-- For dynamic_liquid support
	if minetest.get_modpath("dynamic_liquid") then
				-- in dynamic_liquid is flowing water not cooling lava
		water_flowing_def.groups.cools_lava = 0
			-- node is detroyed by lava, Flowing lava will turn these blocks into steam
		water_flowing_def.groups.dynamic_lava_source_destroys = 1
		water_flowing_def.groups.dynamic_lava_flowing_destroys = 1
	end
	
	-- new water liquids are registered
	minetest.register_node(Liquid_name.water[source_name], water_source_def)
	minetest.register_node(Liquid_name.water[flowing_name], water_flowing_def)
	
	-- minetest.log(dump(minetest.registered_nodes[Liquid_name.water[source_name]]))
	-- minetest.log(dump(minetest.registered_nodes[Liquid_name.water[flowing_name]]))
	
	-- ABM to revert bucket water to original liquid
	if bucket_liquid_abm > 0 then
		minetest.register_abm({
			label = "Water "..source_name.."-"..flowing_name.." normalization",
			nodenames = {Liquid_name.water[source_name], Liquid_name.water[flowing_name]},
			neighbors = {source, flowing, "group:lava"},
			interval = bucket_liquid_abm, -- Run every 1 second
			chance = 1, -- Select every 1 nod
			action = function(pos, node, active_object_count, active_object_count_wider)
				--minetest.log("ZASAH: "..dump(node))
				if minetest.registered_nodes[node.name].liquid_origin ~= nil then
					local pos = {x = pos.x, y = pos.y, z = pos.z}
					minetest.set_node(pos, {name = minetest.registered_nodes[node.name].liquid_origin})
				end
			end
		})
	end
	
	-- return new bucket liquid names
	return {Liquid_name.water[source_name], Liquid_name.water[flowing_name]}
end

-- run to gegister ner bucket lava type
function bucket.register_bucket_lava(source, flowing, name, renewable)
	
	local lava_mod = source:split":"[1]			--get source mod name
	local b_prefix = Liquid_name.bucket_prefix

	-- check source mod of bucket definition
	if lava_mod == "default" or lava_mod == "bucket" then
		lava_mod = "bucket"		-- if defined in this mod
	else
		b_prefix = b_prefix..lava_mod.."_"		--defined from ther mod
	end

	-- Define new bucket lava names
	local source_name = b_prefix..source:split":"[2]
	local flowing_name = b_prefix..flowing:split":"[2]

	-- names wit mod prefix
	Liquid_name.lava[source_name]=lava_mod..":"..source_name
	Liquid_name.lava[flowing_name]=lava_mod..":"..flowing_name

	-- Source lava definition has to be used and changed fot bucket lava definition
	local lava_source_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.lava.source]))
	lava_source_def.description = S("Bucket Lava Source")
	lava_source_def.liquid_alternative_flowing = Liquid_name.lava[flowing_name]
	lava_source_def.liquid_alternative_source = Liquid_name.lava[flowing_name]
	lava_source_def.liquid_renewable = renewable
	lava_source_def.liquid_origin = source		-- NEW - information for ABM to get back to the original liquid after contact with it.
	lava_source_def.groups.bucket_liquid = 1

	-- Flowing lava definition has to be used and changed fot bucket lava definition
	local lava_flowing_def = minetest.deserialize(minetest.serialize(minetest.registered_nodes[Liquid_name.lava.flowing]))
	lava_flowing_def.description = S("Bucket Lava Source")
	lava_flowing_def.liquid_alternative_flowing = Liquid_name.lava[flowing_name]
	lava_flowing_def.liquid_alternative_source = Liquid_name.lava[source_name]
	lava_flowing_def.liquid_range = bucket_lava_range
	lava_flowing_def.liquid_renewable = false
	lava_flowing_def.liquid_origin = flowing		-- NEW - information for ABM to get back to the original liquid after contact with it.
	lava_flowing_def.groups.bucket_liquid = 1

	-- new lava liquids are registered
	minetest.register_node(Liquid_name.lava[source_name], lava_source_def)
	minetest.register_node(Liquid_name.lava[flowing_name], lava_flowing_def)
	
	-- minetest.log(dump(minetest.registered_nodes[Liquid_name.lava[source_name]]))
	-- minetest.log(dump(minetest.registered_nodes[Liquid_name.lava[flowing_name]]))

	-- ABM to revert bucket lava to original liquid
	if bucket_liquid_abm > 0 then
		minetest.register_abm({
			label = "Lava "..source_name.."-"..flowing_name.." normalization",
			nodenames = {Liquid_name.lava[source_name], Liquid_name.lava[flowing_name]},
			neighbors = {source, flowing, "group:water"},
			interval = bucket_liquid_abm, -- Run every 1 second
			chance = 1, -- Select every 1 nod
			action = function(pos, node, active_object_count, active_object_count_wider)
				--minetest.log("ZASAH lava: "..dump(node))
				if minetest.registered_nodes[node.name].liquid_origin ~= nil then
					local pos = {x = pos.x, y = pos.y, z = pos.z}
					minetest.set_node(pos, {name = minetest.registered_nodes[node.name].liquid_origin})
				end
			end
		})
	end

	-- return new bucket liquid names
	return {Liquid_name.lava[source_name], Liquid_name.lava[flowing_name]}
end
