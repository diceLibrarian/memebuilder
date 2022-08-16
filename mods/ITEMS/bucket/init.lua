-- Minetest mod: bucket (Fork of Minetest mod)
-- See README.md for licensing and other information.

-- Load support for MT game translation.
local S = minetest.get_translator("bucket")

-- bucket item definitions
bucket = {}

bucket.empty = "bucket:bucket_empty"		-- empty bucket name prefix
bucket.water = "bucket:bucket_water_uni"	-- water bucket name prefix
bucket.water_river = "bucket:bucket_water_river"	-- river water bucket name prefix
bucket.lava = "bucket:bucket_lava_uni"		-- lava bucket name prefix
bucket.default = {}		-- default bucket names
bucket.default_material = minetest.settings:get("bucket_default_type") or "steel"	-- default material for bucket
bucket.liquids = {}		-- all buckets for defined liquid

-- standard bucket recipe (like in minecraft)
-- conflicts "Wood Empty Bucket" with farming "Wooden Bowl"
bucket.recipe_clasic ={
				{"MATERIAL", "", "MATERIAL"},
				{"", "MATERIAL", ""}
}
-- new recipe for bucket
bucket.recipe_new ={
				{"MATERIAL", "", "MATERIAL"},
				{"MATERIAL", "", "MATERIAL"},
				{"MATERIAL", "MATERIAL", "MATERIAL"}
}

-- define bucket liquids and Liquid_name
dofile(minetest.get_modpath("bucket") .. "/bucket_liquids.lua")

-- Read settinf in boolean and return integer
-- Used for get lava groups
local function Bool2Int_setting(settingtype, default_setting)
	if minetest.settings:get_bool(settingtype, default_setting) then
		return 1
	else
		return 0
	end
end

-- craft diferent types of bucket
-- recipe can be anjustet for every material type
local craft_ingreds = {
	wood = {"group:wood", "default_wood.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_wood", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_wood", false)}
	},
	stone = {"group:stone", "default_stone.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_stone", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_stone", true)}
	},
	steel = {"default:steel_ingot", "default_steel_block.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_steel", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_steel", true)}
	},
	bronze = {"default:bronze_ingot", "default_bronze_block.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_bronze", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_bronze", false)}
	},
	mese = {"default:mese_crystal", "default_mese_block.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_mese", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_mese", true)}
	},
	diamond = {"default:diamond", "default_diamond_block.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_diamond", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_diamond", true)}
	},
	gold = {"default:gold_ingot", "default_gold_block.png",
		recipe = table.copy(bucket.recipe_clasic),
		enabled = minetest.settings:get_bool("bucket_material_gold", true),
		groups = {tool = 1, get_lava = Bool2Int_setting("bucket_getlava_gold", false)}
	}
}

-- Default bucket names
bucket.default.empty = bucket.empty.."_"..bucket.default_material
bucket.default.water = bucket.water.."_"..bucket.default_material
bucket.default.lava = bucket.lava.."_"..bucket.default_material

-- Bucket aliases - default bucket ist steel
minetest.register_alias("bucket", bucket.default.empty)
minetest.register_alias("bucket_water", bucket.default.water)
minetest.register_alias("bucket_lava", bucket.default.lava)
-- for compatibility witk old bucket mod
minetest.register_alias("bucket:bucket_empty", bucket.default.empty)
minetest.register_alias("bucket:bucket_water", bucket.default.water)
minetest.register_alias("bucket:bucket_lava", bucket.default.lava)

-- set new recipe if enabled
local use_clasic_recipe = minetest.settings:get_bool("bucket_use_clasic_recipe", true)

if not use_clasic_recipe then
	for idx, mat in pairs(craft_ingreds) do
		craft_ingreds[idx].recipe = table.copy(bucket.recipe_new)
	end
end

