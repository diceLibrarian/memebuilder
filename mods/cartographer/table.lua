-- Arguments
-- gui: The GUI API
-- gui_skin: The GUI skin
-- audio: The audio playback API
-- maps: The map API
-- materials: The material API
-- map_item: The map item API
-- settings: The mod settings
local gui, gui_skin, audio, maps, materials, map_item, settings = ...

local SCALE_SMALL = 1
local SCALE_MEDIUM = 2
local SCALE_LARGE = 4
local SCALE_HUGE = 8

-- Get the material cost for the given map scale and detail level
--
-- scale: The map scale
-- detail: The detail level
--
-- Returns a table with material costs
local function get_material_cost(scale, detail)
    local paper = scale * 4
    local pigment = detail * 5

    if scale == SCALE_SMALL then
        pigment = pigment + 5
    elseif scale == SCALE_MEDIUM then
        pigment = pigment + 10
    elseif scale == SCALE_LARGE then
        pigment = pigment + 15
    elseif scale == SCALE_HUGE then
        pigment = pigment + 20
    end

    return {
        paper = math.max(paper, 0),
        pigment = math.max(pigment, 0),
    }
end

-- Get the material cost of the craft settings from the given table metadata
--
-- meta: The metadata to read
--
-- Returns a table with the material costs, and a boolean indicating if the
-- costs were positive or negative before clamping.
local function get_craft_material_cost(meta)
    local cost = get_material_cost(meta:get_int("scale") or SCALE_SMALL, meta:get_int("detail") or 0)
    local stack = meta:get_inventory():get_stack("output", 1)
    local is_positive = true

    if stack:get_name() == "cartographer:map" then
        local smeta = stack:get_meta()
        local sub_cost = get_material_cost(smeta:get_int("cartographer:scale") or SCALE_SMALL,
                                          (smeta:get_int("cartographer:detail") or 1) - 1)
        is_positive = cost.paper >= sub_cost.paper and cost.pigment >= sub_cost.pigment
        cost.paper = math.max(cost.paper - sub_cost.paper, 0)
        cost.pigment = math.max(cost.pigment - sub_cost.pigment, 0)
    end

    return cost, is_positive
end

-- Check if the given table metadata has enough materials to cover the given
-- cost table.
--
-- cost: A table of material costs
-- meta: The metadata
--
-- Returns true if the table's materials can cover the cost
local function can_afford(cost, meta)
    return cost.paper + cost.pigment > 0
       and cost.paper <= meta:get_int("paper")
       and cost.pigment <= meta:get_int("pigment")
end

-- Get the material cost of the copy settings from the given table metadata
--
-- meta: The metadata to read
--
-- Returns a table with the material costs
local function get_copy_material_cost(meta)
    local inv = meta:get_inventory()
    local in_stack = inv:get_stack("copy_input", 1)
    local out_stack = inv:get_stack("copy_output", 1)


    if out_stack:is_empty() and in_stack:get_name() == "cartographer:map" then
        local smeta = in_stack:get_meta()
        local scale = smeta:get_int("cartographer:scale") or SCALE_SMALL
        local detail = smeta:get_int("cartographer:detail") or 1

        return get_material_cost(scale, detail - 1)
    end

    return {
        paper = 0,
        pigment = 0,
    }
end

local fs = {}

-- Draw a 1px thick horizontal separator formspec element
--
-- y: The y position of the separator
-- width: The wisth of the separator
-- skin: A 9-slice background skin table
--
-- Returns a formspec string
function fs.separator(y, width, skin)
    return gui.bg9 {
        x = 0,
        y = y,
        w = width,
        h = 0.01,

        skin = skin,
    }
end

