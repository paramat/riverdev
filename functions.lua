function riverdev_appletree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_appleleaf = minetest.get_content_id("riverdev:appleleaf")
	local top = 3 + math.random(2)
	for j = -2, top do
		if j == top - 1 or j == top then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				local viu = area:index(x - 2, y + j - 1, z + k)
				for i = -2, 2 do
					if math.random() < 0.8 then
						data[vi] = c_appleleaf
						if j == top and math.random() < 0.04 then
							data[viu] = c_apple
						end
					end
					vi = vi + 1
					viu = viu + 1
				end
			end
		elseif j == top - 2 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 2 then
						data[vi] = c_tree
					end
					vi = vi + 1
				end
			end
		else
			local vi = area:index(x, y + j, z)
			data[vi] = c_tree
		end
	end
end

function riverdev_pinetree(x, y, z, area, data)
	local c_pinetree = minetest.get_content_id("riverdev:pinetree")
	local c_needles = minetest.get_content_id("riverdev:needles")
	for j = -4, 14 do
		if j == 3 or j == 6 or j == 9 or j == 12 then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				for i = -2, 2 do
					if math.abs(i) == 1 and math.abs(k) == 1 then
						data[vi] = c_pinetree
					elseif math.abs(i) + math.abs(k) == 2
					or math.abs(i) + math.abs(k) == 3 then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		elseif j == 4 or j == 7 or j == 10 or j == 13 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if not (i == 0 and j == 0) then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		elseif j == 14 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 1 then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		end
		local vi = area:index(x, y + j, z)
		data[vi] = c_pinetree
	end
	local vi = area:index(x, y + 15, z)
	local via = area:index(x, y + 16, z)
	data[vi] = c_needles
	data[via] = c_needles
end