-- according to source (liquid type) assign bucket with "bucket" liquid
-- with this you can override the mod setting
bucket.giving_back={
		-- return bucket for standard water and lava
		-- [Liquid_name.lava.source]=bucket.lava,
		-- [Liquid_name.water.source]=bucket.water,
		-- return bucket for river water
		-- [Liquid_name.water.river_source ]=bucket.water,
		-- return bucket for bucket water and lava
		-- [Liquid_name.lava.bucket_source]=bucket.lava,
		-- [Liquid_name.water.bucket_source]=bucket.water,
 		}

-- if true, the flowing water can be taken in the bucket
-- load settingtypes
local get_flowing_liquid = minetest.settings:get_bool("bucket_get_flowing", true)

-- Function relpaces all "MATERIAL" with new/real material definition new_mat
local function replace_recipe_material(recipe_def, new_mat)
	local recipe_mat = table.copy(recipe_def)
	for r_row_idx, r_row in pairs(recipe_def) do
		for r_idx, r_mat in pairs(r_row) do
			if r_mat=="MATERIAL" then
				recipe_mat[r_row_idx][r_idx]=new_mat
			end
		end
	end
	return recipe_mat
end

-- Register empty buckets crafting recipes
for name, mat in pairs(craft_ingreds) do
	-- replace "MATERIAL" with correct one
	local bucket_recipe = replace_recipe_material(mat.recipe, mat[1])
	
	-- register new empty bucket crafting recipe
	minetest.register_craft({
		output = "bucket:bucket_empty".."_"..name,
		recipe = table.copy(bucket_recipe)
	})
end

-- for compatibility
minetest.register_alias("bucket:bucket_empty", "bucket:bucket_empty_steel")

-- protection - from original bucket mod
-- not analysed yet
local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- ============================================================================
-- Register a new liquid (bucket.register_liquid)
--    source = name of the source node
--    flowing = name of the flowing node
--    itemname = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--		- this new bucket mod version defines is as table, e.g. {empty = "bucket_uni.png", materials = craft_ingreds, fill = "bucket_uni_lava.png"}
--		- if only one image is defined, then thi imege is used for liquid and bucket materials are from this mod
--    name = text description of the bucket item
--    groups = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew = (optional) bool. Force the liquid source to renew if it has a
--                  source neighbour, even if defined as 'liquid_renewable = false'.
--                  Needed to avoid creating holes in sloping rivers.
--    giving_back = (NEW) defines the bucket to return (optional, not tested)
-- This function can be called from any mod (that depends on bucket).

local function register_full_bucket(source, flowing, itemname, inventory_image, name,
		groups, force_renew, giving_back)
	minetest.register_craftitem(itemname, {
		description = name,
		inventory_image = inventory_image,
		stack_max = 1,
		liquids_pointable = true,
		groups = groups,

		on_place = function(itemstack, user, pointed_thing)
			-- Must be pointing to node
			if pointed_thing.type ~= "node" then
				return
			end

			local node = minetest.get_node_or_nil(pointed_thing.under)
			local ndef = node and minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if ndef and ndef.on_rightclick and
					not (user and user:is_player() and
					user:get_player_control().sneak) then
				return ndef.on_rightclick(
					pointed_thing.under,
					node, user,
					itemstack)
			end

			local lpos

			-- Check if pointing to a buildable node
			if ndef and ndef.buildable_to then
				-- buildable; replace the node
				lpos = pointed_thing.under
			else
				-- not buildable to; place the liquid above
				-- check if the node above can be replaced

				lpos = pointed_thing.above
				node = minetest.get_node_or_nil(lpos)
				local above_ndef = node and minetest.registered_nodes[node.name]

				if not above_ndef or not above_ndef.buildable_to then
					-- do not remove the bucket with the liquid
					return itemstack
				end
			end

			if check_protection(lpos, user
					and user:get_player_name()
					or "", "place "..source) then
				return
			end

			minetest.set_node(lpos, {name = source})
			return ItemStack(giving_back)
		end
	})
end

-- Function to register new liquid in bucket
function bucket.register_liquid(source, flowing, itemname, inventory_image, name,
		groups, force_renew, giving_back)

	if itemname ~= nil then

