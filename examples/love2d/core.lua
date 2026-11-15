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
		end, -- 39

		get_center = function(self, offset_x, offset_y) -- 42
			if offset_x == nil then -- 42
				offset_x = 0 -- 42
			end -- 42
			if offset_y == nil then -- 42
				offset_y = 0 -- 42
			end -- 42
			return self.x + (self.width / 2) + offset_x, self.y + (self.height / 2) + offset_y -- 43
		end, -- 42

		get_top_left = function(self) -- 45
			return self.x, self.y -- 46
		end, -- 45

		get_bottom_right = function(self) -- 48
			return self.x + self.width, self.y + self.height -- 49
		end -- 48
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

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 52
local rects = { -- 54
	Rectangle(10, 10, 750, 400) -- 54
} -- 53

local squish_sounds -- 57
do -- 57
	local _accum_0 = { } -- 57
	local _len_0 = 1 -- 57
	for i = 1, 3 do -- 57
		_accum_0[_len_0] = love.audio.newSource("sounds/squish" .. tostring(i) .. ".wav", "static") -- 57
		_len_0 = _len_0 + 1 -- 57
	end -- 57
	squish_sounds = _accum_0 -- 57
end -- 57
local selected_index = 1 -- 58
local kb = { } -- 59
local SMALLEST_SIZE_ALLOWED = 20 -- 60

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = true -- 65

if hide_errors then -- 67
	love.errorhandler = function(msg) -- 68
		msg = tostring(msg) -- 69
		print(msg) -- 70
		LuaReload.Monitor() -- 71
		return love.graphics.print(msg, 10, 10) -- 72
	end -- 68
end -- 67

local reset_state -- 74
reset_state = function() -- 74
	rects = { } -- 75
	return table.insert(rects, Rectangle(10, 10, 750, 400)) -- 76
end -- 74

love.load = function() -- 78
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 79
end -- 78

-- macro debugLog = ()->
--     if show_logs
--         print() 

