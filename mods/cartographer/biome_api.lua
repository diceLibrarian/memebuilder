-- Arguments
-- util: API for uncategorized utility methods
local map_data,util,skin = ...

local biome_lookup = {}
local biome_ids = {}
local fallback_biome_lookup = {}
local biomes_ready = false
local ready_callbacks = {}
local biome_id_to_cartographer_id = {}

local function match_biome_metrics (biome, height, heat, humidity)
    return (not height or not biome.min_height or height >= biome.min_height)
       and (not height or not biome.max_height or height <= biome.max_height)
       and (not heat or not biome.min_heat or heat >= biome.min_heat)
       and (not heat or not biome.max_heat or heat <= biome.max_heat)
       and (not humidity or not biome.min_humidity or humidity >= biome.min_humidity)
       and (not humidity or not biome.max_humidity or humidity <= biome.max_humidity)
end

minetest.after(0, function()
    if map_data.api_version < 2 then
        for k,_ in pairs(minetest.registered_biomes) do
            local biome_id = minetest.get_biome_id(k)
            map_data.biomes[biome_id] = k
            biome_ids[k] = biome_id
            biome_id_to_cartographer_id[biome_id] = biome_id
        end
    else
        for k,v in ipairs(map_data.biomes) do
            biome_ids[v] = k
        end
        for k,_ in pairs(minetest.registered_biomes) do
            if not biome_ids[k] then
                table.insert(map_data.biomes, k)
                biome_ids[k] = #map_data.biomes
                biome_id_to_cartographer_id[minetest.get_biome_id(k)] = #map_data.biomes
            else
                biome_id_to_cartographer_id[minetest.get_biome_id(k)] = biome_ids[k]
            end
        end
    end
    for _,cb in ipairs(ready_callbacks) do
        cb()
    end
end)

-- Contains functions for registering and getting biome-related mapping information
return {
    -- Register a biome with textures to display. Takes arguments as a table.
    --
    -- name: A string containing the biome name
    -- textures: A table of texture names.
    --           These should correspond with detail levels,
    --           any detail level past the length of the table will return the last texture
    -- (Optional) min_height: The minimum Y position where these textures should be used
    -- (Optional) max_height: The maximum Y position where these textures should be used
    -- (Optional) min_heat: The minimum temperature where these textures should be used
    -- (Optional) max_heat: The maximum temperature where these textures should be used
    -- (Optional) min_humidity: The minimum humidity level where these textures should be used
    -- (Optional) max_humidity: The maximum humidity level where these textures should be used
    add = function (args)
        assert(args.name)
        assert(args.textures)
        table.insert(biome_lookup, table.copy(args))
    end,

    -- Register fallback biome textures to use when a biome hasn't been registered. Takes arguments as a table.
    --
    -- textures: A table of texture names.
    --           These should correspond with detail levels,
    --           any detail level past the length of the table will return the last texture
    -- (Optional) min_height: The minimum Y position where these textures should be used
    -- (Optional) max_height: The maximum Y position where these textures should be used
    -- (Optional) min_heat: The minimum temperature where these textures should be used
    -- (Optional) max_heat: The maximum temperature where these textures should be used
    -- (Optional) min_humidity: The minimum humidity level where these textures should be used
    -- (Optional) max_humidity: The maximum humidity level where these textures should be used
    add_fallback = function (args)
        assert(args.textures)
        table.insert(fallback_biome_lookup, table.copy(args))
    end,

    -- Convert a minetest biome id (temporary) into a cartography biome id (permanent)
    --
    -- id: The biome id to convert
    --
    -- Returns the biome's permamnent id, or 0 if not registered
    convert_biome_id = function(id)
        return biome_id_to_cartographer_id[id] or 0
    end,

    -- Get the permanent id of a biome from its name
    --
    -- name: A string containing the biome name
    --
    -- Returns the biome's permamnent id, or 0 if not registered
    get_biome_id = function(name)
        return biome_ids[name] or 0
    end,

    -- Get the name of a biome from its permanent id
    --
    -- id: The biome id
    --
    -- Returns the name of the biome, or "" if not registered
    get_biome_name = function(id)
        return map_data.biomes[id] or ""
    end,

    -- Get the texture name (minus index/extension) for the given biome, height, and detail level.
    --
    -- name: A string containing the biome name
    -- height: A number representing the Y position of the biome (Set to null to ignore)
    -- heat: A number representing the temperature of the biome (Set to null to ignore)
    -- humidity: A number representing the humidity of the biome (Set to null to ignore)
    -- detail: The detail level
    --
    -- Always returns a string with a texture name, if the biome is unregistered it will fallback to other options
    get_texture = function (name, height, heat, humidity, detail)
        for _,biome in pairs(biome_lookup) do
            if biome.name == name and match_biome_metrics (biome, height, heat, humidity) then
                return util.get_clamped(biome.textures, detail)
            end
        end

        -- Fallback on matching default biomes
        for _,biome in ipairs(fallback_biome_lookup) do
            if match_biome_metrics (biome, height, heat, humidity) then
                return util.get_clamped(biome.textures, detail)
            end
        end

        -- If we don't have any registered defaults, fallback to a texture
        return util.get_clamped(skin.default_biome_textures, detail)
    end,

    -- Is this API ready, or still initializing?
    is_ready = function()
        return biomes_ready
    end,

    on_ready = function(cb)
        if biomes_ready then
            cb()
        else
            table.insert(ready_callbacks, cb)
        end
    end,
}