-- TODO - doplnit pre bucket water aj pre source obycany

		local inv_images

		if type(inventory_image) == "string" then
			-- if only one image is defined (like from other mod)
			-- material are from predefined craft_ingreds
			-- fill/liquid image ist taken from the inventory_image
			inv_images = {empty = "bucket_uni.png", materials = craft_ingreds, fill = "bucket_uni_fill.png"}
		else
			-- if more images in table are defined = more materials
			-- suplied materials and images are used - has to be like in this mod defined
			inv_images = inventory_image
		end
		-- bucket.liquids defined for original source and flowing
		-- more or less dummy, real item definition is for bucket liquids
		bucket.liquids[source] = {
			source = source,
			flowing = flowing,
			--itemname = itemname, -- buckets are defined later
			force_renew = force_renew,
		}
		
		-- define all buckets (itemanames) for all materials
		bucket.liquids[source].itemname = {}	-- all buckets for defined source
		for mat_name, mat in pairs(inv_images["materials"]) do
			local bucket_itemname = itemname.."_"..mat_name		--delivered itemname + material name
			bucket.liquids[source].itemname[mat_name]=bucket_itemname
		end
		
		bucket.liquids[flowing] = bucket.liquids[source]		-- the same for flowing liquid
		
		-- generate bucket liquids
		local bucket_liq		-- for bucket liquid names {bucket source, bucket flowing}
		if minetest.registered_nodes[source] ~= nil then				-- if source really exists
			if minetest.registered_nodes[source].groups.lava then		-- check if it is lava liquid
				-- create new bucket lava with reduced flowing
				bucket_liq = bucket.register_bucket_lava(source, flowing, name, force_renew)
			else
				-- create new bucket water with reduced flowing
				bucket_liq = bucket.register_bucket_water(source, flowing, name, force_renew)
			end
		end
		
		-- bucket liquid names {bucket source, bucket flowing}
		-- replaces the delivered source and flowing names
		source = bucket_liq[1]
		flowing = bucket_liq[2]
		
		-- bucket liquids definition for new buket water/lava liquid
		bucket.liquids[source] = {
			source = source,
			flowing = flowing,
			--itemname = itemname, -- buckets are defined later
			force_renew = force_renew,
		}
		bucket.liquids[source].itemname = {}	-- all buckets for defined source
		
		-- loop for all materials in inv_images
		-- to define new full buckets with the delivered liquid (changed to bucket liquid)
		for mat_name, mat in pairs(inv_images["materials"]) do
			if mat["enabled"] then		-- check if this material is enabled in settingtypes
				local Mat_name_txt = mat_name:gsub("^%l", string.upper)		--get material text
				local bucket_material_name = S(Mat_name_txt)			-- material text translated
				local bucket_name = bucket_material_name.." "..name			-- material + bucket name
				local bucket_itemname = itemname.."_"..mat_name				-- new bucket name
				giving_back = bucket.empty.."_"..mat_name				-- coresponding empty bucket
				bucket.liquids[source].itemname[mat_name]=bucket_itemname	-- add to bucket for this bucker source
				
				-- different image creation ist defined for all material
				local bucket_inv_image
				
				if type(inventory_image) == "string" then
					-- only one image was delivered - inventory_image = liquid (filling)
					-- like from other mods
				 	local bucket_fill_image = "("..inventory_image.."^[resize:16x16".."^[colorize:#fff:30^"..inv_images["fill"].."^[noalpha^[makealpha:0,255,0)"
				 	bucket_inv_image = mat[2].."^[resize:16x16".."^[colorize:#fff:30^bucket_uni.png".."^[noalpha^[makealpha:0,255,0^"..bucket_fill_image
				else
					-- all images for bucket are defined
					-- definition in this mod
					bucket_inv_image = mat[2].."^[resize:16x16".."^[colorize:#fff:30^bucket_uni.png^"..inv_images["fill"].."^[noalpha^[makealpha:0,255,0"
				end

				register_full_bucket(source, flowing, bucket_itemname, bucket_inv_image, bucket_name,
				groups, force_renew, giving_back)
			end
		end
	end

	-- the same for flowing liquid
	bucket.liquids[flowing] = bucket.liquids[source]

