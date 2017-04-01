minetest.register_node("riverdev:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("riverdev:redstone", {
	description = "Red Stone",
	tiles = {"default_desert_stone.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	drop = "default:desert_cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("riverdev:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:grass", {
	description = "Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})

minetest.register_node("riverdev:path", {
	description = "Dirt Path",
	tiles = {"riverdev_path.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:drygrass", {
	description = "Dry grass",
	tiles = {"riverdev_drygrass.png"},
	is_ground_content = false,
	groups = {crumbly = 1, soil = 1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.4},
	}),
})

minetest.register_node("riverdev:icydirt", {
	description = "Icy dirt",
	tiles = {"riverdev_icydirt.png"},
	is_ground_content = false,
	groups = {crumbly = 1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_snow_footstep", gain = 0.15},
		dug = {name = "default_snow_footstep", gain = 0.45},
	}),
})

minetest.register_node("riverdev:permafrost", {
	description = "Permafrost",
	tiles = {"riverdev_permafrost.png"},
	is_ground_content = false,
	groups = {crumbly = 1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:freshwater", {
	description = "Fresh Water Source",
	inventory_image = minetest.inventorycube("riverdev_freshwater.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "riverdev_freshwateranim.png",
			animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 2.0}
		}
	},
	special_tiles = {
		{
			name = "riverdev_freshwateranim.png",
			animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 2.0},
			backface_culling = false,
		}
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "riverdev:freshwaterflow",
	liquid_alternative_source = "riverdev:freshwater",
	liquid_viscosity = WATER_VISC,
	liquid_renewable = false,
	liquid_range = 2,
	post_effect_color = {a = 64, r = 100, g = 150, b = 200},
	groups = {water = 3, liquid = 3, puts_out_fire = 1},
})

minetest.register_node("riverdev:freshwaterflow", {
	description = "Fresh Flowing Water",
	inventory_image = minetest.inventorycube("riverdev_freshwater.png"),
	drawtype = "flowingliquid",
	tiles = {"riverdev_freshwater.png"},
	special_tiles = {
		{
			image = "riverdev_freshwaterflowanim.png",
			backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8}
		},
		{
			image = "riverdev_freshwaterflowanim.png",
			backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8}
		},
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "riverdev:freshwaterflow",
	liquid_alternative_source = "riverdev:freshwater",
	liquid_viscosity = WATER_VISC,
	liquid_renewable = false,
	liquid_range = 2,
	post_effect_color = {a = 64, r = 100, g = 130, b = 200},
	groups = {water = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
})

minetest.register_node("riverdev:mixwater", {
	description = "Mixed Water Source",
	inventory_image = minetest.inventorycube("riverdev_mixwater.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "riverdev_mixwateranim.png",
			animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 2.0}
		}
	},
	special_tiles = {
		{
			name = "riverdev_mixwateranim.png",
			animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 2.0},
			backface_culling = false,
		}
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "riverdev:mixwaterflow",
	liquid_alternative_source = "riverdev:mixwater",
	liquid_viscosity = WATER_VISC,
	liquid_renewable = false,
	liquid_range = 2,
	post_effect_color = {a = 64, r = 100, g = 115, b = 200},
	groups = {water = 3, liquid = 3, puts_out_fire = 1},
})

minetest.register_node("riverdev:mixwaterflow", {
	description = "Flowing Mixed Water",
	inventory_image = minetest.inventorycube("riverdev_mixwater.png"),
	drawtype = "flowingliquid",
	tiles = {"riverdev_mixwater.png"},
	special_tiles = {
		{
			image = "riverdev_mixwaterflowanim.png",
			backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8}
		},
		{
			image = "riverdev_mixwaterflowanim.png",
			backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8}
		},
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "riverdev:mixwaterflow",
	liquid_alternative_source = "riverdev:mixwater",
	liquid_viscosity = WATER_VISC,
	liquid_renewable = false,
	liquid_range = 2,
	post_effect_color = {a = 64, r = 100, g = 115, b = 200},
	groups = {water = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
})
