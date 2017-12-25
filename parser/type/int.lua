return function (str)
	local value = tonumber(str)
	return math.modf(value)
end