local on_split_success -- 85
on_split_success = function() -- 85
	if love.keyboard.isDown("lshift") then -- 86
		selected_index = #rects -- 87
	end -- 86
	return squish_sounds[math.random(#squish_sounds)]:play() -- 88
end -- 85

local split_rect_at -- 91
split_rect_at = function(index) -- 91
	local _with_0 = rects[index] -- 92
	if _with_0.width > _with_0.height then -- 93
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 94
			local width_before = _with_0.width -- 95
			_with_0.width = _with_0.width / 2 -- 96
			local half_width = _with_0.width -- 97
			table.insert(rects, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 98
			on_split_success() -- 99
		end -- 94
		return -- 100
	else -- 103
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 103
			print(_with_0.height) -- 104
			local height_before = _with_0.height -- 105
			_with_0.height = _with_0.height / 2 -- 106
			local half_height = _with_0.height -- 107
			table.insert(rects, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 108
			on_split_success() -- 109
		end -- 103
		return -- 110
	end -- 93
	return _with_0 -- 92
end -- 91

local show_shadow_split_spot -- 117
show_shadow_split_spot = function(index) -- 117
	local _with_0 = rects[index] -- 118
	if _with_0.width > _with_0.height then -- 119
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 120
			local line_width = _with_0.width * .05 -- 121
			local half_line_width = line_width / 2 -- 122
			-- vertical line
			local width_before = _with_0.width -- 124
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.height * .1) -- 125
			local half_rect_width = _with_0.width / 2 -- 126
			love.graphics.rectangle("fill", _with_0.x + half_rect_width - half_line_width, _with_0.y + moving_offset, line_width, _with_0.height + moving_offset) -- 127
		end -- 120
	else -- 131
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 131
			local line_width = _with_0.height * .05 -- 132
			local half_line_width = line_width / 2 -- 133
			-- horizontal line
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.width * .1) -- 135
			local height_before = _with_0.height -- 136
			local half_height = _with_0.height / 2 -- 137
			love.graphics.rectangle("fill", _with_0.x + moving_offset, _with_0.y + half_height - half_line_width, _with_0.width + moving_offset, line_width) -- 138
		end -- 131
	end -- 119
	return _with_0 -- 118
end -- 117

love.keypressed = function(key) -- 141
	if key == "r" then -- 142
		reset_state() -- 143
	end -- 142
	if ("q" == key or "escape" == key) then -- 144
		love.event.quit() -- 145
	end -- 144
	if key == 'a' then -- 146
		return love.event.quit() -- 147
	end -- 146
end -- 141

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

local never_pressed_time = -100 -- 174
local _anon_func_0 = function(kb, key, never_pressed_time) -- 176
	local _exp_0 = kb[key] -- 176
	if _exp_0 ~= nil then -- 176
		return _exp_0 -- 176
	else -- 176
		return never_pressed_time -- 176
	end -- 176
end -- 176
local was_just_pressed -- 175
was_just_pressed = function(key) -- 175
	local was_down_before = (_anon_func_0(kb, key, never_pressed_time)) > 0 -- 176
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 178
		kb[key] = love.timer.getTime() -- 179
	else -- 181
		kb[key] = never_pressed_time -- 181
	end -- 178
	return love.keyboard.isDown(key) and not was_down_before -- 182
end -- 175

local repeat_kb = { } -- 184
local is_pressed_with_repeat_allowed -- 185
is_pressed_with_repeat_allowed = function(key, repeat_time) -- 185
	if repeat_time == nil then -- 185
		repeat_time = .3 -- 185
	end -- 185
	if not love.keyboard.isDown(key) then -- 186
		repeat_kb[key] = nil -- 187
		return false -- 188
	end -- 186
	if repeat_kb[key] == nil or love.timer.getTime() - repeat_kb[key] >= repeat_time then -- 189
		repeat_kb[key] = love.timer.getTime() -- 190
		return true -- 191
	end -- 189
	return false -- 192
end -- 185

local bring_focus_to_neighbors -- 194
bring_focus_to_neighbors = function() -- 194
	local x_offset = 0 -- 195
	local y_offset = 0 -- 196
	if is_pressed_with_repeat_allowed("left") then -- 197
		print("left") -- 198
		x_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 199
	end -- 197
	if is_pressed_with_repeat_allowed("right") then -- 200
		print("right") -- 201
		x_offset = SMALLEST_SIZE_ALLOWED / 2 -- 202
	end -- 200

	if is_pressed_with_repeat_allowed("up") then -- 204
		print("up") -- 205
		y_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 206
	end -- 204
	if is_pressed_with_repeat_allowed("down") then -- 207
		print("down") -- 208
		y_offset = SMALLEST_SIZE_ALLOWED / 2 -- 209
	end -- 207

	-- print(x_offset, y_offset)
	if x_offset == 0 and y_offset == 0 then -- 212
		return -- 213
	end -- 212

	print(rects[selected_index]:get_center()) -- 215
	local cur_x, cur_y = rects[selected_index]:get_center(-SMALLEST_SIZE_ALLOWED / 2, -SMALLEST_SIZE_ALLOWED / 2) -- 216
	if love.keyboard.isDown("lshift") then -- 217
		cur_x, cur_y = rects[selected_index]:get_center(SMALLEST_SIZE_ALLOWED / 2, SMALLEST_SIZE_ALLOWED / 2) -- 218
	end -- 217
	print(cur_x, cur_y) -- 219

	local screen_size_x = 800 -- 222
	local screen_size_y = 450 -- 223
	while -10 <= cur_x and cur_x <= screen_size_x and -10 <= cur_y and cur_y <= screen_size_y do -- 224
		cur_x = cur_x + x_offset -- 225
		cur_y = cur_y + y_offset -- 226
		print(cur_y, cur_x) -- 227
		for i, rect in ipairs(rects) do -- 228
			local _continue_0 = false -- 229
			repeat -- 229
				if rect == rects[selected_index] then -- 229
					_continue_0 = true -- 230
					break -- 230
				end -- 229
				if rect:contains(cur_x, cur_y) then -- 231
					selected_index = i -- 232
					return -- 233
				end -- 231
				_continue_0 = true -- 229
			until true -- 229
			if not _continue_0 then -- 229
				break -- 229
			end -- 229
		end -- 228
	end -- 224
end -- 194

local did_slice_action -- 235
did_slice_action = function(repeat_time) -- 235
	if repeat_time == nil then -- 235
		repeat_time = .2 -- 235
	end -- 235
	return is_pressed_with_repeat_allowed("s", repeat_time) or is_pressed_with_repeat_allowed("space", repeat_time) -- 236
end -- 235

love.update = function(dt) -- 238
	if love.window.hasFocus() then -- 239
		LuaReload.Monitor() -- 240
	end -- 239
	-- if love.keyboard.isDown "escape"
	if did_slice_action() then -- 242
		print("just pressed s") -- 243
		split_rect_at(selected_index) -- 244
	end -- 242
	bring_focus_to_neighbors() -- 245

	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 248
	-- dump(just_pressed)
end -- 238

love.draw = function() -- 252
	love.graphics.setFont(main_font) -- 253
	local tile_size = 100 -- 254
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 255
	-- print(mouse_pos_x, mouse_pos_y)
	for i, rect in ipairs(rects) do -- 257
		if i == selected_index then -- 258
			love.graphics.setColor(.8, .6, .7) -- 259
		else -- 261
			love.graphics.setColor(.3, .6, .7) -- 261
		end -- 258

		-- if rect\contains(mouse_pos_x, mouse_pos_y)
		--     love.graphics.setColor(1, 1, 1)

		love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 266
		love.graphics.setColor(0, 0, 0) -- 267
		love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 268
	end -- 257

	show_shadow_split_spot(selected_index) -- 270

	-- love.graphics.rectangle("fill", 10, 10, tile_size, tile_size)s
	love.graphics.setColor(1, 1, 1) -- 273
	if is_pressed_with_repeat_allowed("d", .2) then -- 274
		return print("registerd d") -- 275
	end -- 274
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
end -- 252