-- Draw all the essential formspec data (size, background, styles, tabs)
--
-- w: The width of the formspec
-- h: The height of the formspec
-- rank: An into defining the 'rank' of the table being displayed
-- tab: An int defining the index of the selected tab
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.header(w, h, rank, tab, skin)
    local tabs_x = skin.background.margin_x + skin.inner_background.margin_x
    local tabs_y = skin.background.margin_y - skin.tab.height

    local data = {
        gui.formspec {
            w = w,
            h = h,

            bg = skin.background,
        },
        gui.bg9 {
            x = skin.background.margin_x,
            y = skin.background.margin_y,

            w = w - skin.background.margin_x * 2,
            h = h - skin.background.margin_y * 2,

            skin = skin.inner_background,
        },

        gui.style_type {
            selector = "button",
            properties = {
                noclip = true,
                border = false,

                bgimg = skin.tab.texture .. ".png",
                bgimg_hovered = skin.tab.hovered_texture .. ".png",
                bgimg_pressed = skin.tab.pressed_texture .. ".png",
                bgimg_middle = skin.tab.radius,
                padding = skin.tab.padding or -skin.tab.radius,
                textcolor = skin.tab.font_color,
            }
        },
        gui.style {
            selector = "tab" .. tostring(tab),
            properties = {
                bgimg = skin.tab.selected_texture .. ".png",
                bgimg_hovered = skin.tab.selected_texture .. ".png",
                bgimg_pressed = skin.tab.selected_texture .. ".png",
            }
        },

        gui.button {
            x = tabs_x,
            y = tabs_y,

            w = skin.tab.width,
            h = skin.tab.height,

            id = "tab1",

            text = "Materials"
        },
        gui.button {
            x = tabs_x + skin.tab.width,
            y = tabs_y,

            w = skin.tab.width,
            h = skin.tab.height,

            id = "tab2",

            text = "Create Map"
        },
    }

    if rank >= 2 then
        table.insert(data, gui.button {
            x = tabs_x + skin.tab.width * 2,
            y = tabs_y,

            w = skin.tab.width,
            h = skin.tab.height,

            id = "tab3",

            text = "Copy Map"
        })
    end

    table.insert(data, gui.style_type {
        selector = "button",
        properties = {
            bgimg = skin.button.texture .. ".png",
            bgimg_hovered = skin.button.hovered_texture .. ".png",
            bgimg_pressed = skin.button.pressed_texture .. ".png",
            bgimg_middle = skin.button.radius,
            padding = skin.button.padding or -skin.button.radius,

            textcolor = skin.button.font_color,
        },
    })
    table.insert(data, gui.style {
        selector = "disabled_button",
        properties = {
            bgimg = "",
            bgimg_hovered = "",
            bgimg_pressed = "",

            textcolor = skin.button.disabled_font_color,
        },
    })

    return table.concat(data)
end

-- Draw material counters from a table's metadata
--
-- x: The x position of the labels
-- y: The y position of the labels
-- meta: A metadata object containing the material quantities
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.materials(x, y, meta, skin)
    local indicator_w = skin.material_indicator.width
    local indicator_h = skin.material_indicator.height
    local indicator_spacing = skin.material_indicator.spacing
    local margin_x = skin.label.margin_x
    local margin_y = skin.label.margin_y
    local inner_h = indicator_h - (margin_y * 2)

    return gui.container {
        x = x,
        y = y,
        w = indicator_w,
        h = indicator_h,
        bg = skin.label,

        gui.image {
            x = margin_x,
            y = margin_y,

            w = inner_h,
            h = inner_h,

            image = skin.paper_texture .. ".png",
        },
        gui.label {
            x = margin_x + inner_h + margin_y, -- y because the previous element uses the inner height
            y = margin_y + inner_h * 0.5,

            textcolor = skin.label.font_color,
            text = string.format("× %d", meta:get_int("paper")),
        },
    } .. gui.container {
        x = x + indicator_w + indicator_spacing,
        y = y,
        w = indicator_w,
        h = indicator_h,
        bg = skin.label,

        gui.image {
            x = margin_x,
            y = margin_y,

            w = inner_h,
            h = inner_h,

            image = skin.pigment_texture .. ".png",
        },
        gui.label {
            x = margin_x + inner_h + margin_y, -- See previous label
            y = margin_y + inner_h * 0.5,

            textcolor = skin.label.font_color,
            text = string.format("× %d", meta:get_int("pigment")),
        },
    }
end

-- Draw a label with material costs from a table
--
-- x: The x position of the interface
-- y: The y position of the interface
-- cost: A table of material costs, with string keys for the material
--       names and integer values
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.cost(x, y, cost, skin)
    local indicator_w = skin.material_indicator.width
    local indicator_h = skin.material_indicator.height
    local margin_x = skin.label.margin_x
    local margin_y = skin.label.margin_y
    local inner_h = indicator_h - (margin_y * 2)
    local data = {
        gui.bg9 {
            x = x,
            y = y,
            w = indicator_w,
            h = indicator_h * 2,

            skin = skin.label,
        },
    }

    local i = 0
    for name,value in pairs(cost) do
        local texture = ""
        if name == "paper" then
            texture = skin.paper_texture .. ".png"
        elseif name == "pigment" then
            texture = skin.pigment_texture .. ".png"
        end

        table.insert(data, gui.image {
            x = x + margin_x,
            y = y + (i * inner_h),
            w = inner_h,
            h = inner_h,

            image = texture,
        })

        table.insert(data, gui.label {
            x = x + margin_x + inner_h,
            y = y + ((i + 0.5) * inner_h),

            textcolor = skin.label.font_color,
            text = string.format("× %d", value),
        })

        i = i + 1
    end

    return table.concat(data)
