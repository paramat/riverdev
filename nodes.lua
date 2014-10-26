minetest.register_node("riverdev:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("riverdev:redstone", {
	description = "Red Stone",
	tiles = {"default_desert_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:desert_cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("riverdev:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:grass", {
	description = "Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_node("riverdev:path", {
	description = "Dirt Path",
	tiles = {"riverdev_path.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:appleleaf", {
	description = "Appletree Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"riverdev:appling"},rarity = 20},
			{items = {"riverdev:appleleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:appling", {
	description = "Appletree Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:pinetree", {
	description = "Pine tree",
	tiles = {"riverdev_pinetreetop.png", "riverdev_pinetreetop.png", "riverdev_pinetree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("riverdev:needles", {
	description = "Pine needles",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"riverdev_needles.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3},
	drop = {
		max_items = 1,
		items = {
			{items = {"riverdev:pineling"}, rarity = 20},
			{items = {"riverdev:needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:pineling", {
	description = "Pine sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"riverdev_pineling.png"},
	inventory_image = "riverdev_pineling.png",
	wield_image = "riverdev_pineling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:pinewood", {
	description = "Pine wood planks",
	tiles = {"riverdev_pinewood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("riverdev:jungleleaf", {
	description = "Jungletree leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_jungleleaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"riverdev:jungling"},rarity = 20},
			{items = {"riverdev:jungleleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:vine", {
	description = "Jungletree vine",
	drawtype = "airlike",
	paramtype = "light",
	walkable = false,
	climbable = true,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("riverdev:jungling", {
	description = "Jungletree sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_junglesapling.png"},
	inventory_image = "default_junglesapling.png",
	wield_image = "default_junglesapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})


minetest.register_node("riverdev:acaciatree", {
	description = "Acacia tree",
	tiles = {"riverdev_acaciatreetop.png", "riverdev_acaciatreetop.png", "riverdev_acaciatree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("riverdev:acacialeaf", {
	description = "Acacia leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"riverdev_acacialeaf.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"riverdev:acacialing"},rarity = 20},
			{items = {"riverdev:acacialeaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:acacialing", {
	description = "Acacia tree sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"riverdev_acacialing.png"},
	inventory_image = "riverdev_acacialing.png",
	wield_image = "riverdev_acacialing.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("riverdev:acaciawood", {
	description = "Acacia wood planks",
	tiles = {"riverdev_acaciawood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("riverdev:goldengrass", {
	description = "Golden grass",
	drawtype = "plantlike",
	tiles = {"riverdev_goldengrass.png"},
	inventory_image = "riverdev_goldengrass.png",
	wield_image = "riverdev_goldengrass.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	groups = {snappy=3,flammable=3,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("riverdev:drygrass", {
	description = "Dry grass",
	tiles = {"riverdev_drygrass.png"},
	is_ground_content = false,
	groups = {crumbly=1,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("riverdev:icydirt", {
	description = "Icy dirt",
	tiles = {"riverdev_icydirt.png"},
	is_ground_content = false,
	groups = {crumbly=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.15},
		dug = {name="default_snow_footstep", gain=0.45},
	}),
})

minetest.register_node("riverdev:permafrost", {
	description = "Permafrost",
	tiles = {"riverdev_permafrost.png"},
	is_ground_content = false,
	groups = {crumbly=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:cactus", {
	description = "Cactus",
	tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_side.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {snappy=1,choppy=3,flammable=2},
	drop = "default:cactus",
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("riverdev:freshwater", {
	description = "Fresh Water Source",
	inventory_image = minetest.inventorycube("riverdev_freshwater.png"),
	drawtype = "liquid",
	tiles = {
		{
			name="riverdev_freshwateranim.png",
			animation={type="vertical_frames",
			aspect_w=16, aspect_h=16, length=2.0}
		}
	},
	special_tiles = {
		{
			name="riverdev_freshwateranim.png",
			animation={type="vertical_frames",
			aspect_w=16, aspect_h=16, length=2.0},
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
	post_effect_color = {a=64, r=100, g=150, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("riverdev:freshwaterflow", {
	description = "Fresh Flowing Water",
	inventory_image = minetest.inventorycube("riverdev_freshwater.png"),
	drawtype = "flowingliquid",
	tiles = {"riverdev_freshwater.png"},
	special_tiles = {
		{
			image="riverdev_freshwaterflowanim.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
		{
			image="riverdev_freshwaterflowanim.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
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
	post_effect_color = {a=64, r=100, g=130, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("riverdev:mixwater", {
	description = "Mixed Water Source",
	inventory_image = minetest.inventorycube("riverdev_mixwater.png"),
	drawtype = "liquid",
	tiles = {
		{
			name="riverdev_mixwateranim.png",
			animation={type="vertical_frames",
			aspect_w=16, aspect_h=16, length=2.0}
		}
	},
	special_tiles = {
		{
			name="riverdev_mixwateranim.png",
			animation={type="vertical_frames",
			aspect_w=16, aspect_h=16, length=2.0},
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
	post_effect_color = {a=64, r=100, g=115, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("riverdev:mixwaterflow", {
	description = "Flowing Mixed Water",
	inventory_image = minetest.inventorycube("riverdev_mixwater.png"),
	drawtype = "flowingliquid",
	tiles = {"riverdev_mixwater.png"},
	special_tiles = {
		{
			image="riverdev_mixwaterflowanim.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
		{
			image="riverdev_mixwaterflowanim.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
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
	post_effect_color = {a=64, r=100, g=115, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

-- Crafting

minetest.register_craft({
	output = "riverdev:pinewood 4",
	recipe = {
		{"riverdev:pinetree"},
	}
})

minetest.register_craft({
	output = "riverdev:acaciawood 4",
	recipe = {
		{"riverdev:acaciatree"},
	}
})

-- Register stairs and slabs

stairs.register_stair_and_slab(
	"pinewood",
	"riverdev:pinewood",
	{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	{"riverdev_pinewood.png"},
	"Pinewood stair",
	"Pinewood slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"acaciawood",
	"riverdev:acaciawood",
	{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	{"riverdev_acaciawood.png"},
	"Acaciawood stair",
	"Acaciawood slab",
	default.node_sound_wood_defaults()
)

