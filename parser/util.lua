


local _M = setmetatable({},{__index = core})

local function get_type_first_print( t )
    local str = type(t)
    return string.upper(string.sub(str, 1, 1))..":"
end

function _M.dump(t, prefix, indent_input,print)
    local indent = indent_input
    if indent_input == nil then
        indent = 1
    end

    if print == nil then
        print = _G["print"]
    end

    local p = nil

    local formatting = string.rep("    ", indent)
    if prefix ~= nil then
        formatting = prefix .. formatting
    end

    if t == nil then
        print(formatting.." nil")
        return
    end

    if type(t) ~= "table" then
        print(formatting..get_type_first_print(t)..tostring(t))
        return
    end

    local output_count = 0
    for k,v in pairs(t) do
        local str_k = get_type_first_print(k)
        if type(v) == "table" then

            print(formatting..str_k..tostring(k).." -> ")

            _M.dump(v, prefix, indent + 1,print)
        else
            print(formatting..str_k..tostring(k).." -> ".. get_type_first_print(v)..tostring(v))
        end
        output_count = output_count + 1
    end

    if output_count == 0 then
        print(formatting.." {}")
    end
end

--保存无环table，n为空格数可为2
function _M.serialize(o, n)
    if type(o) == "number" then
        io.write(o)
    elseif type(o) == "boolean" then
        io.write((o and "true") or "false")
    elseif type(o) == "string" then
        io.write(string.format("%q", o))
    elseif type(o) == "table" then
        io.write("{\n")
        for k,v in pairs(o) do
                io.write(string.rep("   ", n) .. "[")
                _M.serialize(k, n + 1)
                io.write("] = ")
                _M.serialize(v, n + 1)
                io.write(",\n")
        end
        io.write(string.rep("   ", n - 1) .. "}")
    else
        io.write("cannot serialize a " .. type(o) .. "\n")
    end
end


local function baseText(o)
    if type(o) == "number" then
        return 0, tostring(o)
    elseif type(o) == "boolean" then
        return 0, (o and "true") or "false"
    elseif type(o) == "string" then
        return 0, string.format("%q", o)
    elseif type(o) == "function" then
        return 0, tostring(o)
    elseif type(o) == "userdata" then
        return 0, tostring(o)
    elseif type(o) == "table" then
        return 1, tostring(o)
    else
        return -1, "unknow"
    end
end


function _M.text(obj, name, record, layer, layerMax)
    layer = layer or 1
    layerMax = layerMax or 10
    record = record or {}       --初始化
    name = name or tostring(obj)
    local ret, str = baseText(obj)
    if ret == 0 then            --基础类型
        io.write(name, " = ", str, "\n")
    elseif ret == 1 then        --table类型
        if record[str] then         --已经存在的table，直接保存记录名称，避免死循环
            io.write(name, " = ", record[str], "\n")
        else
            record[str] = name
            io.write(name, " = {}\n")
            for k,v in pairs(obj) do
                local ret_sub, str_sub = baseText(k)
                if record[str_sub] ~= nil then
                    str_sub = record[str_sub]
                end
                local name_sub
                if type(k) == "number" then
                    name_sub = string.format("%s[%s]", name, str_sub)
                else
                    name_sub = string.format("%s{%s}", name, str_sub)
                end
                _M.text(v, name_sub, record, layer + 1, layerMax)
            end
        end
    else                        --未知类型
        io.write(name, " = unsupport:" .. type(obj) .. "\n")
    end
end

local function get_suffix(filename)
    return filename:match(".+%.(%w+)$")
end

function _M.find_dir_files(r_table,path,suffix,is_path_name,recursive)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file

            local attr = lfs.attributes (f)
            if type(attr) == "table" and attr.mode == "directory" and recursive then
                _M.find_dir_files(r_table, f, suffix, is_path_name, recursive)
            else
                local target = file
                if is_path_name then target = f end

                if suffix == nil or suffix == "" or suffix == get_suffix(f) then
                    table.insert(r_table, target)
                end
            end
        end
    end
end

function _M.spilt(str,delimiter)
    if str == nil or str == "" or delimiter == nil then
        return false,"error arg1 or arg2"
    end

    local result = {}
    local pattern = string.format("(.-)%s",delimiter)
    local hole = string.format("%s%s",str,delimiter)
    for match in hole:gmatch(pattern) do
        table.insert(result,match)
    end

    return result
end



return _M