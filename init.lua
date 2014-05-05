-- riverdev 0.3.0 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- TODO
-- add XL scale noise, amplitude 0.1, YTER = -128 as a mirror of cloud level

-- Parameters

local YMIN = -33000
local YMAX = 33000
local YWATER = 1
local YSAND = 3 -- Top of beach
local YTER = -128 -- Terrain zero level, average seabed level

local TERSCA = 512 -- Terrain vertical scale in nodes
local BASAMP = 0.3 -- Base amplitude. Ridge network structure
local MIDAMP = 0.1 -- Mid amplitude. River valley structure
local TERAMP = 0.4 -- Primary terrain amplitude. Stream valley structure
local ATANAMP = 1 -- Arctan density gradient amplitude. Controls size/amount of floatlands above ridges

local TSTONE = 0.02
local TRIVER = -0.02
local TRSAND = -0.025
local TSTREAM = -0.004
local TSSAND = -0.005

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=192, z=384},
	seed = 5900033,
	octaves = 5,
	persist = 0.67
}

-- 2D noise for mid terrain

local np_mid = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768},
	seed = 85546,
	octaves = 5,
	persist = 0.5
}

-- 2D noise for base terrain

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x=3072, y=3072, z=3072},
	seed = -990054,
	octaves = 3,
	persist = 0.33
}

-- Stuff

riverdev = {}

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
end)

-- Nodes

minetest.register_node("riverdev:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("riverdev:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("riverdev:grass", {
	description = "Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	drop = "riverdev:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
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
	liquid_range = 0,
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
	liquid_range = 0,
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
	liquid_range = 0,
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
	liquid_range = 0,
	post_effect_color = {a=64, r=100, g=115, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < YMIN or maxp.y > YMAX then
		return
	end

	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[riverdev] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_water = minetest.get_content_id("default:water_source")
	local c_sand = minetest.get_content_id("default:sand")
	local c_dirt = minetest.get_content_id("riverdev:dirt")
	local c_grass = minetest.get_content_id("riverdev:grass")
	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_freshwater = minetest.get_content_id("riverdev:freshwater")
	local c_mixwater = minetest.get_content_id("riverdev:mixwater")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen+2, z=sidelen}
	local minposxyz = {x=x0, y=y0-1, z=z0}
	local minposxz = {x=x0, y=z0}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minposxyz)
	local nvals_mid = minetest.get_perlin_map(np_mid, chulens):get2dMap_flat(minposxz)
	local nvals_base = minetest.get_perlin_map(np_base, chulens):get2dMap_flat(minposxz)
	
	local ungen = false
	if minetest.get_node({x=x0, y=y0-1, z=z0}).name == "ignore" then
		ungen = true
	end
	
	local nixyz = 1
	local nixz = 1
	local stable = {}
	local under = {}
	for z = z0, z1 do
	for y = y0 - 1, y1 + 1 do
		local vi = area:index(x0, y, z)
		local viu = area:index(x0, y-1, z)
		for x = x0, x1 do
			local si = x - x0 + 1
			local n_absterrain = math.abs(nvals_terrain[nixyz])
			local n_absmid = math.abs(nvals_mid[nixz])
			local n_absbase = math.abs(nvals_base[nixz])
			
			local n_invbase = (1 - n_absbase)
			local grad = math.atan((YTER - y) / TERSCA) * ATANAMP
			local densitybase = n_invbase * BASAMP + grad
			local densitymid = n_absmid * MIDAMP + densitybase
			local terexp = 0.2 + n_invbase * 0.8
			local teramp = n_invbase * TERAMP
			local density = n_absterrain ^ terexp * teramp * n_absmid + densitymid
			
			local tstone = TSTONE * (1 + grad)
			local triver = TRIVER * n_absbase
			local trsand = TRSAND * n_absbase
			local tstream = TSTREAM * (1 - n_absmid)
			local tssand = TSSAND * (1 - n_absmid)
				
			if y == y0 - 1 then -- overgeneration, initialise tables
				under[si] = 0
				if ungen then
					if density >= 0 then
						stable[si] = 2
					else
						stable[si] = 0
					end
				else
					local nodename = minetest.get_node({x=x,y=y0-1,z=z}).name
					if nodename == "air"
					or nodename == "default:water_source"
					or nodename == "riverdev:freshwater"
					or nodename == "riverdev:freshwaterflow"
					or nodename == "riverdev:mixwater"
					or nodename == "riverdev:mixwaterflow" then
						stable[si] = 0
					else
						stable[si] = 2
					end
				end
			elseif y >= y0 and y <= y1 then -- chunk generation
				if density >= tstone then -- stone
					data[vi] = c_stone
					stable[si] = stable[si] + 1
					under[si] = 0
				elseif density >= 0 and density < tstone and stable[si] >= 2 then -- fine materials
					if y <= YSAND + math.random() * 2
					or densitybase >= trsand + math.random() * 0.002
					or densitymid >= tssand + math.random() * 0.002 then
						data[vi] = c_sand
						under[si] = 0
					else
						data[vi] = c_dirt
						under[si] = 1
					end
				elseif y <= YWATER and density < tstone then -- sea water
					data[vi] = c_water
					stable[si] = 0
					under[si] = 0
				elseif densitybase >= triver then -- river water
					if y == YWATER + 1 then
						data[vi] = c_mixwater
					else
						data[vi] = c_freshwater
					end
					stable[si] = 0
					under[si] = 0
				elseif densitymid >= tstream then -- stream water
					if y == YWATER + 1 then
						data[vi] = c_mixwater
					else
						data[vi] = c_freshwater
					end
					stable[si] = 0
					under[si] = 0
				elseif density < 0 and under[si] ~= 0 then -- air above surface
					if under[si] == 1 then
						data[viu] = c_grass
					end
					stable[si] = 0
					under[si] = 0
				else -- air
					stable[si] = 0
					under[si] = 0
				end
			elseif y == y1 + 1 then -- overgeneration, detect surface, add surface nodes
				if density < 0 and under[si] ~= 0 then
					if under[si] == 1 then
						data[viu] = c_grass
					end
				end
			end
				
			nixyz = nixyz + 1
			nixz = nixz + 1
			vi = vi + 1
			viu = viu + 1
		end
		nixz = nixz - 80
	end
	nixz = nixz + 80
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[riverdev] "..chugent.." ms")
end)