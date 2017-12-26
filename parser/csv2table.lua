local lpeg = require "lpeg"
local json = require "cjson"
local util = require "util"

local _compatible = false

local csv2table = {}

function csv2table.split(s,sep)
	sep = lpeg.P(sep)
  	local elem = lpeg.C((1 - sep)^0)
  	local p = lpeg.Ct(elem * (sep * elem)^0)
  	return lpeg.match(p, s)
end

local _field = '"' * lpeg.Cs(((lpeg.P(1) - '"') + lpeg.P'""' / '"')^0) * '"'  + lpeg.C(lpeg.P'{' * (lpeg.P(1) - lpeg.P'}') ^0 * lpeg.P'}') + lpeg.C(lpeg.P'[' * (lpeg.P(1) - lpeg.P']') ^0 * lpeg.P']') + lpeg.C((1 - lpeg.S',\n"')^0)
local _record = _field * (',' * _field)^0 * (lpeg.P'\n' + -1)

function csv2table.csv(s)
	local pat = lpeg.Ct(_record)
 	return lpeg.match(pat, s)
end

function csv2table.load(file)
	local fd = assert(io.open(file,"r"))
 	local content = fd:read("*a")
 	return csv2table.parse(content,file)
end

function csv2table.parse(csv,file)
	local lines = csv2table.split(csv,'\n')

	local headline = lines[1]

	local data = {}
	local headtable = csv2table.csv(headline)
	for col = 1,#headtable do
		local column = data[i]
		if column == nil then
			column = {}
			data[col] = column
		end
		local str = headtable[col]:gsub("\"","\\\""):gsub("\'","\\\""):gsub("[\r\n]"," ")
		table.insert(column,string.format("\"%s\"",str))
	end

	local total_col = #headtable
	for i = 2,#lines do
		local ct = csv2table.csv(lines[i])
		assert(ct ~= nil,string.format("%s,line:%d,content:[%s]",file,i,lines[i]))

		for col = 1,total_col do
			local column = data[col]
			if ct[col] == nil or ct[col] == '' then
				table.insert(column,"nil")
			else
				local number = tonumber(ct[col])
				if number then
					table.insert(column,number)
				else
					local str = ct[col]:gsub("\"","\\\""):gsub("\'","\\\""):gsub("[\r\n]"," ")
					table.insert(column,string.format("\"%s\"",str))
				end
			end
		end
	end

	local str = "{"
	for index,column in ipairs(data) do
		data[index] = table.concat(column,",")
		str = str..string.format("[%d] = { ",index)
		str = str..table.concat(column,",")
		str = str.."},"
	end
	str = str.."}"
	return str
end

return csv2table