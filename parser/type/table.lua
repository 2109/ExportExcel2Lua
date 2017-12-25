return function (str)
	local result = {}
	
	for value in string.gmatch(str, "([^,]+),*") do
		local args = {}
		for v in string.gmatch(value, "([^|]+)|*") do
			local value = tonumber(v)
			if value == nil then
				table.insert(args,v)
			else
				table.insert(args,value)
			end
		end
		assert(#args == 2)
		result[args[1]] = args[2]
	end
	return result
end