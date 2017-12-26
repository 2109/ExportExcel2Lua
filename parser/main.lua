package.path = string.format("%s;%s",package.path,"./core/?.lua")
package.cpath = string.format("%s;%s",package.cpath,"./core/?.dll")
local util = require "util"
local serialize = require "serialize"
local lpeg = require "lpeg"
local csv2table = require "csv2table"
local parser = require "parser"

local input = ...

local iscsv = false
local fullfile = string.format("./excel/%s.xls",input)
local test = io.open(fullfile,"r")
if not test then
	fullfile = string.format("./excel/%s.xlsx",input)
	test = io.open(fullfile,"r")
	if not test then
		fullfile = string.format("./excel/%s.csv",input)
		test = io.open(fullfile,"r")
		if test then
			iscsv = true
		else
			error(string.format("no such file:%s",input))
		end
	else
		test:close()
	end
else
	test:close()
end

local result
if not iscsv then
	local cmd = string.format("python ./core/excel2table.py %s",fullfile)
	local file = io.popen(cmd)
	result = file:read("*a")
	file:close()
else
	result  = csv2table.load(fullfile)
	result = string.format("{ \"%s\" = %s}",input,result)
end
parser(input,serialize.unpack(result))