end

-- Draw the material conversion tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- pos: The table position (for displaying the inventory)
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.convert(x, y, pos, skin)
    local meta = minetest.get_meta(pos)
    local value = materials.get_stack_value(meta:get_inventory():get_stack("input", 1))

    local button_w = skin.button.width
    local button_h = skin.button.height
    local inv_w = skin.slot.width
    local inv_h = skin.slot.height
    local indicator_w = skin.material_indicator.width
    local indicator_h = skin.material_indicator.height * 2
    local indicator_spacing = skin.material_indicator.spacing

    return gui.container {
        x = x,
        y = y,

        gui.inventory {
            x = 0,
            y = 0,
            w = inv_w,
            h = inv_h,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            id = "input",
            bg = skin.slot,
            tooltip = "Place items here to convert\nthem into mapmaking materials",
        },

        fs.cost(inv_w + indicator_spacing, (inv_h - indicator_h) * 0.5, value, skin),

        gui.button {
            x = inv_w + indicator_w + indicator_spacing * 2,
            y = (inv_h - button_h) * 0.5,
            w = button_w,
            h = button_h,

            id = "convert",
            text = "Convert Materials",
            disabled = value.paper + value.pigment <= 0,
        },
    }
end

-- Draw the map crafting tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- pos: The table position (for displaying the inventory)
-- rank: The 'rank' of the table
-- meta: A metadata object containing the table settings and material
--       quantities
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.craft(x, y, pos, rank, meta, skin)
    local cost, is_positive = get_craft_material_cost(meta)
    local stack = meta:get_inventory():get_stack("output", 1)

    local button_w = skin.button.width
    local button_h = skin.button.height
    local inv_w = skin.slot.width
    local inv_h = skin.slot.height
    local indicator_w = skin.material_indicator.width
    local indicator_h = skin.material_indicator.height * 2
    local indicator_spacing = skin.material_indicator.spacing
    local radio = skin.radio

    local data = {
        x = x,
        y = y,

        gui.container {
            x = 0,
            y = radio.height + radio.margin_y * 2,

            gui.inventory {
                x = 0,
                y = 0,
                w = inv_w,
                h = inv_h,

                location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
                id = "output",
                bg = skin.slot,
                tooltip = "Place a map here to upgrade it,\nor leave empty to craft",
            },

            fs.cost(inv_w + indicator_spacing, (inv_h - indicator_h) * 0.5, cost, skin),

            gui.button {
                x = inv_w + indicator_w + indicator_spacing * 2,
                y = (inv_h - button_h) * 0.5,
                w = button_w,
                h = button_h,

                id = "craft",
                text = stack:get_name() == "cartographer:map" and "Upgrade Map" or "Craft Map",
                disabled = not (is_positive and can_afford(cost, meta)),
            },
        },

        gui.style {
            selector = string.format("%dx,%d", meta:get_int("scale"), meta:get_int("detail") + 1),
            properties = {
                bgimg = skin.button.selected_texture .. ".png",
                bgimg_hovered = skin.button.selected_texture .. ".png",
                bgimg_pressed = skin.button.selected_texture .. ".png",
            },
        },
        gui.label {
            x = 0,
            y = 0,

            text = "Detail Level",
            textcolor = skin.label.font_color,
        },
    }

    table.insert(data, gui.button {
        x = 0,
        y = radio.margin_y,
        w = radio.width,
        h = radio.height,

        id = "1",
        text = "1",
    })
    table.insert(data, gui.button {
        x = radio.width,
        y = radio.margin_y,
        w = radio.width,
        h = radio.height,

        id = "2",
        text = "2",
    })
    if rank > 1 then
        table.insert(data, gui.button {
            x = radio.width * 2,
            y = radio.margin_y,
            w = radio.width,
            h = radio.height,

            id = "3",
            text = "3",
        })
        if rank > 2 then
            table.insert(data, gui.button {
                x = radio.width * 3,
                y = radio.margin_y,
                w = radio.width,
                h = radio.height,

                id = "4",
                text = "4",
            })
        end
    end

    if rank > 1 then
        table.insert(data, gui.button {
            x = radio.margin_x + radio.width * 4,
            y = radio.margin_y,
            w = radio.width,
            h = radio.height,

            id = "1x",
            text = "1×",
        })
        table.insert(data, gui.button {
            x = radio.margin_x + radio.width * 5,
            y = radio.margin_y,
            w = radio.width,
            h = radio.height,

            id = "2x",
            text = "2×",
        })

        if rank > 2 then
            table.insert(data, gui.button {
                x = radio.margin_x + radio.width * 6,
                y = radio.margin_y,
                w = radio.width,
                h = radio.height,

                id = "4x",
                text = "4×",
            })
            table.insert(data, gui.button {
                x = radio.margin_x + radio.width * 7,
                y = radio.margin_y,
                w = radio.width,
                h = radio.height,

                id = "8x",
                text = "8×",
            })
        end
    end

    return gui.container(data)
