--
--	Jackson Munsell
--	07/25/18
--	tableutil.lua
--
--	Table utility module
--

-- Module
local tableutil = {}

-- Get random
function tableutil.getrandom(array)
	if not array or type(array) ~= 'table' then
		error('Invalid argument passed to tableutil.getrandom; table expected, got ' .. type(array))
	end
	if #array == 0 then
		return nil
	end
	return array[math.random(1, #array)]
end

-- Get key from value
function tableutil.getkey(tb, val)
	for k, v in pairs(tb) do
		if v == val then return k end
	end
end

-- Shallow copy array
function tableutil.shallow_copy(tb)
	local n = {}
	for k, v in pairs(tb) do
		n[k] = v
	end
	return n
end

-- Deeply merge two tables into one new table
function tableutil.merge_into_new(a, b)
	local tb = {}
	local function copy(src, dest)
		for k, v in pairs(src) do
			if type(v) == 'table' then
				if not dest[k] then dest[k] = {} end
				copy(v, dest[k])
			else
				dest[k] = v
			end
		end
	end
	copy(a, tb)
	copy(b, tb)
	return tb
end

-- return util
return tableutil
