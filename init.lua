-- Parameters

local PSCA = 16 -- Player scatter. Maximum distance in chunks (80 nodes)
				-- of player spawn from (0, 0, 0)

local YWATER = 1 -- Water surface y
local YSAND = 4 -- Top of beach y
local YTER = -64 -- Deepest seabed y
local YPINE = 47 -- Pines above this y

local TERSCA = 512 -- Terrain vertical scale in nodes
local BASAMP = 0.3 -- Base amplitude relative to 3D noise amplitude. Ridge network structure
local MIDAMP = 0.05 -- Mid amplitude relative to 3D noise amplitude. River valley structure

local TSTONE = 0.02 -- Maximum depth of stone under surface
local TRIVER = -0.018 -- River depth
local TRSAND = -0.022 -- Depth of river sand
local TPFLO = 0.02 -- Width of flora clearing around paths
local TTUN = 0.06 -- Tunnel width
local TFIS = 0.004 -- Fissure width
local TCAV = 1.1 -- Cavern threshold
local ORETHI = 0.003 -- Ore seam minimum thickness (diamond, mese, gold)
-- 1 / n ^ 3 where n = average distance between ores
local ORECHA = 1 / 5 ^ 3 -- Ore chance per stone node

-- 1 / n ^ 2 where n = average distance between features
local BOLCHA = 1 / 128 ^ 2 -- Boulder chance per surfacenode

local LOTET = -0.4 -- Low temperature threshold
local HITET = 0.4 -- High ^
local LOHUT = 0.2 -- Low humidity threshold (abs noise)
local HIHUT = 0.6 -- High ^

-- 2D noise for mid terrain / river

local np_mid = {
	offset = 0,
	scale = 1,
	spread = {x = 1536, y = 1536, z = 1536},
	seed = 85546,
	octaves = 6,
	persist = 0.4
}

-- 2D noise for base terrain / humidity

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x = 3072, y = 3072, z = 3072},
	seed = -990054,
	octaves = 3,
	persist = 0.4
}

-- 2D noises for patha / top terrain

local np_patha = {
	offset = 0,
	scale = 1,
	spread = {x = 768, y = 768, z = 768},
	seed = 7000023,
	octaves = 4,
	persist = 0.4
}

-- 2D noises for pathb / top terrain

local np_pathb = {
	offset = 0,
	scale = 1,
	spread = {x = 768, y = 768, z = 768},
	seed = 23,
	octaves = 4,
	persist = 0.4
}

-- 2D noise for temperature

local np_temp = {
	offset = 0,
	scale = 1,
	spread = {x = 3072, y = 3072, z = 3072},
	seed = 18882,
	octaves = 3,
	persist = 0.4
}

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 192, z = 384},
	seed = 5900033,
	octaves = 5,
	persist = 0.67
}

-- 3D noise for alt terrain

local np_terrainalt = {
	offset = 0,
	scale = 1,
	spread = {x = 311, y = 155, z = 311},
	seed = -5933,
	octaves = 5,
	persist = 0.67
}

-- 3D noises for tunnels

local np_weba = {
	offset = 0,
	scale = 1,
	spread = {x = 61, y = 61, z = 61},
	seed = 5900033,
	octaves = 3,
	persist = 0.5
}

local np_webb = {
	offset = 0,
	scale = 1,
	spread = {x = 67, y = 67, z = 67},
	seed = 33,
	octaves = 3,
	persist = 0.5
}

-- 3D noise for strata layering

local np_strata = {
	offset = 0,
	scale = 1,
	spread = {x = 3072, y = 48, z = 3072},
	seed = 92219,
	octaves = 4,
	persist = 1
}


-- Do files

dofile(minetest.get_modpath("riverdev") .. "/functions.lua")
dofile(minetest.get_modpath("riverdev") .. "/nodes.lua")


-- Set mapgen parameters

minetest.set_mapgen_params({mgname = "singlenode", flags = "nolight"})


-- Mapgen functions