end

-- Draw the map copying tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- width: The width to fill
-- pos: The table position (for displaying the inventory)
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.copy(x, y, width, pos, skin)
    local meta = minetest.get_meta(pos)
    local costs = get_copy_material_cost(meta)

    local button_w = skin.button.width
    local button_h = skin.button.height
    local inv_w = skin.slot.width
    local inv_h = skin.slot.height
    local indicator_w = skin.material_indicator.width
    local indicator_h = skin.material_indicator.height * 2
    local indicator_spacing = skin.material_indicator.spacing

    return gui.container {
        x = x,
        y = y,

        gui.inventory {
            x = 0,
            y = 0,
            w = inv_h,
            h = inv_w,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            id = "copy_input",
            bg = skin.slot,
        },
        gui.inventory {
            x = width - inv_w,
            y = 0,
            w = inv_w,
            h = inv_h,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            id = "copy_output",
            bg = skin.slot,
        },
        fs.cost(inv_w + indicator_spacing, (inv_h - indicator_h) * 0.5, costs, skin),
        gui.button {
            x = inv_w + indicator_w + indicator_spacing * 2,
            y = (inv_h - button_h) * 0.5,
            w = button_w,
            h = button_h,

            id = "copy",
            text = "Copy Map",
            disabled = not can_afford(costs, meta),
        },
    }
end

-- Draw the player's inventory
--
-- x: The x position of the inventory
-- y: The y position of the inventory
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.inv(x, y, skin)
    return gui.inventory {
        x = x,
        y = y,
        w = gui_skin.player_inv_columns,
        h = gui_skin.player_inv_rows,

        location = "current_player",
        id = "main",
        bg = skin.slot,
    }
end

local player_tables = {}

