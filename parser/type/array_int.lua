return function (str)
	local result = {}
	for v in string.gmatch(str, "([^,]+),*") do
		local value = tonumber(v)
		assert(value ~= nil)
		value = math.modf(value)
		table.insert(result,value)
	end
	return result
end