local function riverdev_pathbrush(x, y, z, area, data,
	y0, wood, emerlen, stable, under, si)

	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_path = minetest.get_content_id("riverdev:path")
	local c_wood = minetest.get_content_id("default:junglewood")
	local c_snow = minetest.get_content_id("default:snow")

	if wood and math.random() < 0.2 then
		local vi = area:index(x, y - 2, z)
		for j = y - 2, y0 - 16, -1 do -- use mapblock shell
			if data[vi] == c_stone then
				break
			else
				data[vi] = c_wood
			end
			vi = vi - emerlen
		end
	end
	for k = -1, 1 do
		local vi = area:index(x - 1, y - 1, z + k)
		local via = vi + emerlen
		for i = -1, 1 do
			if wood then
				data[vi] = c_wood
			else
				data[vi] = c_path
			end
			if data[via] ~= c_path and data[via] ~= c_wood
			and under[si] == 2 then
				data[via] = c_snow
			end
			vi = vi + 1
			via = via + 1
		end
	end
	stable[si] = 0
	under[si] = 0
end


local function riverdev_surface(x, y, z, area, data, y1, vi, viu,
	n_abspatha, n_abspathb, n_temp, n_humid, under, si)

	local c_grass = minetest.get_content_id("riverdev:grass")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_drygrass = minetest.get_content_id("riverdev:drygrass")
	local c_icydirt = minetest.get_content_id("riverdev:icydirt")

	if under[si] == 1 then -- tundra
		data[viu] = c_icydirt
	elseif under[si] == 2 then -- taiga
		data[viu] = c_grass
		data[vi] = c_snowblock
	elseif under[si] == 3 then -- dry grassland
		data[viu] = c_drygrass
	elseif under[si] == 4 then -- forest/grassland
		if math.random() < BOLCHA
				and n_abspatha > TPFLO and n_abspathb > TPFLO then
			riverdev_boulder(x, y, z, area, data)
		else
			data[viu] = c_grass
		end
	elseif under[si] == 6 then -- savanna
		data[viu] = c_drygrass
	elseif under[si] == 7 then -- rainforest
		data[viu] = c_grass
	elseif under[si] == 8 then -- sand
		if math.random() < BOLCHA
				and n_abspatha > TPFLO and n_abspathb > TPFLO then
			riverdev_boulder(x, y, z, area, data)
		end
	elseif under[si] == 9 and n_temp < LOTET then -- stone
			data[vi] = c_snowblock
	end
end


-- initialize noise objects to nil

local nobj_terrain    = nil
local nobj_terrainalt = nil
local nobj_weba       = nil
local nobj_webb       = nil
local nobj_strata     = nil
	
local nobj_mid        = nil
local nobj_base       = nil
local nobj_patha      = nil
local nobj_pathb      = nil
local nobj_temp       = nil


-- Localise noise buffers

local nbuf_terrain = {}
local nbuf_terrainalt = {}
local nbuf_weba = {}
local nbuf_webb = {}
local nbuf_strata = {}

local nbuf_mid = {}
local nbuf_base = {}
local nbuf_humid = {}
local nbuf_patha = {}
local nbuf_pathb = {}
local nbuf_temp = {}


-- Localise data buffer

local dbuf = {}


