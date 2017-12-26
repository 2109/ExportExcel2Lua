local util = require "util"
local serialize = require "serialize"
local parser = require "parser"

local export_path = io.read()
local client_path = io.read()
local server_path = io.read()
local name = io.read()
local input = io.read("*all")

local fd = assert(io.open(string.format("tmp/%s.lua",name) ,"w"))
fd:write(input)  
fd:close() 

local tbl = serialize.unpack(input)
parser(name,serialize.unpack(input),export_path,server_path,client_path)