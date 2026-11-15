-- [yue]: examples/love2d/core.yue
local love = require("love") -- 1
-- import p from "yue"

local dump -- 5
dump = function(table, indent) -- 5
	if indent == nil then -- 5
		indent = "" -- 5
	end -- 5
	print("{") -- 6
	for k, v in pairs(table) do -- 7
		if #indent > 0 then -- 8
			io.write(indent) -- 9
		end -- 8
		io.write(k .. ": ") -- 10
		if type(v) == 'table' then -- 11
			print() -- 12
			dump(v, indent .. "    ") -- 13
		else -- 15
			print(v) -- 15
		end -- 11
	end -- 7
	return print("}") -- 16
end -- 5

local show -- 18
show = function(to_show, indent) -- 18
	if indent == nil then -- 18
		indent = "" -- 18
	end -- 18
	if to_show == nil then -- 19
		return "" -- 20
	end -- 19
	local ret = "{\n" -- 21
	for k, v in pairs(to_show) do -- 22
		if #indent > 0 then -- 23
			ret = ret .. indent -- 24
		end -- 23
		ret = ret .. (k .. ": ") -- 25
		if type(v) == 'table' then -- 26
			ret = ret .. "\n" -- 27
			ret = ret .. (show(v, indent .. "    ")) -- 28
		else -- 30
			ret = ret .. (tostring(v) .. "\n") -- 30
		end -- 26
	end -- 22
	ret = ret .. "}" -- 31
	if indent == "" then -- 32
		love.graphics.print(ret, 10, 10) -- 33
	end -- 32
	return ret -- 34
end -- 18

local Rectangle -- 36
do -- 36
	local _class_0 -- 36
	local _base_0 = { -- 36

		contains = function(self, point_x, point_y) -- 39
			return self.x <= point_x and point_x <= (self.x + self.width) and self.y <= point_y and point_y <= (self.y + self.height) -- 40
		end -- 39
	} -- 36
	if _base_0.__index == nil then -- 36
		_base_0.__index = _base_0 -- 36
	end -- 36
	_class_0 = setmetatable({ -- 36
		__init = function(self, x, y, width, height) -- 37
			self.x = x -- 37
			self.y = y -- 37
			self.width = width -- 37
			self.height = height -- 37
		end, -- 37
		__base = _base_0, -- 36
		__name = "Rectangle" -- 36
	}, { -- 36
		__index = _base_0, -- 36
		__call = function(cls, ...) -- 36
			local _self_0 = setmetatable({ }, _base_0) -- 36
			cls.__init(_self_0, ...) -- 36
			return _self_0 -- 36
		end -- 36
	}) -- 36
	_base_0.__class = _class_0 -- 36
	Rectangle = _class_0 -- 36
end -- 36

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 43
local rects = { -- 45
	Rectangle(10, 10, 750, 400) -- 45
} -- 44
local selected_index = 1 -- 47
local kb = { } -- 48

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = false -- 53

if hide_errors then -- 55
	love.errorhandler = function(msg) -- 56
		msg = tostring(msg) -- 57
		print(msg) -- 58
		LuaReload.Monitor() -- 59
		return love.graphics.print(msg, 10, 10) -- 60
	end -- 56
end -- 55

local reset_state -- 62
reset_state = function() -- 62
	if #rects ~= 0 then -- 63
		return -- 64
	end -- 63
	return table.insert(rects, Rectangle(10, 10, 750, 400)) -- 65
end -- 62

love.load = function() -- 67
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 68
end -- 67

local debug_text = "" -- 71
local names = { -- 72
	"jo", -- 72
	"ron", -- 72
	"harry" -- 72
} -- 72

