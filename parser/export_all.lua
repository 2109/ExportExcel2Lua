local util = require "util"
local serialize = require "serialize"
local parser = require "parser"

local excel_path = io.read()
local export_path = io.read()
local client_path = io.read()
local server_path = io.read()

print(excel_path,export_path,client_path,server_path)
