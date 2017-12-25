return function (str)
	local result = {}
	for v in string.gmatch(str, "([^,]+),*") do
		table.insert(result,v)
	end
	return result
end