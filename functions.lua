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
