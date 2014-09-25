-- riverdev 0.5.1 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- boulders
-- tune noise parameters, big biomes
-- TODO
-- magma tunnels
-- packed snow above paths

-- Parameters

local YMIN = -33000
local YMAX = 1024
local YWATER = 1
local YSAND = 4 -- Top of beach y
local YTER = -64 -- Deepest seabed y
local YPINE = 32 -- Pines above this y

local TERSCA = 512 -- Terrain vertical scale in nodes
local BASAMP = 0.3 -- Base amplitude relative to 3D noise amplitude. Ridge network structure
local MIDAMP = 0.05 -- Mid amplitude relative to 3D noise amplitude. River valley structure

local TSTONE = 0.02
local TRIVER = -0.018
local TRSAND = -0.02
local TPFLO = 0.03 -- Width of flora clearing around paths
local TTUN = 0.02 -- Tunnel width

local ORECHA = 1 / 5 ^ 3 -- Ore chance per stone node. 1 / n ^ 3 where n = average distance between ores
local BOLCHA = 1 / 61 ^ 2 -- Boulder maximum chance per grass node. 1 / n ^ 2 where n = average minimum distance between flora
local APPCHA = 1 / 5 ^ 2 -- Appletree maximum chance per grass node
local PINCHA = 1 / 6 ^ 2 -- Pinetree maximum chance per grass node
local JUNCHA = 1 / 4 ^ 2 -- Jungletree maximum chance per grass node
local GRACHA = 1 / 5 ^ 2 -- Grasses maximum chance per grass node
local FLOCHA = 1 / 47 ^ 2 -- Flower chance per grass node
local LOTET = -0.4
local HITET = 0.6

-- 3D noise for highland terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 5900033,
	octaves = 4,
	persist = 0.67
}

-- 2D noise for mid terrain / river

local np_mid = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768},
	seed = 85546,
	octaves = 5,
	persist = 0.4
}

-- 2D noise for base terrain

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x=3072, y=3072, z=3072},
	seed = -990054,
	octaves = 2,
	persist = 0.4
}

-- 2D noises for patha / top terrain

local np_patha = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768},
	seed = 7000023,
	octaves = 4,
	persist = 0.4
}

-- 2D noises for pathb / top terrain

local np_pathb = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768},
	seed = 23,
	octaves = 4,
	persist = 0.4
}

-- 2D noise for temperature

local np_temp = {
	offset = 0,
	scale = 1,
	spread = {x=3072, y=3072, z=3072},
	seed = 18882,
	octaves = 3,
	persist = 0.4
}

-- 2D noise for trees

local np_tree = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384},
	seed = 133338,
	octaves = 3,
	persist = 0.6
}

-- 2D noise for grasses

local np_grass = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384},
	seed = 133,
	octaves = 2,
	persist = 0.6
}

-- 3D noises for tunnels

local np_weba = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 5900033,
	octaves = 3,
	persist = 0.5
}

local np_webb = {
	offset = 0,
	scale = 1,
	spread = {x=191, y=191, z=191},
	seed = 33,
	octaves = 3,
	persist = 0.5
}

-- Stuff

riverdev = {}

