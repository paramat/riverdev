function riverdev_appletree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_appleaf = minetest.get_content_id("riverdev:appleleaf")
	local top = 3 + math.random(2)
	for j = -2, top do
		if j == top - 1 or j == top then
			for i = -2, 2 do
			for k = -2, 2 do
				local vi = area:index(x + i, y + j, z + k)
				if math.random(5) ~= 2 then
					data[vi] = c_appleaf
					if j == top and math.random() < 0.04 then -- apples hang from leaves
						local viu = area:index(x + i, y + j - 1, z + k)
						data[viu] = c_apple
					end
				end
			end
			end
		elseif j == top - 2 then
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_tree
				end
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
			for i = -2, 2 do
			for k = -2, 2 do
				if math.abs(i) == 2 or math.abs(k) == 2 then
					if math.random(7) ~= 2 then
						local vil = area:index(x + i, y + j, z + k)
						data[vil] = c_needles
					end
				end
			end
			end
		elseif j == 4 or j == 7 or j == 10 then
			for i = -1, 1 do
			for k = -1, 1 do
				if not (i == 0 and j == 0) then
					if math.random(11) ~= 2 then
						local vil = area:index(x + i, y + j, z + k)
						data[vil] = c_needles
					end
				end
			end
			end
		elseif j == 13 then
			for i = -1, 1 do
			for k = -1, 1 do
				if not (i == 0 and j == 0) then
					local vil = area:index(x + i, y + j, z + k)
					data[vil] = c_needles
					local vila = area:index(x + i, y + j + 1, z + k)
					data[vila] = c_needles
				end
			end
			end
		end
		local vit = area:index(x, y + j, z)
		data[vit] = c_pinetree
	end
	local vil = area:index(x, y + 15, z)
	local vila = area:index(x, y + 16, z)
	data[vil] = c_needles
	data[vila] = c_needles
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
		local pos1 = {x=x-2, y=y-2, z=z-2}
		local pos2 = {x=x+2, y=y+5, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
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
		local pos1 = {x=x-2, y=y-4, z=z-2}
		local pos2 = {x=x+2, y=y+16, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		riverdev_pinetree(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Spawn flat facing south

	function riverdev_flatsouth(pos)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_air = minetest.get_content_id("air")
		local c_tree = minetest.get_content_id("default:tree")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-2, y=y-5, z=z-2}
		local pos2 = {x=x+9, y=y+4, z=z+9}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		for j = -5, 4 do
		for k = -2, 9 do
			local vi = area:index(x-2, y+j, z+k)
			for i = -2, 9 do
				local nodid = data[vi]
				if nodid == c_tree then
					data[vi] = c_air
					--for j = -2, 2 do
					--for k = -2, 2 do
					--for i = -2, 2 do
					--end
					--end
					--end
				end
				vi = vi + 1
			end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()

		local path = minetest.get_modpath("riverdev") .. "/schems/flat.mts"
		minetest.place_schematic({x=x, y=y, z=z}, path, 270, nil, false)
	end