-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	local t0 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data(dbuf)
	
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_water = minetest.get_content_id("default:water_source")
	local c_sand = minetest.get_content_id("default:sand")
	local c_sandstone = minetest.get_content_id("default:sandstone")
	local c_wood = minetest.get_content_id("default:junglewood")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_ice = minetest.get_content_id("default:ice")
	local c_desand = minetest.get_content_id("default:desert_sand")
	local c_stodiam = minetest.get_content_id("default:stone_with_diamond")
	local c_stomese = minetest.get_content_id("default:stone_with_mese")
	local c_stogold = minetest.get_content_id("default:stone_with_gold")
	local c_stocopp = minetest.get_content_id("default:stone_with_copper")
	local c_stoiron = minetest.get_content_id("default:stone_with_iron")
	local c_stocoal = minetest.get_content_id("default:stone_with_coal")

	local c_dirt = minetest.get_content_id("riverdev:dirt")
	local c_grass = minetest.get_content_id("riverdev:grass")
	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_redstone = minetest.get_content_id("riverdev:redstone")
	local c_path = minetest.get_content_id("riverdev:path")
	local c_freshwater = minetest.get_content_id("riverdev:freshwater")
	local c_mixwater = minetest.get_content_id("riverdev:mixwater")
	local c_freshwaterflow = minetest.get_content_id("riverdev:freshwaterflow")
	local c_mixwaterflow = minetest.get_content_id("riverdev:mixwaterflow")
	local c_permafrost = minetest.get_content_id("riverdev:permafrost")
	
	local sidelen = x1 - x0 + 1 -- mapgen chunk side length
	local overlen = sidelen + 1 -- perlinmap overgeneration horizontal side length
	local emerlen = sidelen + 32 -- voxelmanip emerged volume edge length
	--local emerarea = emerlen ^ 2 -- voxelmanip emerged volume face area
	local chulensxyz = {x = overlen, y = sidelen + 2, z = overlen}
	local minposxyz = {x = x0 - 1, y = y0 - 1, z = z0 - 1}
	local chulensxz = {x = overlen, y = overlen, z = 1} -- different because here x=x, y=z
	local minposxz = {x = x0 - 1, y = z0 - 1}
	-- 3D and 2D noise objects created once on first mapchunk generation only
	nobj_terrain    = nobj_terrain    or minetest.get_perlin_map(np_terrain, chulensxyz)
	nobj_terrainalt = nobj_terrainalt or minetest.get_perlin_map(np_terrainalt, chulensxyz)
	nobj_weba       = nobj_weba       or minetest.get_perlin_map(np_weba, chulensxyz)
	nobj_webb       = nobj_webb       or minetest.get_perlin_map(np_webb, chulensxyz)
	nobj_strata     = nobj_strata     or minetest.get_perlin_map(np_strata, chulensxyz)

	nobj_mid        = nobj_mid        or minetest.get_perlin_map(np_mid, chulensxz)
	nobj_base       = nobj_base       or minetest.get_perlin_map(np_base, chulensxz)
	nobj_patha      = nobj_patha      or minetest.get_perlin_map(np_patha, chulensxz)
	nobj_pathb      = nobj_pathb      or minetest.get_perlin_map(np_pathb, chulensxz)
	nobj_temp       = nobj_temp       or minetest.get_perlin_map(np_temp, chulensxyz)
	-- 3D and 2D perlinmaps created per mapchunk
	local nvals_terrain    = nobj_terrain:get3dMap_flat(minposxyz, nbuf_terrain)
	local nvals_terrainalt = nobj_terrainalt:get3dMap_flat(minposxyz, nbuf_terrainalt)
	local nvals_weba       = nobj_weba:get3dMap_flat(minposxyz, nbuf_weba)
	local nvals_webb       = nobj_webb:get3dMap_flat(minposxyz, nbuf_webb)
	local nvals_strata     = nobj_strata:get3dMap_flat(minposxyz, nbuf_strata)

	local nvals_mid        = nobj_mid:get2dMap_flat(minposxz, nbuf_mid)
	local nvals_base       = nobj_base:get2dMap_flat(minposxz, nbuf_base)
	local nvals_humid      = nobj_base:get2dMap_flat({x = x0 - 1, y = z0 + 383}, nbuf_humid)
	local nvals_patha      = nobj_patha:get2dMap_flat(minposxz, nbuf_patha)
	local nvals_pathb      = nobj_pathb:get2dMap_flat(minposxz, nbuf_pathb)
	local nvals_temp       = nobj_temp:get2dMap_flat(minposxz, nbuf_temp)
	-- ungenerated chunk below?
	local viu = area:index(x0, y0 - 1, z0)
	local ungen = data[viu] == c_ignore
	
	local nixyz = 1
	local nixz = 1
	local stable = {}
	local under = {}
	for z = z0 - 1, z1 do
	for y = y0 - 1, y1 + 1 do
		local si = 1
		local vi = area:index(x0 - 1, y, z)
		local viu = vi - emerlen
		local n_xprepatha = false
		local n_xprepathb = false
		for x = x0 - 1, x1 do
			local nodid = data[vi]
			local nodidu = data[viu]
			local chunkxz = x >= x0 and z >= z0

			local n_patha = nvals_patha[nixz]
			local n_abspatha = math.abs(n_patha)
			local n_zprepatha = nvals_patha[(nixz - overlen)]

			local n_pathb = nvals_pathb[nixz]
			local n_abspathb = math.abs(n_pathb)
			local n_zprepathb = nvals_pathb[(nixz - overlen)]

			local n_absweba = math.abs(nvals_weba[nixyz])
			local n_abswebb = math.abs(nvals_webb[nixyz])
			local novoid = not (n_absweba < TTUN and n_abswebb < TTUN)

			local n_terrain = (nvals_terrain[nixyz]
				+ nvals_terrainalt[nixyz] + 2) / 2
			local n_absmid = (math.abs(nvals_mid[nixz])) ^ 0.8
			local n_absbase = (math.abs(nvals_base[nixz])) ^ 0.8
			local n_invbase = math.max(1 - n_absbase, 0)

			local grad = (YTER - y) / TERSCA -- noise gradient
			local densitybase = n_invbase * BASAMP + grad -- ridge surface
			local densitymid = n_absmid * MIDAMP + densitybase -- river valley surface
			local density = n_terrain * n_invbase * n_absmid -- actual surface
				* n_abspatha ^ 1.5 * n_abspathb ^ 1.5 + densitymid
			
			local n_strata = math.abs(nvals_strata[nixyz])
			local n_temp = nvals_temp[nixz]
			local n_humid = math.abs(nvals_humid[nixz]) - n_absmid * 0.5 + 0.5
			local tstone = math.max(TSTONE * (1 + grad * 2), 0)
			local triver = TRIVER * n_absbase
			local trsand = TRSAND * n_absbase
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
				local biome = 0
				if n_temp < LOTET then
					if n_humid < LOHUT then -- tundra
						biome = 1
					else -- taiga
						biome = 2
					end
				elseif n_temp > HITET then
					if n_humid < LOHUT then -- desert
						biome = 5
					elseif n_humid > HIHUT then -- rainforest
						biome = 7
					else -- savanna
						biome = 6
					end
				else
					if n_humid < LOHUT then -- dry grassland
						biome = 3
					else -- temperate forest / grassland
						biome = 4
					end
				end

				if density >= tstone and (novoid
						or (density < tstone * 1.5
						and (y <= YWATER or densitybase >= triver))) then
					if n_strata < 0.1 then -- sandstone
						data[vi] = c_sandstone
					elseif n_strata > 1.4
							and n_strata < 1.4 + ORETHI then
						data[vi] = c_stodiam
					elseif n_strata > 1.2
							and n_strata < 1.2 + ORETHI then
						data[vi] = c_stomese
					elseif n_strata > 1
							and n_strata < 1 + ORETHI then
						data[vi] = c_stogold
					elseif n_strata > 0.8
							and n_strata < 0.8 + ORETHI * 2 then
						data[vi] = c_stocopp
					elseif n_strata > 0.6
							and n_strata < 0.6 + ORETHI * 3 then
						data[vi] = c_stoiron
					elseif n_strata > 0.4
							and n_strata < 0.4 + ORETHI * 4 then
						data[vi] = c_stocoal
					elseif biome == 5 then
						data[vi] = c_redstone -- redstone layer
					else
						data[vi] = c_stone -- stone
					end
					stable[si] = stable[si] + 1
					under[si] = 9
				elseif y > YSAND -- paths
						and ((not wood and density < 0 and under[si] ~= 0)
						or (wood and densitybase > trsand * 2
						and densitybase < trsand * 2 + 0.002))
						and (((n_patha >= 0 and n_xprepatha < 0)
						or (n_patha < 0 and n_xprepatha >= 0))
						or ((n_patha >= 0 and n_zprepatha < 0)
						or (n_patha < 0 and n_zprepatha >= 0))
						or ((n_pathb >= 0 and n_xprepathb < 0)
						or (n_pathb < 0 and n_xprepathb >= 0))
						or ((n_pathb >= 0 and n_zprepathb < 0)
						or (n_pathb < 0 and n_zprepathb >= 0))) then

					riverdev_pathbrush(x, y, z, area, data,
						y0, wood, emerlen, stable, under, si)

				elseif density >= 0 and density < tstone -- fine materials
						and stable[si] >= 2 and nodid ~= c_stone then -- do not replace boulder
					if y <= YSAND or densitybase >= trsand then
						data[vi] = c_sand
						under[si] = 8
					elseif biome == 1 then -- tundra
						data[vi] = c_permafrost
						under[si] = 1
					elseif biome == 2 then -- taiga
						data[vi] = c_dirt
						under[si] = 2
					elseif biome == 3 then -- dry grassland
						data[vi] = c_dirt
						under[si] = 3
					elseif biome == 4 then -- forest / grassland
						data[vi] = c_dirt
						under[si] = 4
					elseif biome == 5 then -- desert
						data[vi] = c_desand
						under[si] = 5
					elseif biome == 6 then -- savanna
						data[vi] = c_dirt
						under[si] = 6
					elseif biome == 7 then -- rainforest
						data[vi] = c_dirt
						under[si] = 7
					end
				elseif y <= YWATER and density < tstone
						and nodid ~= c_stone then -- sea water
					data[vi] = c_water
					stable[si] = 0
					under[si] = 0
				elseif densitybase >= triver and density < tstone
						and nodid ~= c_stone then -- river water
					if y == YWATER + 1 then
						data[vi] = c_mixwater
					else
						data[vi] = c_freshwater
					end
					stable[si] = 0
					under[si] = 0
				elseif density < 0 and y > YWATER
						and under[si] ~= 0 -- detect surface, place surface nodes
						and nodid ~= c_stone
						and nodid ~= c_snowblock and nodidu ~= c_snowblock
						and nodid ~= c_path and nodidu ~= c_path
						and nodid ~= c_wood and nodidu ~= c_wood then

					riverdev_surface(x, y, z, area, data, y1, vi, viu,
						n_abspatha, n_abspathb, n_temp, n_humid, under, si)

					stable[si] = 0
					under[si] = 0
				else -- air or tunnel
					stable[si] = 0
					under[si] = 0
				end
			elseif chunkxz and y == y1 + 1 then -- overgeneration
				if y > YSAND
						and ((not wood and density < 0 and under[si] ~= 0)
						or (wood and densitybase > trsand * 2
						and densitybase < trsand * 2 + 0.002))
						and (((n_patha >= 0 and n_xprepatha < 0)
						or (n_patha < 0 and n_xprepatha >= 0)) -- patha
						or ((n_patha >= 0 and n_zprepatha < 0)
						or (n_patha < 0 and n_zprepatha >= 0))
						or ((n_pathb >= 0 and n_xprepathb < 0)
						or (n_pathb < 0 and n_xprepathb >= 0)) -- pathb
						or ((n_pathb >= 0 and n_zprepathb < 0)
						or (n_pathb < 0 and n_zprepathb >= 0))) then

					riverdev_pathbrush(x, y, z, area, data,
					y0, wood, emerlen, stable, under, si)

				elseif density < 0 and y > YWATER
						and under[si] ~= 0 -- detect surface, place surface nodes
						and nodid ~= c_stone
						and nodid ~= c_snowblock and nodidu ~= c_snowblock
						and nodid ~= c_path and nodidu ~= c_path
						and nodid ~= c_wood and nodidu ~= c_wood then

					riverdev_surface(x, y, z, area, data, y1, vi, viu,
						n_abspatha, n_abspathb, n_temp, n_humid, under, si)

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
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()

	local chugent = math.ceil((os.clock() - t0) * 1000)
	print ("[riverdev] " .. chugent .. " ms")
