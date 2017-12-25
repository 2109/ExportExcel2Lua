return function (str)
	str = str:lower()
	if str ~= "true" and str ~= "false" and str ~= "1" and str ~= "0"  then
		error(str)
	end

	local template = [[
		return %s
	]]
	template = string.format(template,str)
	return load(template)()
end