-- Show the table formspec to the specified player
-- The player must be recorded in player_tables in order to receive
-- a formspec.
--
-- player: The player's name
local function table_formspec(player)
    local data = player_tables[player]
    local pos = data.pos

    if not pos then
        return
    end

    local meta = minetest.get_meta(pos)

    local rank = 1
    local skin = gui_skin.table_skins.simple_table
    local name = minetest.get_node(pos).name
    if name == "cartographer:standard_table" then
        rank = 2
        skin = gui_skin.table_skins.standard_table
    elseif name == "cartographer:advanced_table" then
        rank = 3
        skin = gui_skin.table_skins.advanced_table
    end

    local outer_x = skin.background.margin_x
    local outer_y = skin.background.margin_y
    local inner_x = skin.inner_background.margin_x
    local inner_y = skin.inner_background.margin_y

    local inv_width = skin.slot.width * gui_skin.player_inv_columns
                    + (skin.slot.column_margin * (gui_skin.player_inv_columns - 1))
    local inv_height = skin.slot.height * gui_skin.player_inv_rows
                     + (skin.slot.row_margin * (gui_skin.player_inv_rows - 1))
    local inner_width = inv_width + inner_x * 2
    local width = inner_width + outer_x * 2

    local sep_height = skin.material_indicator.spacing
    local ind_h = skin.material_indicator.height + skin.material_indicator.spacing * 0.5

    if data.tab == 1 then
        local convert_height = skin.slot.height + sep_height
        local form_height = (outer_y * 2) + (inner_y * 2) + convert_height + ind_h + sep_height * 2 + inv_height
        minetest.show_formspec(player, "cartographer:table",
            fs.header(width, form_height, rank, data.tab, skin) ..
            gui.container {
                x = outer_x,
                y = outer_y + inner_y,
                fs.materials(inner_x, 0, meta, skin),
                fs.separator(ind_h, inner_width, skin.separator),
                fs.convert(inner_x, ind_h + sep_height, pos, skin),
                fs.separator(ind_h + sep_height + convert_height, inner_width, skin.separator),
                fs.inv(inner_x, ind_h + sep_height * 2 + convert_height, skin),
            })
    elseif data.tab == 2 then
        local radio_height = skin.radio.height
        local radio_margin_y = skin.radio.margin_y
        local craft_height = radio_height + radio_margin_y * 2 + skin.slot.height + sep_height
        local form_height = (outer_y * 2) + (inner_y * 2) + craft_height + ind_h + sep_height * 2 + inv_height
        minetest.show_formspec(player, "cartographer:table",
            fs.header(width, form_height, rank, data.tab, skin) ..
            gui.container {
                x = outer_x,
                y = outer_y + inner_y,
                fs.materials(inner_x, 0, meta, skin),
                fs.separator(ind_h, inner_width, skin.separator),
                fs.craft(inner_x, ind_h + sep_height, pos, rank, meta, skin),
                fs.separator(ind_h + craft_height + sep_height, inner_width, skin.separator),
                fs.inv(inner_x, ind_h + craft_height + sep_height * 2, skin),
            })
    elseif data.tab == 3 then
        local copy_height = skin.slot.height + sep_height
        local form_height = (outer_y * 2) + (inner_y * 2) + copy_height + ind_h + sep_height * 2 + inv_height
        minetest.show_formspec(player, "cartographer:table",
            fs.header(width, form_height, rank, data.tab, skin) ..
            gui.container {
                x = outer_x,
                y = outer_y + inner_y,
                fs.materials(inner_x, 0, meta, skin),
                fs.separator(ind_h, inner_width, skin.separator),
                fs.copy(inner_x, ind_h + sep_height, inv_width, pos, skin),
                fs.separator(ind_h + copy_height + sep_height, inner_width, skin.separator),
                fs.inv(inner_x, ind_h + copy_height + sep_height * 2, skin),
            })
    end
end

-- Called when a player sends input to the server from a formspec
-- This callback handles player input in the table formspec
--
-- player: The player who sent the input
-- name: The formspec name
-- fields: A table containing the input
minetest.register_on_player_receive_fields(function(player, name, fields)
    if name == "cartographer:table" then
        local meta = minetest.get_meta(player_tables[player:get_player_name()].pos)

        local rank = 1
        local node_name = minetest.get_node(player_tables[player:get_player_name()].pos).name
        if node_name == "cartographer:standard_table" then
            rank = 2
        elseif node_name == "cartographer:advanced_table" then
            rank = 3
        end

        if fields["convert"] then
            local inv = meta:get_inventory()
            local stack = inv:get_stack("input", 1)

            local value = materials.get_stack_value(stack)

            if value.paper + value.pigment > 0 then
                meta:set_int("paper", meta:get_int("paper") + value.paper)
                meta:set_int("pigment", meta:get_int("pigment") + value.pigment)
                inv:set_stack("input", 1, ItemStack(nil))
            end
        elseif fields["craft"] then
            local size = meta:get_int("size")
            local detail = meta:get_int("detail")
            local scale = meta:get_int("scale")
            local cost, is_positive = get_craft_material_cost(meta)

            if is_positive and can_afford(cost, meta) then
                meta:set_int("paper",  meta:get_int("paper") - cost.paper)
                meta:set_int("pigment", meta:get_int("pigment") - cost.pigment)

                local inv = meta:get_inventory()
                local stack = inv:get_stack("output", 1)

                if stack:is_empty() then
                    inv:set_stack("output", 1, map_item.create(size, 1 + detail, scale))
                else
                    local smeta = stack:get_meta()
                    smeta:set_int("cartographer:detail", 1 + detail)
                    map_item.resize(smeta, size)
                    map_item.rescale(smeta, scale)

                    local map = maps.get(smeta:get_int("cartographer:map_id"))
                    if map then
                        map.detail = 1 + detail
                    end
                    inv:set_stack("output", 1, stack)
                end

                audio.play_feedback("cartographer_write", player)
            end
        elseif fields["copy"] and rank >= 2 then
            local cost = get_copy_material_cost(meta)
            if can_afford(cost, meta) then
                meta:set_int("paper",  meta:get_int("paper") - cost.paper)
                meta:set_int("pigment", meta:get_int("pigment") - cost.pigment)

                audio.play_feedback("cartographer_write", player)

                local inv = meta:get_inventory()
                inv:set_stack("copy_output", 1, map_item.copy(inv:get_stack("copy_input", 1)))
            end
        elseif fields["1"] then
            meta:set_int("detail", 0)
        elseif fields["2"] then
            meta:set_int("detail", 1)
        elseif fields["3"] and rank > 1 then
            meta:set_int("detail", 2)
        elseif fields["4"] and rank > 2 then
            meta:set_int("detail", 3)
        elseif fields["1x"] and rank > 1 then
            meta:set_int("scale", SCALE_SMALL)
        elseif fields["2x"] and rank > 1 then
            meta:set_int("scale", SCALE_MEDIUM)
        elseif fields["4x"] and rank > 2 then
            meta:set_int("scale", SCALE_LARGE)
        elseif fields["8x"] and rank > 2 then
            meta:set_int("scale", SCALE_HUGE)
        elseif fields["tab1"] then
            player_tables[player:get_player_name()].tab = 1
            audio.play_feedback("cartographer_turn_page", player)
        elseif fields["tab2"] then
            player_tables[player:get_player_name()].tab = 2
            audio.play_feedback("cartographer_turn_page", player)
        elseif fields["tab3"] and rank >= 2 then
            player_tables[player:get_player_name()].tab = 3
            audio.play_feedback("cartographer_turn_page", player)
        end

        if not fields["quit"] then
            table_formspec(player:get_player_name())
        end
    end
end)

