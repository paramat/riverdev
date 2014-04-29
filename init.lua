-- riverdev 0.1.0 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- Parameters

local YMIN = -33000
local YMAX = 33000
local YWATER = 1
local TERZERO = 32 -- Terrain zero level
local TERSCAL = 128 -- Terrain scale in nodes
local TSTONE = 0.04 -- Density threshold for stone, depth of stone below surface
local BASAMP = 0.4
local MIDAMP = 0.4
local TERAMP = 0.4
local TRIVER = -0.04
local TSTREAM = -0.02

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384}, -- squashed perlin noise, y spread is half
	seed = 5900033,
	octaves = 5,
	persist = 0.63
}

-- 2D noise for mid terrain

local np_mid = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768}, -- spread is still stated with xyz values
	seed = 85546,
	octaves = 4,
	persist = 0.5
}

-- 2D noise for base terrain

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x=1536, y=1536, z=1536}, -- spread is still stated with xyz values
	seed = -990054,
	octaves = 3,
	persist = 0.4
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
	post_effect_color = {a=64, r=100, g=150, b=200},
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
	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_freshwater = minetest.get_content_id("riverdev:freshwater")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minposxyz = {x=x0, y=y0, z=z0}
	local minposxz = {x=x0, y=z0}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minposxyz)
	
	local nvals_mid = minetest.get_perlin_map(np_mid, chulens):get2dMap_flat(minposxz)
	local nvals_base = minetest.get_perlin_map(np_base, chulens):get2dMap_flat(minposxz)
	
	local nixyz = 1 -- 3D noise index
	local nixz = 1 -- 2D noise index
	local stable = {}
	for z = z0, z1 do
		for x = x0, x1 do
			local si = x - x0 + 1
			local nodename = minetest.get_node({x=x,y=y0-1,z=z}).name
			if nodename == "air"
			or nodename == "default:water_source"
			or nodename == "riverdev:freshwater"
			or nodename == "riverdev:freshwaterflow" then
				stable[si] = 0
			else
				stable[si] = 2
			end
		end
		for y = y0, y1 do
			local vi = area:index(x0, y, z)
			for x = x0, x1 do
				local si = x - x0 + 1
				local n_terrain = nvals_terrain[nixyz]
				local n_mid = nvals_mid[nixz]
				local n_base = nvals_base[nixz]
				
				local grad = (TERZERO - y) / TERSCAL
				local densitybas = n_base * BASAMP + grad
				local densitymid = math.abs(n_mid) * MIDAMP + densitybas
				local density = math.abs(n_terrain) * TERAMP * math.abs(n_mid) + densitymid
				
				if density >= TSTONE then -- stone
					data[vi] = c_stone
					stable[si] = stable[si] + 1
				elseif density >= 0 and density < TSTONE and stable[si] >= 2 then -- fine materials
					data[vi] = c_sand
				elseif y <= YWATER and density < TSTONE then -- sea water
					data[vi] = c_water
					stable[si] = 0
				elseif densitybas >= TRIVER then -- river water
					data[vi] = c_freshwater
					stable[si] = 0
				elseif densitymid >= TSTREAM then -- stream water
					data[vi] = c_freshwater
					stable[si] = 0
				else -- air
					stable[si] = 0
				end
				
				
				nixyz = nixyz + 1 -- increment 3D noise index
				nixz = nixz + 1 -- increment 2D noise index
				vi = vi + 1
			end
			nixz = nixz - 80 -- rewind 2D noise index by 80 nodes for next x row above
		end
		nixz = nixz + 80 -- fast-forward 2D noise index by 80 nodes for next northward xy plane
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[riverdev] "..chugent.." ms")
end)