end

-- Use this function, if you want to change the defined liquid to destination_source
-- when taken in the bucket
-- like river water in this mod
-- destination_source is optional, default = standard water)
-- destination_source has to be defined first
function bucket.register_bucket_as_diffrent_liquid(source, flowing, destination_source, force_renew)
	local destination_source = destination_source or Liquid_name.water.source
	local force_renew = force_renew or false
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = bucket.liquids[destination_source].itemname,
		force_renew = force_renew,
	}
	bucket.liquids[flowing] = bucket.liquids[source]
end
-- ============================================================================

-- Register Empty buckets
for mat_name, mat in pairs(craft_ingreds) do
	if mat["enabled"] then
		-- Capitalise first character
		local Name = mat_name:gsub("^%l", string.upper)
		-- register all empty buckets
		local bucket_empty = bucket.empty.."_"..mat_name
		minetest.register_craftitem(bucket_empty, {
			description = S(Name).." "..S("Empty Bucket"),
			--inventory_image = "bucket.png",
			-- inventory_image created from bucket_uni.png and defined material texture mat[2] (craft_ingreds)
			inventory_image = mat[2].."^[resize:16x16".."^[colorize:#fff:30^bucket_uni.png^[noalpha^[makealpha:0,255,0",
			--groups = {tool = 1},
			groups = mat["groups"],
			liquids_pointable = true,
			on_use = function(itemstack, user, pointed_thing)
				if pointed_thing.type == "object" then
					pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
					return user:get_wielded_item()
				elseif pointed_thing.type ~= "node" then
					-- do nothing if it's neither object nor node
					return
				end
				-- Check if pointing to a liquid source
				local node = minetest.get_node(pointed_thing.under)
				local liquiddef = bucket.liquids[node.name]
				local item_count = user:get_wielded_item():get_count()
				
				-- Check if is lava and if lava can be taken
				-- exit if it not allowed - group get_lava = 0
				local bucket_name = itemstack:get_name()
				if minetest.registered_nodes[node.name].groups.lava and minetest.get_item_group(bucket_name, "get_lava")==0 then
					return
				end
				-- node.name == liquiddef.flowing return water even from flowing liquid
					-- get_flowing_liquid - if this is enabled
				if liquiddef ~= nil
				and liquiddef.itemname ~= nil
				and (node.name == liquiddef.source
					or (node.name == liquiddef.flowing and get_flowing_liquid)) then
					if check_protection(pointed_thing.under,
										user:get_player_name(),
										"take ".. node.name) then
										return
					end

					-- find source for the flowing liquid
					if node.name == liquiddef.flowing then
						-- source_dist max. distance from flowing node, if Nil, the max. = 8 is used
						local source_dist = tonumber(minetest.registered_nodes[liquiddef.flowing].liquid_range) or 8
						-- Find source node position
						local source_pos = minetest.find_node_near(pointed_thing.under, source_dist, liquiddef.source) -- position of the source node
						-- If found, then replace with flowing node
						if source_pos ~= nil then
							minetest.set_node(source_pos, {name = liquiddef.flowing})
						else
							-- if source not found, then do nothing
							return
						end
					end


					-- default set to return filled bucket
					-- defined in this script
					local giving_back = bucket.giving_back[liquiddef.source]	--TODO - test this

					-- giving_back from original bucket
					if giving_back == nil then
						-- if type(liquiddef.itemname) == "string" then
						-- 	giving_back = liquiddef.itemname
						-- else
							giving_back = liquiddef.itemname[mat_name]
						-- end
					end

					-- check if holding more than 1 empty bucket
					if item_count > 1 then

						-- if space in inventory add filled bucked, otherwise drop as item
						local inv = user:get_inventory()
						if inv:room_for_item("main", {name=giving_back}) then
							inv:add_item("main", giving_back)
						else
							local pos = user:get_pos()
							pos.y = math.floor(pos.y + 0.5)
							minetest.add_item(pos, giving_back)
						end

						-- set to return empty buckets minus 1
						itemstack:take_item()
						giving_back = itemstack

					end

					-- force_renew requires a source neighbour
					local source_neighbor = false
					if liquiddef.force_renew then
						source_neighbor =
							minetest.find_node_near(pointed_thing.under, 1, liquiddef.source)
					end
					if not (source_neighbor and liquiddef.force_renew) then
						minetest.add_node(pointed_thing.under, {name = "air"})
					end

					return ItemStack(giving_back)
				else
					-- non-liquid nodes will have their on_punch triggered
					local node_def = minetest.registered_nodes[node.name]
					if node_def then
						node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
					end
					return user:get_wielded_item()
				end
			end,
		})
	end
