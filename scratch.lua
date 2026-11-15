-- [yue]: scratch.yue
local p -- 1
do -- 1
	local _obj_0 = require("yue") -- 1
	p = _obj_0.p -- 1
end -- 1

print("test") -- 3
local add_amount -- 4
add_amount = function(num, amount) -- 4
	if amount == nil then -- 4
		amount = 10 -- 4
	end -- 4
	return num + amount -- 4
end -- 4
print(add_amount(5, 1)) -- 5

local defaultdict -- 7
do -- 7
	local _class_0 -- 7
	local _base_0 = { -- 7
		__index = function(self, idx) -- 10
			if not (#self > 0 and (function() -- 11
				for _index_0 = 1, #self do -- 11
					if self[_index_0] == idx then -- 11
						return true -- 11
					end -- 11
				end -- 11
				return false -- 11
			end)()) then -- 11
				self[idx] = self.default_value -- 12
			end -- 11
			return self[idx] -- 13
		end -- 10
	} -- 7
	if _base_0.__index == nil then -- 7
		_base_0.__index = _base_0 -- 7
	end -- 7
	_class_0 = setmetatable({ -- 7
		__init = function(self, default_value) -- 8
			self.default_value = default_value -- 9
		end, -- 8
		__base = _base_0, -- 7
		__name = "defaultdict" -- 7
	}, { -- 7
		__index = _base_0, -- 7
		__call = function(cls, ...) -- 7
			local _self_0 = setmetatable({ }, _base_0) -- 7
			cls.__init(_self_0, ...) -- 7
			return _self_0 -- 7
		end -- 7
	}) -- 7
	_base_0.__class = _class_0 -- 7
	defaultdict = _class_0 -- 7
end -- 7

local counts = defaultdict(5) -- 15
local _update_0 = 12 -- 16
counts[_update_0] = counts[_update_0] + 8 -- 16
counts[16] = 3 -- 17
p(counts) -- 18

local obj = { -- 21
	hello = "world", -- 21
	day = "tuesday", -- 22
	length = 20 -- 23
} -- 20

p(obj) -- 26

local hello, the_day = obj.hello, obj.day -- 28
print(hello, the_day) -- 29

local day = obj.day -- 31
p(day) -- 32

local thing = { -- 34
	1, -- 34
	2 -- 34
} -- 34

local a, b = table.unpack(thing) -- 36
print(a, b) -- 37

local obj2 = { -- 41
	numbers = { -- 41
		1, -- 41
		2, -- 41
		3, -- 41
		4 -- 41
	}, -- 41
	properties = { -- 43
		color = "green", -- 43
		height = 13.5 -- 44
	} -- 42
} -- 40

local first, second, color2 = obj2.numbers[1], obj2.numbers[2], obj2.properties.color -- 48
print(first, second, color2) -- 49

local countdown -- 51
countdown = function(n) -- 51
	return function() -- 52
		n = n - 1 -- 53
		if n > 0 then -- 54
			return n -- 55
		end -- 54
	end -- 52
end -- 51

for x in countdown(10) do -- 57
	print(x) -- 58
end -- 57




local item = 4 -- 70


return print("end") -- 75
