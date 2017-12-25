package.path = string.format("%s;%s",package.path,"./core/?.lua")
package.cpath = string.format("%s;%s",package.cpath,"./core/?.dll")

local util = require "util"
local serialize = require "serialize"
local parser = require "parser"

local client_path = io.read()
local server_path = io.read()
local name = io.read()
local input = io.read("*all")

local fd = io.open(string.format("tmp/%s.lua",name) ,"w");  
fd:write(input)  
fd:close() 

local tbl = serialize.unpack(input)
parser(name,serialize.unpack(input),server_path,client_path)