-- Arguments
-- settings: The mod settings
local settings = ...

-- The current API version
local MAX_API_VERSION = 2

-- Storage and saving
local mod_storage = minetest.get_mod_storage()
local map_data = {
    -- Scanned map data
    generated = minetest.deserialize(mod_storage:get_string("map")) or {},

    -- Maps
    maps = minetest.deserialize(mod_storage:get_string("maps")) or {},

    biomes = minetest.deserialize(mod_storage:get_string("biomes")) or {},

    -- The next id
    next_map_id = mod_storage:get_int("next_map_id"),

    -- The version of the map api
    api_version = mod_storage:get_int("api_version"),
}

-- Is this API ready, or still initializing?
--
-- self: The map_data instance
function map_data.is_ready(self)
    return self.api_version == MAX_API_VERSION
end

if map_data.next_map_id == 0 then
    map_data.next_map_id = 1
end

if map_data.api_version == 0 then
    map_data.api_version = 1
end

assert(map_data.api_version <= MAX_API_VERSION)

local private_storage = {
    migrations = { },
}

-- Update the API version, performing any necessary data migrations
function private_storage.migrate_data(version, api)
    if version <= MAX_API_VERSION then
        map_data.api_version = version

        for i=version+1,MAX_API_VERSION do
            if private_storage.migrations[i] then
                private_storage.migrations[i](api)
                return
            end
        end
    end

    api.is_ready = true
end

-- API version 2: Generate biomes from existing IDs
table.insert(private_storage.migrations, 2, function(api)
    -- Migration depends on async biome init, so we wait for that then increment the version
    api.biomes.on_ready(function()
        private_storage.migrate_data(2, api)
    end)
end)

local function save()
    if not map_data:is_ready() then
        return
    end
    mod_storage:set_string("biomes", minetest.serialize(map_data.biomes))
    mod_storage:set_string("maps", minetest.serialize(map_data.maps))
    mod_storage:set_int("next_map_id", map_data.next_map_id)
    mod_storage:set_string("map", minetest.serialize(map_data.generated))
    mod_storage:set_int("api_version", map_data.api_version)
end
minetest.register_on_shutdown(save);
minetest.register_on_leaveplayer(save);

if settings.autosave_freq ~= 0 then
    local function periodic_save()
        save();
        minetest.after(settings.autosave_freq, periodic_save);
    end
    minetest.after(settings.autosave_freq, periodic_save);
end

return map_data,private_storage
