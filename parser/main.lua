local util = require "util"
local serialize = require "serialize"
local lpeg = require "lpeg"
local csv2table = require "csv2table"
local parser = require "parser"



local export_path = io.read()
local client_path = io.read()
local server_path = io.read()
local wb_name = io.read()
local wb_path = io.read()

-- print(wb_name,wb_path)
local name,postfix = wb_name:match("(%w+).(%w+)")

local result
if postfix == "csv" then
	result  = csv2table.load(wb_path.."/"..wb_name)
	result = string.format("{ \"%s\" = %s}",name,result)
else
	local cmd = string.format("python excel2table.py %s",wb_path.."/"..wb_name)
	local file = io.popen(cmd)
	result = file:read("*a")
	file:close()
end
parser(name,serialize.unpack(result),export_path,server_path,client_path)