function riverdev_snowypine(x, y, z, area, data)
	local c_pinetree = minetest.get_content_id("riverdev:pinetree")
	local c_needles = minetest.get_content_id("riverdev:needles")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	for j = -4, 14 do
		if j == 3 or j == 6 or j == 9 or j == 12 then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				local via = area:index(x - 2, y + j + 1, z + k)
				for i = -2, 2 do
					if math.abs(i) == 1 and math.abs(k) == 1 then
						data[vi] = c_pinetree
					elseif math.abs(i) + math.abs(k) == 2
					or math.abs(i) + math.abs(k) == 3 then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		elseif j == 4 or j == 7 or j == 10 or j == 13 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				local via = area:index(x - 1, y + j + 1, z + k)
				for i = -1, 1 do
					if not (i == 0 and j == 0) then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		elseif j == 14 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				local via = area:index(x - 1, y + j + 1, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 1 then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		end
		local vi = area:index(x, y + j, z)
		data[vi] = c_pinetree
	end
	local vi = area:index(x, y + 15, z)
	local via = area:index(x, y + 16, z)
	local viaa = area:index(x, y + 17, z)
	data[vi] = c_needles
	data[via] = c_needles
	data[viaa] = c_snowblock
end

function riverdev_jungletree(x, y, z, area, data, y1)
	local c_juntree = minetest.get_content_id("default:jungletree")
	local c_junleaf = minetest.get_content_id("riverdev:jungleleaf")
	local c_vine = minetest.get_content_id("riverdev:vine")
	local top = math.random(13, math.min(y1 + 16 - y, 23)) -- avoid chopped trees
	local branch = math.floor(top * 0.6)
	for j = -5, top do
		if j == top or j == top - 1 or j == branch + 1 or j == branch + 2 then
			for i = -2, 2 do -- leaves
			for k = -2, 2 do
				local vi = area:index(x + i, y + j, z + k)
				if math.random(5) ~= 2 then
					data[vi] = c_junleaf
				end
			end
			end
		elseif j == top - 2 or j == branch then -- branches
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_juntree
				end
			end
			end
		end
		if j >= 0 and j <= top - 3 then -- climbable nodes
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 1 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_vine
				end
			end
			end
		end
		if j <= top - 3 then -- trunk
			local vi = area:index(x, y + j, z)
			data[vi] = c_juntree
		end
	end
end

function riverdev_acaciatree(x, y, z, area, data)
	local c_actree = minetest.get_content_id("riverdev:acaciatree")
	local c_acleaf = minetest.get_content_id("riverdev:acacialeaf")
	local top = 4 + math.random(3)
	for j = -3, top do
		if j == top then
			for i = -4, 4 do
			for k = -4, 4 do
				if not (i == 0 or k == 0) then
					if math.random(7) ~= 2 then
						local vi = area:index(x + i, y + j, z + k)
						data[vi] = c_acleaf
					end
				end
			end
			end
		elseif j == top - 1 then
			for i = -2, 2, 4 do
			for k = -2, 2, 4 do
				local vi = area:index(x + i, y + j, z + k)
				data[vi] = c_actree
			end
			end
		elseif j == top - 2 then
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_actree
				end
			end
			end
		else
			local vi = area:index(x, y + j, z)
			data[vi] = c_actree
		end
	end
end

function riverdev_cactus(x, y, z, area, data)
	local c_cactus = minetest.get_content_id("riverdev:cactus")
	for j = -2, 4 do
	for i = -2, 2 do
		if i == 0 or j == 2 or (j == 3 and math.abs(i) == 2) then
			local vic = area:index(x + i, y + j, z)
			data[vic] = c_cactus
		end
	end
	end
end

function riverdev_boulder(x, y, z, area, data)
	local c_stone = minetest.get_content_id("riverdev:stone")
	local dx = math.random() * 15 + 1
	local dy = math.random() * 15 + 1
	local dz = math.random() * 15 + 1
	for k = -8, 8 do
	for j = -8, 8 do
		local vi = area:index(x-8, y+j, z+k)
		for i = -8, 8 do
			if (i ^ 2 * dx + j ^ 2 * dy + k ^ 2 * dz) ^ 0.5 < 8 then
				data[vi] = c_stone
			end
			vi = vi + 1
		end
	end
	end
end

function riverdev_flower(data, vi)
	local c_danwhi = minetest.get_content_id("flowers:dandelion_white")
	local c_danyel = minetest.get_content_id("flowers:dandelion_yellow")
	local c_rose = minetest.get_content_id("flowers:rose")
	local c_tulip = minetest.get_content_id("flowers:tulip")
	local c_geranium = minetest.get_content_id("flowers:geranium")
	local c_viola = minetest.get_content_id("flowers:viola")
	local rand = math.random(6)
	if rand == 1 then
		data[vi] = c_danwhi
	elseif rand == 2 then
		data[vi] = c_rose
	elseif rand == 3 then
		data[vi] = c_tulip
	elseif rand == 4 then
		data[vi] = c_danyel
	elseif rand == 5 then
		data[vi] = c_geranium
	else
		data[vi] = c_viola
	end
end

-- ABM

-- Appletree sapling

minetest.register_abm({
	nodenames = {"riverdev:appling"},
	interval = 31,
	chance = 5,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - 2, y = y - 2, z = z - 2}
		local pos2 = {x = x + 2, y = y + 5, z = z + 2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		riverdev_appletree(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Pinetree sapling

minetest.register_abm({
	nodenames = {"riverdev:pineling"},
	interval = 29,
	chance = 5,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - 2, y = y - 4, z = z - 2}
		local pos2 = {x = x + 2, y = y + 17, z = z + 2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		riverdev_pinetree(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Jungletree sapling

minetest.register_abm({
	nodenames = {"riverdev:jungling"},
	interval = 63,
	chance = 3,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - 2, y = y - 5, z = z - 2}
		local pos2 = {x = x + 2, y = y + 23, z = z + 2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		-- check temp/humid
		riverdev_jungletree(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Acacia sapling

minetest.register_abm({
	nodenames = {"riverdev:acacialing"},
	interval = 61,
	chance = 3,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - 4, y = y - 3, z = z - 4}
		local pos2 = {x = x + 4, y = y + 7, z = z + 4}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		riverdev_acaciatree(x, y, z, area, data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})