-- macro debugLog = ()->
--     if show_logs
--         print() 
local split_rect_at -- 77
split_rect_at = function(index) -- 77
	local _with_0 = rects[index] -- 78
	if _with_0.width > _with_0.height then -- 79
		local width_before = _with_0.width -- 80
		_with_0.width = _with_0.width / 2 -- 81
		local half_width = _with_0.width -- 82
		table.insert(rects, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 83
	else -- 85
		local height_before = _with_0.height -- 85
		_with_0.height = _with_0.height / 2 -- 86
		local half_height = _with_0.height -- 87
		table.insert(rects, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 88
	end -- 79
	return _with_0 -- 78
end -- 77

love.keypressed = function(key) -- 92
	debug_text = "" -- 93
	if key == "e" then -- 94
		debug_text = debug_text .. "e was pressed" -- 95
	end -- 94
	if key == "r" then -- 96
		reset_state() -- 97
	end -- 96
	if ("q" == key or "escape" == key) then -- 98
		love.event.quit() -- 99
	end -- 98
	if key == 'a' then -- 100
		return love.event.quit() -- 101
	end -- 100
end -- 92

-- love.keyreleased = (key) ->
--     keys_pressed[key] = nil
--     just_pressed[key] = nil
--     print("released", key)
--     old_keys_pressed[key] = nil


--     msg = tostring(msg)
--     print(msg)
--     LuaReload.Monitor!
--     love.graphics.print(msg, 10, 10)

-- macro mark_key_state = (key)-> 
--     if love.keyboard.isDown(key)
--         kb[key] = love.timer.getTime!
--     else
--         kb[key] = never_pressed_time
--     return

local never_pressed_time = -100 -- 128
local _anon_func_0 = function(kb, key, never_pressed_time) -- 130
	local _exp_0 = kb[key] -- 130
	if _exp_0 ~= nil then -- 130
		return _exp_0 -- 130
	else -- 130
		return never_pressed_time -- 130
	end -- 130
end -- 130
local was_just_pressed -- 129
was_just_pressed = function(key) -- 129
	local was_down_before = (_anon_func_0(kb, key, never_pressed_time)) > 0 -- 130
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 132
		kb[key] = love.timer.getTime() -- 133
	else -- 135
		kb[key] = never_pressed_time -- 135
	end -- 132
	print(kb[key]) -- 136
	return love.keyboard.isDown(key) and not was_down_before -- 137
end -- 129

-- is_pressed_with_repeat_allowed = (key, repeat_time=1) ->
--     last_pressed_at = (kb[key] ?? never_pressed_time)
--     if love.keyboard.isDown(key)
--         if key not in kb
--             kb[key] = love.timer.getTime!
--     else
--         kb[key] = never_pressed_time
--     if last_pressed_at == never_pressed_time
--         return false
--     last_pressed_at > 0 or love.timer.getTime! - last_pressed_at >= repeat_time

love.update = function(dt) -- 150
	LuaReload.Monitor() -- 151
	reset_state() -- 152
	-- if love.keyboard.isDown "escape"
	if was_just_pressed("s") then -- 154
		print("just pressed s") -- 155
		split_rect_at(selected_index) -- 156
	end -- 154

	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 159
	-- dump(just_pressed)
end -- 150

love.draw = function() -- 163
	love.graphics.setFont(main_font) -- 164
	local tile_size = 100 -- 165
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 166
	-- print(mouse_pos_x, mouse_pos_y)
	for i, rect in ipairs(rects) do -- 168
		if i == selected_index then -- 169
			love.graphics.setColor(.8, .6, .7) -- 170
		else -- 172
			love.graphics.setColor(.3, .6, .7) -- 172
		end -- 169

		if rect:contains(mouse_pos_x, mouse_pos_y) then -- 174
			love.graphics.setColor(1, 1, 1) -- 175
		end -- 174

		love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 177
		love.graphics.setColor(0, 0, 0) -- 178
		love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 179
	end -- 168

	-- love.graphics.rectangle("fill", 10, 10, tile_size, tile_size)s
	return love.graphics.setColor(1, 1, 1) -- 183
	-- if is_pressed_with_repeat_allowed("d")
	--     print("registerd d")
	-- dump(board)
	-- if love.keyboard.isDown("f")
	--     love.graphics.print("cool", 32, 132)
	-- for i, name in ipairs names 
	--     love.graphics.print(i .. ": " .. name, 32, 132 + i * 30)

	-- love.graphics.setColor(0, 0, 0)
	-- show(rects)
	-- love.graphics.print(love.timer.getTime!)
	-- love.graphics.setColor 0.8, 0.8, 0.8
	-- major, minor, revision, codename = love.getVersion( )
	-- love.graphics.print("#{major}, #{minor}, revision, codename", 32, 32)
	-- love.graphics.print(text, 32, 32)
	-- love.graphics.print("#{mouse_pos_x}, #{mouse_pos_y}", mouse_pos_x, mouse_pos_y - 15)
	-- love.graphics.print(names[1, 3], mouse_pos_x, mouse_pos_y - 15)
end -- 163
