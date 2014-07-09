-- riverdev 0.4.1 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- Parameters

local YMIN = -33000
local YMAX = 33000
local YWATER = 1
local YSAND = 4 -- Top of beach
local YTER = -64 -- Terrain zero level, average seabed level

local TERSCA = 512 -- Terrain vertical scale in nodes
local BASAMP = 0.3 -- Base amplitude. Ridge network structure
local MIDAMP = 0.1 -- Mid amplitude. River valley structure
local TERAMP = 0.6 -- Primary terrain amplitude. Stream / path valley structure

local TSTONE = 0.02
local TRIVER = -0.02
local TRSAND = -0.025

local APPCHA = 1 / 4 ^ 2 -- Appletree maximum chance per grass node. 1 / n ^ 2 where n = minimum average distance between flora

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
	persist = 0.4
}

-- 2D noises for patha / top terrain

local np_patha = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384},
	seed = 7000023,
	octaves = 3,
	persist = 0.4
}

-- 2D noises for pathb / top terrain

local np_pathb = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384},
	seed = 23,
	octaves = 4,
	persist = 0.4
}

-- 2D noise for trees

local np_tree = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 133338,
	octaves = 3,
	persist = 0.5
}

-- Stuff

riverdev = {}

dofile(minetest.get_modpath("riverdev").."/functions.lua")
dofile(minetest.get_modpath("riverdev").."/nodes.lua")

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
end)

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
	local c_ignore = minetest.get_content_id("ignore")
	local c_water = minetest.get_content_id("default:water_source")
	local c_sand = minetest.get_content_id("default:sand")
	local c_wood = minetest.get_content_id("default:wood")

	local c_dirt = minetest.get_content_id("riverdev:dirt")
	local c_grass = minetest.get_content_id("riverdev:grass")
	local c_stone = minetest.get_content_id("riverdev:stone")
	local c_path = minetest.get_content_id("riverdev:path")
	local c_freshwater = minetest.get_content_id("riverdev:freshwater")
	local c_mixwater = minetest.get_content_id("riverdev:mixwater")
	local c_freshwaterflow = minetest.get_content_id("riverdev:freshwaterflow")
	local c_mixwaterflow = minetest.get_content_id("riverdev:mixwaterflow")
	
	local sidelen = x1 - x0 + 1 -- chunk sidelen
	local chulensxyz = {x=sidelen+1, y=sidelen+2, z=sidelen+1}
	local minposxyz = {x=x0-1, y=y0-1, z=z0-1}
	local chulensxz = {x=sidelen+1, y=sidelen+1, z=sidelen} -- different because here x=x, y=z
	local minposxz = {x=x0-1, y=z0-1}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulensxyz):get3dMap_flat(minposxyz)

	local nvals_mid = minetest.get_perlin_map(np_mid, chulensxz):get2dMap_flat(minposxz)
	local nvals_base = minetest.get_perlin_map(np_base, chulensxz):get2dMap_flat(minposxz)
	local nvals_patha = minetest.get_perlin_map(np_patha, chulensxz):get2dMap_flat(minposxz)
	local nvals_pathb = minetest.get_perlin_map(np_pathb, chulensxz):get2dMap_flat(minposxz)
	local nvals_tree = minetest.get_perlin_map(np_tree, chulensxz):get2dMap_flat(minposxz)
	
	local viu = area:index(x0, y0-1, z0)
	local ungen = data[viu] == c_ignore
	
	local nixyz = 1
	local nixz = 1
	local stable = {}
	local under = {}
	for z = z0 - 1, z1 do
	for y = y0 - 1, y1 + 1 do
		local vi = area:index(x0-1, y, z)
		local viu = area:index(x0-1, y-1, z)
		local n_xprepatha = false
		local n_xprepathb = false
		for x = x0 - 1, x1 do
			local si = x - x0 + 2
			local nodid = data[vi]
			local nodidu = data[viu]
			local chunkxz = x >= x0 and z >= z0
			local n_tree = math.min(math.max(nvals_tree[nixz], 0), 1)

			local n_patha = nvals_patha[nixz]
			local n_abspatha = math.abs(n_patha)
			local n_zprepatha = nvals_patha[(nixz - sidelen - 1)]

			local n_pathb = nvals_pathb[nixz]
			local n_abspathb = math.abs(n_pathb)
			local n_zprepathb = nvals_pathb[(nixz - sidelen - 1)]

			local n_terrain = (nvals_terrain[nixyz] + 2) / 2
			local n_absmid = math.abs(nvals_mid[nixz])
			local n_absbase = math.abs(nvals_base[nixz])
			
			local n_invbase = (1 - n_absbase)
			local grad = (YTER - y) / TERSCA
			local densitybase = n_invbase * BASAMP + grad
			local densitymid = n_absmid * MIDAMP + densitybase
			local teramp = n_invbase * TERAMP
			local density = n_terrain * teramp * n_absmid * (0.1 + n_abspatha * n_abspathb) + densitymid
			
			local tstone = TSTONE * (1 + grad)
			local triver = TRIVER * n_absbase
			local trsand = TRSAND * n_absbase

			local wood = densitybase > trsand * 2 and density < 0
				
			if chunkxz and y == y0 - 1 then -- overgeneration, initialise tables
				under[si] = 0
				if ungen then -- guess by calculating density
					if density >= 0 then
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
				if density >= tstone then -- stone
					data[vi] = c_stone
					stable[si] = stable[si] + 1
					under[si] = 0
				elseif y > YSAND
				and ((not wood and density < 0 and under[si] ~= 0)
				or (wood and densitybase > trsand * 2 and densitybase < trsand * 2 + 0.002))
				and (((n_patha >= 0 and n_xprepatha < 0) or (n_patha < 0 and n_xprepatha >= 0)) -- patha
				or ((n_patha >= 0 and n_zprepatha < 0) or (n_patha < 0 and n_zprepatha >= 0))
				or ((n_pathb >= 0 and n_xprepathb < 0) or (n_pathb < 0 and n_xprepathb >= 0)) -- pathb
				or ((n_pathb >= 0 and n_zprepathb < 0) or (n_pathb < 0 and n_zprepathb >= 0))) then
					if wood and math.random() < 0.1 then
						local vi = area:index(x, y-2, z)
						for j = 1, 16 do
							data[vi] = c_wood
							vi = vi - 112
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
					if y <= YSAND + math.random() * 2
					or densitybase >= trsand + math.random() * 0.002 then
						data[vi] = c_sand
						under[si] = 2
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
				elseif density < 0 and under[si] ~= 0 then -- air above surface
					if under[si] == 1 and nodidu ~= c_path then
						if math.random() < APPCHA * n_tree
						and n_abspatha > 0.03 and n_abspathb > 0.03 then
							riverdev_appletree(x, y, z, area, data)
						else
							data[viu] = c_grass
						end
					end
					stable[si] = 0
					under[si] = 0
				else -- air
					stable[si] = 0
					under[si] = 0
				end
			elseif chunkxz and y == y1 + 1 then -- overgeneration, detect surface, add surface nodes
				if density < 0 and under[si] ~= 0 then
					if under[si] == 1 and nodidu ~= c_path then
						data[viu] = c_grass
					end
				end
			end
				
			n_xprepatha = n_patha
			n_xprepathb = n_pathb
			nixyz = nixyz + 1
			nixz = nixz + 1
			vi = vi + 1
			viu = viu + 1
		end
		nixz = nixz - sidelen - 1
	end
	nixz = nixz + sidelen + 1
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[riverdev] "..chugent.." ms")
end)
