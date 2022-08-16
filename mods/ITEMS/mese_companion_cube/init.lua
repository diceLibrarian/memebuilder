-- Nodebox and textures from NodeBox Editor Abuse Mod by Napiophelios under WTFPL
-- Simplified by FreeGamers.org, added mesecon compatibility.

-- Register the Mese Companion Cube node into the game.
minetest.register_node("mese_companion_cube:mese_companion_cube", {
	description = "Mese Companion Cube",
    	tiles = {"mese_companion_cube.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {oddly_breakable_by_hand=3, mesecon = 2, cracky = 3},
	sounds = default.node_sound_metal_defaults(),
	mesecons = {receptor = {
	                state = mesecon.state.on
        }},
	node_box = {
		type = "fixed",
		fixed = {
			{0.1875, -0.4375, -0.4375, 0.4375, -0.125, -0.375},
			{-0.4375, -0.4375, -0.4375, -0.1875, -0.125, -0.375},
			{0.125, 0.1875, -0.4375, 0.4375, 0.4375, -0.375},
			{-0.4375, 0.1875, -0.4375, -0.125, 0.4375, -0.375},
			{0.25, -0.375, -0.5, 0.4375, -0.125, -0.4375},
			{0.125, -0.4375, -0.5, 0.375, -0.25, -0.4375},
			{0.1875, -0.375, -0.5, 0.375, -0.1875, -0.4375},
			{0.125, -0.4375, -0.4375, 0.4375, -0.1875, -0.375},
			{-0.4375, -0.4375, -0.4375, -0.125, -0.1875, -0.375},
			{-0.4375, -0.375, -0.5, -0.25, -0.125, -0.4375},
			{-0.375, -0.4375, -0.5, -0.125, -0.25, -0.4375},
			{-0.375, -0.375, -0.5, -0.1875, -0.1875, -0.4375},
			{0.1875, 0.125, -0.4375, 0.4375, 0.4375, -0.375},
			{-0.4375, 0.125, -0.4375, -0.1875, 0.4375, -0.375},
			{0.1875, 0.1875, -0.5, 0.375, 0.375, -0.4375},
			{0.25, 0.125, -0.5, 0.4375, 0.375, -0.4375},
			{0.125, 0.25, -0.5, 0.375, 0.4375, -0.4375},
			{-0.4375, 0.125, -0.5, -0.25, 0.375, -0.4375},
			{-0.375, 0.25, -0.5, -0.125, 0.4375, -0.4375},
			{-0.375, 0.1875, -0.5, -0.1875, 0.375, -0.4375},
			{-0.125, 0.25, -0.4375, 0.125, 0.375, -0.3125},
			{-0.125, -0.375, -0.4375, 0.125, -0.25, -0.3125},
			{0.25, -0.125, -0.4375, 0.375, 0.125, -0.3125},
			{-0.375, -0.125, -0.4375, -0.25, 0.125, -0.3125},
			{-0.125, -0.125, -0.4375, -0.0625, 0.125, -0.375},
			{0.0625, -0.125, -0.4375, 0.125, 0.125, -0.375},
			{-0.0625, -0.125, -0.4375, 0.0625, -0.0625, -0.375},
			{-0.0625, 0.0625, -0.4375, 0.0625, 0.125, -0.375},
			{-0.4375, -0.4375, -0.4375, -0.375, -0.125, -0.1875},
			{-0.4375, -0.4375, 0.1875, -0.375, -0.125, 0.4375},
			{-0.4375, 0.1875, -0.4375, -0.375, 0.4375, -0.125},
			{-0.4375, 0.1875, 0.125, -0.375, 0.4375, 0.4375},
			{-0.5, -0.375, -0.4375, -0.4375, -0.125, -0.25},
			{-0.5, -0.4375, -0.375, -0.4375, -0.25, -0.125},
			{-0.5, -0.375, -0.375, -0.4375, -0.1875, -0.1875},
			{-0.4375, -0.4375, -0.4375, -0.375, -0.1875, -0.125},
			{-0.4375, -0.4375, 0.125, -0.375, -0.1875, 0.4375},
			{-0.5, -0.375, 0.25, -0.4375, -0.125, 0.4375},
			{-0.5, -0.4375, 0.125, -0.4375, -0.25, 0.375},
			{-0.5, -0.375, 0.1875, -0.4375, -0.1875, 0.375},
			{-0.4375, 0.125, -0.4375, -0.375, 0.4375, -0.1875},
			{-0.4375, 0.125, 0.1875, -0.375, 0.4375, 0.4375},
			{-0.5, 0.1875, -0.375, -0.4375, 0.375, -0.1875},
			{-0.5, 0.125, -0.4375, -0.4375, 0.375, -0.25},
			{-0.5, 0.25, -0.375, -0.4375, 0.4375, -0.125},
			{-0.5, 0.125, 0.25, -0.4375, 0.375, 0.4375},
			{-0.5, 0.25, 0.125, -0.4375, 0.4375, 0.375},
			{-0.5, 0.1875, 0.1875, -0.4375, 0.375, 0.375},
			{-0.4375, 0.25, -0.125, -0.3125, 0.375, 0.125},
			{-0.4375, -0.375, -0.125, -0.3125, -0.25, 0.125},
			{-0.4375, -0.125, -0.375, -0.3125, 0.125, -0.25},
			{-0.4375, -0.125, 0.25, -0.3125, 0.125, 0.375},
			{-0.4375, -0.125, 0.0625, -0.375, 0.125, 0.125},
			{-0.4375, -0.125, -0.125, -0.375, 0.125, -0.0625},
			{-0.4375, -0.125, -0.0625, -0.375, -0.0625, 0.0625},
			{-0.4375, 0.0625, -0.0625, -0.375, 0.125, 0.0625},
            		{0.375, -0.4375, 0.1875, 0.4375, -0.125, 0.4375},
			{0.375, -0.4375, -0.4375, 0.4375, -0.125, -0.1875},
			{0.375, 0.1875, 0.125, 0.4375, 0.4375, 0.4375},
			{0.375, 0.1875, -0.4375, 0.4375, 0.4375, -0.125},
			{0.4375, -0.375, 0.25, 0.5, -0.125, 0.4375},
			{0.4375, -0.4375, 0.125, 0.5, -0.25, 0.375},
			{0.4375, -0.375, 0.1875, 0.5, -0.1875, 0.375},
			{0.375, -0.4375, 0.125, 0.4375, -0.1875, 0.4375},
			{0.375, -0.4375, -0.4375, 0.4375, -0.1875, -0.125},
			{0.4375, -0.375, -0.4375, 0.5, -0.125, -0.25},
			{0.4375, -0.4375, -0.375, 0.5, -0.25, -0.125},
			{0.4375, -0.375, -0.375, 0.5, -0.1875, -0.1875},
			{0.375, 0.125, 0.1875, 0.4375, 0.4375, 0.4375},
			{0.375, 0.125, -0.4375, 0.4375, 0.4375, -0.1875},
			{0.4375, 0.1875, 0.1875, 0.5, 0.375, 0.375},
			{0.4375, 0.125, 0.25, 0.5, 0.375, 0.4375},
			{0.4375, 0.25, 0.125, 0.5, 0.4375, 0.375},
			{0.4375, 0.125, -0.4375, 0.5, 0.375, -0.25},
			{0.4375, 0.25, -0.375, 0.5, 0.4375, -0.125},
			{0.4375, 0.1875, -0.375, 0.5, 0.375, -0.1875},
			{0.3125, 0.25, -0.125, 0.4375, 0.375, 0.125},
			{0.3125, -0.375, -0.125, 0.4375, -0.25, 0.125},
			{0.3125, -0.125, 0.25, 0.4375, 0.125, 0.375},
			{0.3125, -0.125, -0.375, 0.4375, 0.125, -0.25},
			{0.375, -0.125, -0.125, 0.4375, 0.125, -0.0625},
			{0.375, -0.125, 0.0625, 0.4375, 0.125, 0.125},
			{0.375, -0.125, -0.0625, 0.4375, -0.0625, 0.0625},
			{0.375, 0.0625, -0.0625, 0.4375, 0.125, 0.0625},
			{0.125, 0.375, 0.1875, 0.4375, 0.4375, 0.4375},
			{0.125, 0.375, -0.4375, 0.4375, 0.4375, -0.1875},
			{-0.4375, 0.375, 0.125, -0.1875, 0.4375, 0.4375},
			{-0.4375, 0.375, -0.4375, -0.1875, 0.4375, -0.125},
			{0.125, 0.4375, 0.25, 0.375, 0.5, 0.4375},
			{0.25, 0.4375, 0.125, 0.4375, 0.5, 0.375},
			{0.1875, 0.4375, 0.1875, 0.375, 0.5, 0.375},
			{0.1875, 0.375, 0.125, 0.4375, 0.4375, 0.4375},
			{0.1875, 0.375, -0.4375, 0.4375, 0.4375, -0.125},
			{0.125, 0.4375, -0.4375, 0.375, 0.5, -0.25},
			{0.25, 0.4375, -0.375, 0.4375, 0.5, -0.125},
			{0.1875, 0.4375, -0.375, 0.375, 0.5, -0.1875},
			{-0.4375, 0.375, 0.1875, -0.125, 0.4375, 0.4375},
			{-0.4375, 0.375, -0.4375, -0.125, 0.4375, -0.1875},
			{-0.375, 0.4375, 0.1875, -0.1875, 0.5, 0.375},
			{-0.375, 0.4375, 0.25, -0.125, 0.5, 0.4375},
			{-0.4375, 0.4375, 0.125, -0.25, 0.5, 0.375},
			{-0.375, 0.4375, -0.4375, -0.125, 0.5, -0.25},
			{-0.4375, 0.4375, -0.375, -0.25, 0.5, -0.125},
			{-0.375, 0.4375, -0.375, -0.1875, 0.5, -0.1875},
			{-0.375, 0.3125, -0.125, -0.25, 0.4375, 0.125},
			{0.25, 0.3125, -0.125, 0.375, 0.4375, 0.125},
			{-0.125, 0.3125, 0.25, 0.125, 0.4375, 0.375},
			{-0.125, 0.3125, -0.375, 0.125, 0.4375, -0.25},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, -0.0625},
			{-0.125, 0.375, 0.0625, 0.125, 0.4375, 0.125},
			{0.0625, 0.375, -0.0625, 0.125, 0.4375, 0.0625},
			{-0.125, 0.375, -0.0625, -0.0625, 0.4375, 0.0625},
			{-0.375, -0.375, -0.375, 0.375, 0.375, 0.375},
			{-0.4375, -0.4375, 0.375, -0.1875, -0.125, 0.4375},
			{0.1875, -0.4375, 0.375, 0.4375, -0.125, 0.4375},
			{-0.4375, 0.1875, 0.375, -0.125, 0.4375, 0.4375},
			{0.125, 0.1875, 0.375, 0.4375, 0.4375, 0.4375},
			{-0.4375, -0.375, 0.4375, -0.25, -0.125, 0.5},
			{-0.375, -0.4375, 0.4375, -0.125, -0.25, 0.5},
			{-0.375, -0.375, 0.4375, -0.1875, -0.1875, 0.5},
			{-0.4375, -0.4375, 0.375, -0.125, -0.1875, 0.4375},
			{0.125, -0.4375, 0.375, 0.4375, -0.1875, 0.4375},
			{0.25, -0.375, 0.4375, 0.4375, -0.125, 0.5},
			{0.125, -0.4375, 0.4375, 0.375, -0.25, 0.5},
			{0.1875, -0.375, 0.4375, 0.375, -0.1875, 0.5},
			{-0.4375, 0.125, 0.375, -0.1875, 0.4375, 0.4375},
			{0.1875, 0.125, 0.375, 0.4375, 0.4375, 0.4375},
			{-0.375, 0.1875, 0.4375, -0.1875, 0.375, 0.5},
			{-0.4375, 0.125, 0.4375, -0.25, 0.375, 0.5},
			{-0.375, 0.25, 0.4375, -0.125, 0.4375, 0.5},
			{0.25, 0.125, 0.4375, 0.4375, 0.375, 0.5},
			{0.125, 0.25, 0.4375, 0.375, 0.4375, 0.5},
			{0.1875, 0.1875, 0.4375, 0.375, 0.375, 0.5},
			{-0.125, 0.25, 0.3125, 0.125, 0.375, 0.4375},
			{-0.125, -0.375, 0.3125, 0.125, -0.25, 0.4375},
			{-0.375, -0.125, 0.3125, -0.25, 0.125, 0.4375},
			{0.25, -0.125, 0.3125, 0.375, 0.125, 0.4375},
			{0.0625, -0.125, 0.375, 0.125, 0.125, 0.4375},
			{-0.125, -0.125, 0.375, -0.0625, 0.125, 0.4375},
			{-0.0625, -0.125, 0.375, 0.0625, -0.0625, 0.4375},
			{-0.0625, 0.0625, 0.375, 0.0625, 0.125, 0.4375},
			{-0.4375, -0.4375, -0.4375, -0.1875, -0.375, -0.125},
			{0.1875, -0.4375, -0.4375, 0.4375, -0.375, -0.125},
			{-0.4375, -0.4375, 0.1875, -0.125, -0.375, 0.4375},
			{0.125, -0.4375, 0.1875, 0.4375, -0.375, 0.4375},
			{-0.4375, -0.5, -0.375, -0.25, -0.4375, -0.125},
			{-0.375, -0.5, -0.4375, -0.125, -0.4375, -0.25},
			{-0.375, -0.5, -0.375, -0.1875, -0.4375, -0.1875},
			{-0.4375, -0.4375, -0.4375, -0.125, -0.375, -0.1875},
			{0.125, -0.4375, -0.4375, 0.4375, -0.375, -0.1875},
			{0.25, -0.5, -0.375, 0.4375, -0.4375, -0.125},
			{0.125, -0.5, -0.4375, 0.375, -0.4375, -0.25},
			{0.1875, -0.5, -0.375, 0.375, -0.4375, -0.1875},
			{-0.4375, -0.4375, 0.125, -0.1875, -0.375, 0.4375},
			{0.1875, -0.4375, 0.125, 0.4375, -0.375, 0.4375},
			{-0.375, -0.5, 0.1875, -0.1875, -0.4375, 0.375},
			{-0.4375, -0.5, 0.125, -0.25, -0.4375, 0.375},
			{-0.375, -0.5, 0.25, -0.125, -0.4375, 0.4375},
			{0.25, -0.5, 0.125, 0.4375, -0.4375, 0.375},
			{0.125, -0.5, 0.25, 0.375, -0.4375, 0.4375},
			{0.1875, -0.5, 0.1875, 0.375, -0.4375, 0.375},
			{-0.125, -0.4375, 0.25, 0.125, -0.3125, 0.375},
			{-0.125, -0.4375, -0.375, 0.125, -0.3125, -0.25},
			{-0.375, -0.4375, -0.125, -0.25, -0.3125, 0.125},
			{0.25, -0.4375, -0.125, 0.375, -0.3125, 0.125},
			{0.0625, -0.4375, -0.125, 0.125, -0.375, 0.125},
			{-0.125, -0.4375, -0.125, -0.0625, -0.375, 0.125},
			{-0.0625, -0.4375, -0.125, 0.0625, -0.375, -0.0625},
			{-0.0625, -0.4375, 0.0625, 0.0625, -0.375, 0.125},
		},
	},
    selection_box = {
        type = "fixed",
        fixed = {
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375},
        },
    },
})
-- Register the recipe for the Mese Companion Cube.
minetest.register_craft({
        output = 'mese_companion_cube:mese_companion_cube',
        recipe = {
                {'default:steel_ingot', 'default:mese_crystal', 'default:steel_ingot'},
                {'default:mese_crystal', 'default:mese_crystal', 'default:mese_crystal'},
                {'default:steel_ingot', 'default:mese_crystal', 'default:steel_ingot'},
        }
})