end)


-- Spawn player function
-- Only works with chunksize = 5 mapblocks

local function riverdev_spawnplayer(player)
	local xsp
	local ysp
	local zsp
	local nobj_terrain = nil
	local nobj_mid     = nil
	local nobj_base    = nil
	local nobj_patha   = nil
	local nobj_pathb   = nil

	for chunk = 1, 128 do
		print ("[riverdev] searching for spawn " .. chunk)
		local x0 = 80 * math.random(-PSCA, PSCA) - 32
		local z0 = 80 * math.random(-PSCA, PSCA) - 32
		local y0 = 80 * math.floor((YWATER + 32) / 80) - 32
		local x1 = x0 + 79
		local z1 = z0 + 79
		local y1 = y0 + 79

		local sidelen = 80
		local chulensxyz = {x = sidelen, y = sidelen, z = sidelen}
		local minposxyz = {x = x0, y = y0, z = z0}
		local chulensxz = {x = sidelen, y = sidelen, z = 1}
		local minposxz = {x = x0, y = z0}
	
		nobj_terrain = nobj_terrain or minetest.get_perlin_map(np_terrain, chulensxyz)
		nobj_mid     = nobj_mid     or minetest.get_perlin_map(np_mid, chulensxz)
		nobj_base    = nobj_base    or minetest.get_perlin_map(np_base, chulensxz)
		nobj_patha   = nobj_patha   or minetest.get_perlin_map(np_patha, chulensxz)
		nobj_pathb   = nobj_pathb   or minetest.get_perlin_map(np_pathb, chulensxz)

		local nvals_terrain = nobj_terrain:get3dMap_flat(minposxyz)
		local nvals_mid     = nobj_mid:get2dMap_flat(minposxz)
		local nvals_base    = nobj_base:get2dMap_flat(minposxz)
		local nvals_patha   = nobj_patha:get2dMap_flat(minposxz)
		local nvals_pathb   = nobj_pathb:get2dMap_flat(minposxz)

		local nixyz = 1
		local nixz = 1
		for z = z0, z1 do
			for y = y0, y1 do
				for x = x0, x1 do
					local n_patha = nvals_patha[nixz]
					local n_abspatha = math.abs(n_patha)
					local n_pathb = nvals_pathb[nixz]
					local n_abspathb = math.abs(n_pathb)

					local n_terrain = (nvals_terrain[nixyz] + 2) / 2
					local n_absmid = (math.abs(nvals_mid[nixz])) ^ 0.8
					local n_absbase = (math.abs(nvals_base[nixz])) ^ 0.8
					local n_invbase = math.max(1 - n_absbase, 0)

					local grad = (YTER - y) / TERSCA
					local densitybase = n_invbase * BASAMP + grad
					local densitymid = n_absmid * MIDAMP + densitybase
					local density = n_terrain * n_invbase * n_absmid *
						n_abspatha ^ 1.5 * n_abspathb ^ 1.5 + densitymid

					if y >= YWATER and density > -0.01 and density < 0 then
						ysp = y + 1
						xsp = x
						zsp = z
						break
					end
					nixz = nixz + 1
					nixyz = nixyz + 1
				end
				if ysp then
					break
				end
				nixz = nixz - 80
			end
			if ysp then
				break
			end
			nixz = nixz + 80
		end
		if ysp then
			break
		end
	end
	if ysp then
		print ("[riverdev] spawn player (" .. xsp .. " " .. ysp .. " " .. zsp .. ")")
		player:setpos({x = xsp, y = ysp, z = zsp})
	else	
		print ("[riverdev] no suitable spawn found")
		player:setpos({x = 0, y = 2, z = 0})
	end
end

minetest.register_on_newplayer(function(player)
	riverdev_spawnplayer(player)
end)

minetest.register_on_respawnplayer(function(player)
	riverdev_spawnplayer(player)
	return true
end)
