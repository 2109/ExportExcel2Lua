local util = require "util"



local function parser(file,result,server,client)
	local key_field = {}

	--检查类型
	for name,sheet in pairs(result) do
		local valid_row = #sheet[1]
		for index,col in ipairs(sheet) do
			local type_list = {}
			for vt in string.gmatch(col[1], "([^@]+)@*") do
				table.insert(type_list,vt)
			end

			local vtype = type_list[1]

			local vtype_args = {}
			for i=2,#type_list do
				vtype_args[type_list[i]] = true
			end
			
			local field = col[3]
			if not field then
				error(string.format("sheet:%s 第%d列,缺少字段类型",name,index))
			end

			if vtype_args["key"] ~= nil then
				if key_field[name] ~= nil then
					error(string.format("sheet:%s 不能同时有两个字段为key",name))
				end
				key_field[name] = {field = field,index = index}
			end
			local unique = {}
			
			for i =4,valid_row do
				if col[i] == nil then
					if vtype_args["key"] ~= nil then
						error(string.format("sheet:%s,有key属性的字段:%s不能为空",name,field))
					end
					if vtype_args["default"] == nil then
						error(string.format("sheet:%s 第%d行,字段:%s不允许为空",name,i,field))
					end
				else
					local value = col[i]
					if vtype_args["unique"] or vtype_args["key"] then
						if unique[value] ~= nil then
							error(string.format("sheet:%s,字段:%s@%s不能重复",name,field,tostring(value)))
						end
						unique[value] = true
					end
	
					local ok,checker = pcall(require,string.format("type.%s",vtype))
					if not ok then
						error(string.format("sheet:%s,字段:%s,类型:%s,不存在",name,field,vtype))
					end
					local ok,result = pcall(checker,value)
					if not ok then
						error(string.format("sheet:%s,字段:%s,类型:%s,解析出错:%s",name,field,vtype,result))
					end
					col[i] = result
				end
			end
		end
	end

	local hold_table = {}
	--构造表
	for name,sheet in pairs(result) do
		local field_info = key_field[name]
		if not field_info then
			error(string.format("sheet:%s,不存在key字段",name))
		end

		local tbl = {}
		local key_index = {}
		for i=4,#sheet[field_info.index] do
			local value = sheet[field_info.index][i]
			tbl[value] = {}
			key_index[i] = value
		end

		for index,col in ipairs(sheet) do
			local field = col[3]
		
			for i=4,#col do
				local key_value = key_index[i]
				local line = tbl[key_value]
				line[field] = col[i]
			end
		end
		hold_table[name] = tbl
	end


	local ok,maker = pcall(require,string.format("maker.%s",file))
	if ok then
		hold_table = maker.make(hold_table)
	end
	local serialize = require "serialize"
	local content = serialize.pack_order(hold_table)
	if server ~= nil then
		local fd = io.open(string.format("%s/%s.lua",server,file) ,"w");  
		fd:write(content)  
		fd:close() 
		print(string.format("%s\\%s.lua done",server,file))
	end

	if client ~= nil then
		local fd = io.open(string.format("%s/%s.lua",client,file) ,"w");  
		fd:write(content)  
		fd:close() 
		print(string.format("%s\\%s.lua done",client,file))
	end
end

return parser