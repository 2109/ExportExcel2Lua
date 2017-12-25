local cjson = require "cjson"

return function (str)
	local result = assert(cjson.decode(str))
	return result
end