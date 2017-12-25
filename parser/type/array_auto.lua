return function (str)
	local result = {}
	for v in string.gmatch(str, "([^,]+),*") do
		local value = tonumber(v)
		if value == nil then
			table.insert(result,v)
		else
			table.insert(result,value)
		end
	end
	return result
end