-- Called after a table is placed. Sets up the table's inventory and metadata.
--
-- pos: The node's position
local function setup_table_node(pos)
    local meta = minetest.get_meta(pos)
    meta:get_inventory():set_size("input", 1)
    meta:get_inventory():set_size("output", 1)
    meta:get_inventory():set_size("copy_input", 1)
    meta:get_inventory():set_size("copy_output", 1)

    meta:set_int("size", settings.default_size)
    meta:set_int("scale", SCALE_SMALL)
    meta:set_int("detail", 0)
end

-- Called when the player tries to put an item into one of the table's
-- inventories.
--
-- listname: The name of the inventory the item is being placed in.
-- stack: The itemstack
--
-- Returns 0 if the place is invalid otherwise, returns the number of items
-- that can be placed.
local function table_can_put(_, listname, _, stack, _)
    if listname == "copy_output" then
        return 0
    end

    if stack:get_name() ~= "cartographer:map" and (listname == "output" or listname == "copy_input") then
        return 0
    end

    return stack:get_count()
end

-- Called when the player tries to move an item between two of the table's
-- inventories.
--
-- to_list: The name of the inventory the item is being placed in.
-- count: The number of items being moved
--
-- Returns 0 if the move is invalid otherwise, returns the number of items
-- that can be moved.
local function table_can_move(_, _, _, to_list, _, count, _)
    if to_list == "copy_output" then
        return 0
    end

    return count
end

-- Called when a change occurs in a table's inventory
--
-- pos: The node's position
-- listname: The name of the changed inventory list
local function table_on_items_changed(pos, listname, _, _, _)
    for player, data in pairs(player_tables) do
        if vector.equals(pos, data.pos) and (
                        (data.tab == 1 and listname == "input")
                     or (data.tab == 2 and listname == "output")
                     or (data.tab == 3 and listname == "copy_input")) then
            table_formspec(player)
        end
    end
end

-- The table node definitions
minetest.register_node("cartographer:simple_table", {
    description = "Shabby Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.simple_table.node_mesh,
    tiles = { gui_skin.table_skins.simple_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        }

        audio.play_feedback("cartographer_open_map", player)
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
})

minetest.register_node("cartographer:standard_table", {
    description = "Simple Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.standard_table.node_mesh,
    tiles = { gui_skin.table_skins.standard_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        }

        audio.play_feedback("cartographer_open_map", player)
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
})

minetest.register_node("cartographer:advanced_table", {
    description = "Advanced Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.advanced_table.node_mesh,
    tiles = { gui_skin.table_skins.advanced_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        }

        audio.play_feedback("cartographer_open_map", player)
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
})
