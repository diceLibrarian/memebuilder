-- Table used for skinning cartographer's look and feel
return {
    -- The textures to use in maps for the sides of tiles
    cliff_textures = {
        "cartographer_simple_cliff",
        "cartographer_cliff",
    };

    -- The textures to use in maps for undiscovered tiles
    unknown_biome_textures = {
        "cartographer_unknown_biome",
    };

    -- The textures to use in maps for tiles with no associated biome
    default_biome_textures = {
        "cartographer_default_biome",
    };

    -- The animated texture data to use for the player icon
    player_icons = {
        {
            frame_count = 2,
            frame_duration = 500,
            texture = "cartographer_simple_player_icon",
        },
        {
            frame_count = 2,
            frame_duration = 500,
            texture = "cartographer_player_icon",
        },
    },

    -- The skinning data for the cartographer's tables
    table_skins = {
        simple_table = {
            node_mesh = "cartographer_simple_table.obj",
            node_texture = "cartographer_simple_table.png",

            background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_simple_table_bg",
                radius = 16,
            },
            inner_background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_simple_table_bg_2",
                radius = 4,
            },
            button = {
                font_color = "#694a3a",
                disabled_font_color = "#606060",
                texture = "cartographer_simple_table_button",
                selected_texture = "cartographer_simple_table_button_pressed",
                hovered_texture = "cartographer_simple_table_button_hovered",
                pressed_texture = "cartographer_simple_table_button_pressed",
                radius = 8,
                width = 2.5,
                height = 0.75,
            },
            slot = {
                texture = "cartographer_simple_table_slot",
                radius = 8,
                width = 1,
                height = 1,
                row_margin = 0.25,
                column_margin = 0.25,
            },
            separator = {
                texture = "cartographer_simple_table_separator",
                radius = "9,1",
            },
            material_indicator = {
                width = 1.25,
                height = 0.5,
                spacing = 0.25
            },
            label = {
                margin_x = 0.125,
                margin_y = 0,
                font_color = "#694a3a",
                texture = "cartographer_simple_table_slot",
                radius = 8,
            },
            radio = {
                width = 0.75,
                height = 0.75,
                margin_x = 0.25,
                margin_y = 0.25,
            },
            tab = {
                width = 1.75,
                height = 0.75,
                font_color = "#694a3a",
                texture = "cartographer_simple_table_tab",
                selected_texture = "cartographer_simple_table_tab_selected",
                hovered_texture = "cartographer_simple_table_tab_hovered",
                pressed_texture = "cartographer_simple_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
        standard_table = {
            node_mesh = "cartographer_standard_table.obj",
            node_texture = "cartographer_standard_table.png",
            background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_standard_table_bg",
                radius = 16,
            },
            inner_background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_standard_table_bg_2",
                radius = 4,
            },
            button = {
                font_color = "#694a3a",
                disabled_font_color = "#606060",
                texture = "cartographer_simple_table_button",
                selected_texture = "cartographer_simple_table_button_pressed",
                hovered_texture = "cartographer_simple_table_button_hovered",
                pressed_texture = "cartographer_simple_table_button_pressed",
                radius = 8,
                width = 2.5,
                height = 0.75,
            },
            slot = {
                texture = "cartographer_standard_table_slot",
                radius = 8,
                width = 1,
                height = 1,
                row_margin = 0.25,
                column_margin = 0.25,
            },
            separator = {
                texture = "cartographer_standard_table_separator",
                radius = "9,1",
            },
            material_indicator = {
                width = 1.25,
                height = 0.5,
                spacing = 0.25
            },
            label = {
                margin_x = 0.125,
                margin_y = 0,
                font_color = "#694a3a",
                texture = "cartographer_standard_table_slot",
                radius = 8,
            },
            radio = {
                width = 0.75,
                height = 0.75,
                margin_x = 0.25,
                margin_y = 0.25,
            },
            tab = {
                width = 1.75,
                height = 0.75,
                font_color = "#694a3a",
                texture = "cartographer_standard_table_tab",
                selected_texture = "cartographer_standard_table_tab_selected",
                hovered_texture = "cartographer_standard_table_tab_hovered",
                pressed_texture = "cartographer_standard_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
        advanced_table = {
            node_mesh = "cartographer_advanced_table.obj",
            node_texture = "cartographer_advanced_table.png",
            background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_advanced_table_bg",
                radius = 16,
            },
            inner_background = {
                margin_x = 0.125,
                margin_y = 0.125,
                texture = "cartographer_advanced_table_bg_2",
                radius = 2,
            },
            button = {
                font_color = "#1f2533",
                disabled_font_color = "#606060",
                texture = "cartographer_advanced_table_button",
                selected_texture = "cartographer_advanced_table_button_pressed",
                hovered_texture = "cartographer_advanced_table_button_hovered",
                pressed_texture = "cartographer_advanced_table_button_pressed",
                radius = 8,
                width = 2.5,
                height = 0.75,
            },
            slot = {
                texture = "cartographer_advanced_table_slot",
                radius = 8,
                width = 1,
                height = 1,
                row_margin = 0.25,
                column_margin = 0.25,
            },
            separator = {
                texture = "cartographer_advanced_table_separator",
                radius = "9,1",
            },
            material_indicator = {
                width = 1.25,
                height = 0.5,
                spacing = 0.25
            },
            label = {
                margin_x = 0.125,
                margin_y = 0,
                font_color = "#1f2533",
                texture = "cartographer_advanced_table_slot",
                radius = 8,
            },
            radio = {
                width = 0.75,
                height = 0.75,
                margin_x = 0.25,
                margin_y = 0.25,
            },
            tab = {
                width = 1.75,
                height = 0.75,
                font_color = "#1f2533",
                texture = "cartographer_advanced_table_tab",
                selected_texture = "cartographer_advanced_table_tab_selected",
                hovered_texture = "cartographer_advanced_table_tab_hovered",
                pressed_texture = "cartographer_advanced_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
    },

    -- The skinning data for the map UI's background
    map_bg = {
        texture = "cartographer_map_bg",
        radius = 3,
    },

    -- The skinning data for the marker editor's background
    marker_bg = {
        texture = "cartographer_markers_bg",
        radius = 6,
    },

    -- The skinning data for the marker editor's buttons
    marker_button = {
        font_color = "#694a3a",
        texture = "cartographer_simple_table_button",
        selected_texture = "cartographer_simple_table_button_pressed",
        hovered_texture = "cartographer_simple_table_button_hovered",
        pressed_texture = "cartographer_simple_table_button_pressed",
        radius = 8,
    },

    -- Standard size / spacing units for the marker UI
    marker_metrics = {
        w = 0.75,
        h = 0.75,
        x_margin = 0.5 / 4,
        y_margin = 0.5 / 4,
        rows = 4,
        columns = 5,
    },

    -- The texture of the height toggle button when active
    height_button_texture = "cartographer_height_button",

    -- The texture of the height toggle button when inactive
    flat_button_texture = "cartographer_flat_button",

    player_inv_columns = 8,
    player_inv_rows = 4,
}