end


-- define bucket for water source
bucket.register_liquid(
	Liquid_name.water.source,
	Liquid_name.water.flowing,
	bucket.water,
	{empty = "bucket_uni.png", materials = craft_ingreds, fill = "bucket_uni_water.png"},
	S("Water Bucket"),
	{tool = 1, water_bucket = 1},
	false
)


-- River water source is 'liquid_renewable = false' to avoid horizontal spread
-- of water sources in sloping rivers that can cause water to overflow
-- riverbanks and cause floods.
-- River water source is instead made renewable by the 'force renew' option
-- used here.

-- define bucket for river water source
Unify_river_water = minetest.settings:get_bool("bucket_unify_river_water", false)		-- get setting

-- Special river water behavior according to setting
if Unify_river_water then			-- take river water as normal water
	bucket.register_bucket_as_diffrent_liquid(
		Liquid_name.water.river_source,
		Liquid_name.water.river_flowing,
		Liquid_name.water.source,
		false
	)
else		-- define new bucket for river water
	bucket.register_liquid(
		Liquid_name.water.river_source,
		Liquid_name.water.river_flowing,
		bucket.water_river,
		{empty = "bucket_uni.png", materials = craft_ingreds, fill = "bucket_uni_river_water.png"},
		S("River Water Bucket"),
		{tool = 1, water_bucket = 1},
		false
	)
end

-- define bucket for lava source
bucket.register_liquid(
	Liquid_name.lava.source,
	Liquid_name.lava.flowing,
	bucket.lava,
	{empty = "bucket_uni.png", materials = craft_ingreds, fill = "bucket_uni_lava.png"},
	S("Lava Bucket"),
	{tool = 1},
	false
)


-- Add lava as fuel
for mat_name, mat in pairs(craft_ingreds) do
	local bucket_empty = bucket.empty.."_"..mat_name
	local bucket_lava = bucket.lava.."_"..mat_name
	
	if mat["enabled"] and mat["groups"].get_lava==1 then
		minetest.register_craft({
			type = "fuel",
			recipe = bucket_lava,
			burntime = 60,
			replacements = {{bucket_lava, bucket_empty}},
		})
	end
end

-- Register buckets as dungeon loot
if minetest.global_exists("dungeon_loot") then
	for mat_name, mat in pairs(craft_ingreds) do
		local bucket_empty = bucket.empty.."_"..mat_name
		local bucket_lava = bucket.lava.."_"..mat_name
		local bucket_water = bucket.water.."_"..mat_name
		
		if mat["enabled"] then
			-- water in deserts/ice or above ground, lava otherwise if enabled
			dungeon_loot.register({
				{name = bucket_empty, chance = 0.55},
				{name = bucket_water, chance = 0.45,
					types = {"sandstone", "desert", "ice"}},
				{name = bucket_water, chance = 0.45, y = {0, 32768},
					types = {"normal"}},
			})
			
			if mat["groups"].get_lava==1 then
				dungeon_loot.register({
					{name = bucket_lava, chance = 0.45, y = {-32768, -1},
						types = {"normal"}},
				})
			end
			
		end
	end
end

--minetest.log(dump(minetest.registered_abms))