dofile(minetest.get_modpath("riverdev").."/functions.lua")
dofile(minetest.get_modpath("riverdev").."/nodes.lua")

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < YMIN or maxp.y > YMAX then
		return
	end

	local t0 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[riverdev] generate chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_water = minetest.get_content_id("default:water_source")
	local c_sand = minetest.get_content_id("default:sand")
	local c_wood = minetest.get_content_id("default:wood")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_grass5 = minetest.get_content_id("default:grass_5")
	local c_jungrass = minetest.get_content_id("default:junglegrass")
	local c_stodiam = minetest.get_content_id("default:stone_with_diamond")
	local c_stomese = minetest.get_content_id("default:stone_with_mese")
	local c_stogold = minetest.get_content_id("default:stone_with_gold")
	local c_stocopp = minetest.get_content_id("default:stone_with_copper")
	local c_stoiron = minetest.get_content_id("default:stone_with_iron")
	local c_stocoal = minetest.get_content_id("default:stone_with_coal")

	local c_dirt = minetest.get_content_id("riverdev:dirt")
	local c_grass = minetest.get_content_id("riverdev:grass")
	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_path = minetest.get_content_id("riverdev:path")
	local c_freshwater = minetest.get_content_id("riverdev:freshwater")
	local c_mixwater = minetest.get_content_id("riverdev:mixwater")
	local c_freshwaterflow = minetest.get_content_id("riverdev:freshwaterflow")
	local c_mixwaterflow = minetest.get_content_id("riverdev:mixwaterflow")
	
	local sidelen = x1 - x0 + 1 -- mapgen chunk side length
	local overlen = sidelen + 1 -- perlinmap overgeneration horizontal side length
	local emerlen = sidelen + 32 -- voxelmanip emerged volume edge length
	--local emerarea = emerlen ^ 2 -- voxelmanip emerged volume face area
	local chulensxyz = {x=overlen, y=sidelen+2, z=overlen}
	local minposxyz = {x=x0-1, y=y0-1, z=z0-1}
	local chulensxz = {x=overlen, y=overlen, z=sidelen} -- different because here x=x, y=z
	local minposxz = {x=x0-1, y=z0-1}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_weba = minetest.get_perlin_map(np_weba, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_webb = minetest.get_perlin_map(np_webb, chulensxyz):get3dMap_flat(minposxyz)

	local nvals_mid = minetest.get_perlin_map(np_mid, chulensxz):get2dMap_flat(minposxz)
	local nvals_base = minetest.get_perlin_map(np_base, chulensxz):get2dMap_flat(minposxz)
	local nvals_patha = minetest.get_perlin_map(np_patha, chulensxz):get2dMap_flat(minposxz)
	local nvals_pathb = minetest.get_perlin_map(np_pathb, chulensxz):get2dMap_flat(minposxz)
	local nvals_temp = minetest.get_perlin_map(np_temp, chulensxz):get2dMap_flat(minposxz)
	local nvals_tree = minetest.get_perlin_map(np_tree, chulensxz):get2dMap_flat(minposxz)
	local nvals_grass = minetest.get_perlin_map(np_grass, chulensxz):get2dMap_flat(minposxz)
	
	--local noiset = math.ceil((os.clock() - t0) * 1000)
	--print ("[riverdev] noise "..noiset.." ms")

	local viu = area:index(x0, y0-1, z0)
	local ungen = data[viu] == c_ignore
	
	local nixyz = 1
	local nixz = 1
	local stable = {}
	local under = {}
	for z = z0 - 1, z1 do
	for y = y0 - 1, y1 + 1 do
		local si = 1
		local vi = area:index(x0-1, y, z)
		local viu = area:index(x0-1, y-1, z)
		local n_xprepatha = false
		local n_xprepathb = false
		for x = x0 - 1, x1 do
			local nodid = data[vi]
			local nodidu = data[viu]
			local chunkxz = x >= x0 and z >= z0

			local n_temp = nvals_temp[nixz]
			local n_tree = math.min(math.max(nvals_tree[nixz], 0), 1)
			local n_grass = math.min(math.max(nvals_grass[nixz], 0), 1)

			local n_patha = nvals_patha[nixz]
			local n_abspatha = math.abs(n_patha)
			local n_zprepatha = nvals_patha[(nixz - overlen)]

			local n_pathb = nvals_pathb[nixz]
			local n_abspathb = math.abs(n_pathb)
			local n_zprepathb = nvals_pathb[(nixz - overlen)]

			local n_terrain = (nvals_terrain[nixyz] + 2) / 2
			local n_absmid = (math.abs(nvals_mid[nixz])) ^ 0.8
			local n_absbase = (math.abs(nvals_base[nixz])) ^ 0.8
			
			local n_invbase = math.max(1 - n_absbase, 0)
			local grad = (YTER - y) / TERSCA
			local densitybase = n_invbase * BASAMP + grad
			local densitymid = n_absmid * MIDAMP + densitybase
			local density = n_terrain * n_invbase * n_absmid * n_abspatha ^ 1.5 * n_abspathb ^ 1.5 + densitymid
			
			local tstone = TSTONE * (1 + grad * 2)
			local triver = TRIVER * n_absbase
			local trsand = TRSAND * n_absbase

			local weba = math.abs(nvals_weba[nixyz]) < TTUN
			local webb = math.abs(nvals_webb[nixyz]) < TTUN + n_invbase ^ 8 * 2 -- blend tunnel into fissure at ridge
			local novoid = not (weba and webb)

			local wood = densitybase > trsand * 2 and density < 0
				
			if chunkxz and y == y0 - 1 then -- overgeneration, initialise tables
				under[si] = 0
				if ungen then -- guess by calculating density
					if density >= 0 and novoid then
						stable[si] = 2
					else
						stable[si] = 0
					end
				else -- scan top layer of chunk below
					if nodid == c_air
					or nodid == c_water
					or nodid == c_freshwater
					or nodid == c_freshwaterflow
					or nodid == c_mixwater
					or nodid == c_mixwaterflow then
						stable[si] = 0
					else
						stable[si] = 2
					end
				end
			elseif chunkxz and y >= y0 and y <= y1 then -- chunk generation
				if density >= tstone
				and (novoid
				or (density < tstone * 1.5
				and (y <= YWATER or densitybase >= triver))) then
					if math.random() < ORECHA and density > TSTONE then -- ores
						local osel = math.random(24)
						if osel == 24 then
							data[vi] = c_stodiam
						elseif osel == 23 then
							data[vi] = c_stomese
						elseif osel == 22 then
							data[vi] = c_stogold
						elseif osel >= 19 then
							data[vi] = c_stocopp
						elseif osel >= 10 then
							data[vi] = c_stoiron
						else
							data[vi] = c_stocoal
						end
					else
						data[vi] = c_stone -- stone
					end
					stable[si] = stable[si] + 1
					under[si] = 5
				elseif y > YSAND
				and ((not wood and density < 0 and under[si] ~= 0)
				or (wood and densitybase > trsand * 2 and densitybase < trsand * 2 + 0.002))
				and (((n_patha >= 0 and n_xprepatha < 0) or (n_patha < 0 and n_xprepatha >= 0)) -- patha
				or ((n_patha >= 0 and n_zprepatha < 0) or (n_patha < 0 and n_zprepatha >= 0))
				or ((n_pathb >= 0 and n_xprepathb < 0) or (n_pathb < 0 and n_xprepathb >= 0)) -- pathb
				or ((n_pathb >= 0 and n_zprepathb < 0) or (n_pathb < 0 and n_zprepathb >= 0))) then
					if wood and math.random() < 0.125 then
						local vi = area:index(x, y-2, z)
						for j = 1, (16 + y - y0) do
							if data[vi] == c_stone then
								break
							else
								data[vi] = c_wood
							end
							vi = vi - emerlen
						end
					end
					for k = -1, 1 do
						local vi = area:index(x-1, y-1, z+k)
						for i = -1, 1 do
							if wood then
								data[vi] = c_wood
							else
								data[vi] = c_path
							end
							vi = vi + 1
						end
					end
					stable[si] = 0
					under[si] = 0
				elseif density >= 0 and density < tstone and stable[si] >= 2 then -- fine materials
					if y <= YSAND + math.random(-1, 1)
					or densitybase >= trsand + math.random() * 0.002 then
						data[vi] = c_sand
						under[si] = 1
					elseif n_temp < LOTET then -- taiga/snowyplains
						data[vi] = c_dirt
						under[si] = 3
					elseif n_temp > HITET then -- rainforest
						data[vi] = c_dirt
						under[si] = 4
					else
						data[vi] = c_dirt -- deciduous forest/grassland
						under[si] = 2
					end
				elseif y <= YWATER and density < tstone then -- sea water
					data[vi] = c_water
					stable[si] = 0
					under[si] = 0
				elseif densitybase >= triver and density < 0 then -- river water
					if y == YWATER + 1 then
						data[vi] = c_mixwater
					else
						data[vi] = c_freshwater
					end
					stable[si] = 0
					under[si] = 0
				elseif density < 0 and under[si] ~= 0 -- air above surface
				and nodid ~= c_path and nodidu ~= c_path
				and nodid ~= c_wood and nodidu ~= c_wood then
					if under[si] == 1 then -- sand
						if math.random() < BOLCHA
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_boulder(x, y, z, area, data)
						end
					elseif under[si] == 2 then -- forest/grassland
						if math.random() < BOLCHA
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_boulder(x, y, z, area, data)
						elseif math.random() < APPCHA * n_tree and y < YPINE
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_appletree(x, y, z, area, data)
						elseif math.random() < PINCHA * n_tree and y >= YPINE
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_pinetree(x, y, z, area, data)
						else
							data[viu] = c_grass
							if math.random() < FLOCHA then
								riverdev_flower(data, vi)
							elseif math.random() < GRACHA * n_grass then
								data[vi] = c_grass5
							end
						end
					elseif under[si] == 3 then -- taiga
						if math.random() < PINCHA * n_tree
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_snowypine(x, y, z, area, data)
						else
							data[viu] = c_grass
							data[vi] = c_snowblock
						end
					elseif under[si] == 4 then -- rainforest
						if math.random() < JUNCHA
						and n_abspatha > TPFLO / 2 and n_abspathb > TPFLO / 2 then
							riverdev_jungletree(x, y, z, area, data)
						else
							data[viu] = c_grass
							if math.random() < GRACHA then
								data[vi] = c_jungrass
							end
						end
					elseif under[si] == 5 and n_temp < LOTET then
							data[vi] = c_snowblock
					end
					stable[si] = 0
					under[si] = 0
				else -- air or tunnel
					stable[si] = 0
					under[si] = 0
				end
			elseif chunkxz and y == y1 + 1 then -- overgeneration
				if y > YSAND
				and ((not wood and density < 0 and under[si] ~= 0)
				or (wood and densitybase > trsand * 2 and densitybase < trsand * 2 + 0.002))
				and (((n_patha >= 0 and n_xprepatha < 0) or (n_patha < 0 and n_xprepatha >= 0)) -- patha
				or ((n_patha >= 0 and n_zprepatha < 0) or (n_patha < 0 and n_zprepatha >= 0))
				or ((n_pathb >= 0 and n_xprepathb < 0) or (n_pathb < 0 and n_xprepathb >= 0)) -- pathb
				or ((n_pathb >= 0 and n_zprepathb < 0) or (n_pathb < 0 and n_zprepathb >= 0))) then
					if wood and math.random() < 0.125 then
						local vi = area:index(x, y-2, z)
						for j = 1, (16 + y - y0) do
							if data[vi] == c_stone then
								break
							else
								data[vi] = c_wood
							end
							vi = vi - emerlen
						end
					end
					for k = -1, 1 do
						local vi = area:index(x-1, y-1, z+k)
						for i = -1, 1 do
							if wood then
								data[vi] = c_wood
							else
								data[vi] = c_path
							end
							vi = vi + 1
						end
					end
				elseif density < 0 and under[si] ~= 0
				and nodid ~= c_path and nodidu ~= c_path
				and nodid ~= c_wood and nodidu ~= c_wood then
					if under[si] == 2 then -- forest/grassland
						if math.random() < APPCHA * n_tree and y < YPINE
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_appletree(x, y, z, area, data)
						elseif math.random() < PINCHA * n_tree and y >= YPINE
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_pinetree(x, y, z, area, data)
						else
							data[viu] = c_grass
							if math.random() < FLOCHA then
								riverdev_flower(data, vi)
							elseif math.random() < GRACHA * n_grass then
								data[vi] = c_grass5
							end
						end
					elseif under[si] == 3 then -- taiga
						if math.random() < PINCHA * n_tree
						and n_abspatha > TPFLO and n_abspathb > TPFLO then
							riverdev_snowypine(x, y, z, area, data)
						else
							data[viu] = c_grass
							data[vi] = c_snowblock
						end
					elseif under[si] == 4 then -- rainforest
						if math.random() < JUNCHA
						and n_abspatha > TPFLO / 2 and n_abspathb > TPFLO / 2 then
							riverdev_jungletree(x, y, z, area, data)
						else
							data[viu] = c_grass
							if math.random() < GRACHA then
								data[vi] = c_jungrass
							end
						end
					elseif under[si] == 5 and n_temp < LOTET then
							data[vi] = c_snowblock
					end
				end
			end
				
			n_xprepatha = n_patha
			n_xprepathb = n_pathb
			nixyz = nixyz + 1
			nixz = nixz + 1
			vi = vi + 1
			viu = viu + 1
			si = si + 1
		end
		nixz = nixz - overlen
	end
	nixz = nixz + overlen
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()

	local chugent = math.ceil((os.clock() - t0) * 1000)
	print ("[riverdev] "..chugent.." ms")
end)

