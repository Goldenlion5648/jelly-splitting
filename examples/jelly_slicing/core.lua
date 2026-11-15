-- [yue]: examples/jelly_slicing/core.yue
local love = require("love") -- 1
-- import p from "yue"

-- macro is_reloading = (debugging) ->
--   global debugMode = debugging == "true"
--   ""
-- macro is_reloading = (val) -> 




local dump -- 19
dump = function(table, indent) -- 19
	if indent == nil then -- 19
		indent = "" -- 19
	end -- 19
	print("{") -- 20
	for k, v in pairs(table) do -- 21
		if #indent > 0 then -- 22
			io.write(indent) -- 23
		end -- 22
		io.write(k .. ": ") -- 24
		if type(v) == 'table' then -- 25
			print() -- 26
			dump(v, indent .. "    ") -- 27
		else -- 29
			print(v) -- 29
		end -- 25
	end -- 21
	return print("}") -- 30
end -- 19

local show -- 32
show = function(to_show, indent) -- 32
	if indent == nil then -- 32
		indent = "" -- 32
	end -- 32
	if to_show == nil then -- 33
		return "" -- 34
	end -- 33
	local ret = "{\n" -- 35
	for k, v in pairs(to_show) do -- 36
		if #indent > 0 then -- 37
			ret = ret .. indent -- 38
		end -- 37
		ret = ret .. (k .. ": ") -- 39
		if type(v) == 'table' then -- 40
			ret = ret .. "\n" -- 41
			ret = ret .. (show(v, indent .. "    ")) -- 42
		else -- 44
			ret = ret .. (tostring(v) .. "\n") -- 44
		end -- 40
	end -- 36
	ret = ret .. "}" -- 45
	if indent == "" then -- 46
		love.graphics.print(ret, 10, 10) -- 47
	end -- 46
	return ret -- 48
end -- 32

local Rectangle -- 50
do -- 50
	local _class_0 -- 50
	local _base_0 = { -- 50

		contains = function(self, point_x, point_y) -- 54
			return self.x <= point_x and point_x <= (self.x + self.width) and self.y <= point_y and point_y <= (self.y + self.height) -- 55
		end, -- 54

		get_center = function(self, offset_x, offset_y) -- 57
			if offset_x == nil then -- 57
				offset_x = 0 -- 57
			end -- 57
			if offset_y == nil then -- 57
				offset_y = 0 -- 57
			end -- 57
			return self.x + (self.width / 2) + offset_x, self.y + (self.height / 2) + offset_y -- 58
		end, -- 57

		get_top_left = function(self) -- 60
			return self.x, self.y -- 61
		end, -- 60

		get_bottom_right = function(self) -- 63
			return self.x + self.width, self.y + self.height -- 64
		end, -- 63

		get_hash = function(self) -- 66
			return self.x * 1000000 + self.width * 1000 + self.y * 100 + self.height -- 67
		end -- 66
	} -- 50
	if _base_0.__index == nil then -- 50
		_base_0.__index = _base_0 -- 50
	end -- 50
	_class_0 = setmetatable({ -- 50
		__init = function(self, x, y, width, height) -- 51
			self.x = x -- 51
			self.y = y -- 51
			self.width = width -- 51
			self.height = height -- 51
			self.age = 0 -- 52
		end, -- 51
		__base = _base_0, -- 50
		__name = "Rectangle" -- 50
	}, { -- 50
		__index = _base_0, -- 50
		__call = function(cls, ...) -- 50
			local _self_0 = setmetatable({ }, _base_0) -- 50
			cls.__init(_self_0, ...) -- 50
			return _self_0 -- 50
		end -- 50
	}) -- 50
	_base_0.__class = _class_0 -- 50
	Rectangle = _class_0 -- 50
end -- 50

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 70
local rects = { -- 72
	Rectangle(10, 10, 750, 400) -- 72
} -- 71

local squish_sounds -- 75
do -- 75
	local _accum_0 = { } -- 75
	local _len_0 = 1 -- 75
	for i = 1, 3 do -- 75
		_accum_0[_len_0] = love.audio.newSource("sounds/squish" .. tostring(i) .. ".wav", "static") -- 75
		_len_0 = _len_0 + 1 -- 75
	end -- 75
	squish_sounds = _accum_0 -- 75
end -- 75
local deny_sound = love.audio.newSource("sounds/deny.wav", "static") -- 76
local selected_index = 1 -- 77
local kb = { } -- 78
local SMALLEST_SIZE_ALLOWED = 20 -- 79

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = true -- 84

if hide_errors then -- 86
	love.errorhandler = function(msg) -- 87
		msg = tostring(msg) -- 88
		print(msg) -- 89
		do -- 90
			LuaReload.Monitor() -- 90
		end -- 90
		return love.graphics.print(msg, 10, 10) -- 91
	end -- 87
end -- 86

local reset_state -- 93
reset_state = function() -- 93
	rects = { } -- 94
	return table.insert(rects, Rectangle(10, 10, 750, 400)) -- 95
end -- 93

love.load = function() -- 97
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 98
end -- 97

-- macro debugLog = ()->
--     if show_logs
--         print() 

local on_split_success -- 106
on_split_success = function() -- 106
	if love.keyboard.isDown("lshift") then -- 107
		selected_index = #rects -- 108
	end -- 107
	return squish_sounds[math.random(#squish_sounds)]:play() -- 109
end -- 106

local split_rect_at -- 112
split_rect_at = function(index) -- 112
	do -- 113
		local _with_0 = rects[index] -- 113
		if _with_0.width > _with_0.height then -- 114
			if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 115
				local width_before = _with_0.width -- 116
				_with_0.width = _with_0.width / 2 -- 117
				local half_width = _with_0.width -- 118
				_with_0.age = 0 -- 119
				table.insert(rects, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 120
				on_split_success() -- 121
				return -- 122
			end -- 115
		else -- 125
			if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 125
				print(_with_0.height) -- 126
				local height_before = _with_0.height -- 127
				_with_0.height = _with_0.height / 2 -- 128
				local half_height = _with_0.height -- 129
				_with_0.age = 0 -- 130
				table.insert(rects, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 131
				on_split_success() -- 132
				return -- 133
			end -- 125
		end -- 114
	end -- 113
	-- deny_sound
	return deny_sound:play() -- 135
end -- 112

local show_shadow_split_spot -- 137
show_shadow_split_spot = function(index) -- 137
	local _with_0 = rects[index] -- 138
	if _with_0.width > _with_0.height then -- 139
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 140
			local line_width = _with_0.width * .05 -- 141
			local half_line_width = line_width / 2 -- 142
			-- vertical line
			local width_before = _with_0.width -- 144
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.height * .1) -- 145
			local half_rect_width = _with_0.width / 2 -- 146
			love.graphics.rectangle("fill", _with_0.x + half_rect_width - half_line_width, _with_0.y + moving_offset, line_width, _with_0.height) -- 147
		end -- 140
	else -- 151
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 151
			local line_width = _with_0.height * .05 -- 152
			local half_line_width = line_width / 2 -- 153
			-- horizontal line
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.width * .1) -- 155
			local height_before = _with_0.height -- 156
			local half_height = _with_0.height / 2 -- 157
			love.graphics.rectangle("fill", _with_0.x + moving_offset, _with_0.y + half_height - half_line_width, _with_0.width, line_width) -- 158
		end -- 151
	end -- 139
	return _with_0 -- 138
end -- 137

love.keypressed = function(key) -- 161
	if key == "r" then -- 162
		reset_state() -- 163
	end -- 162
	if ("q" == key or "escape" == key) then -- 164
		love.event.quit() -- 165
	end -- 164
	if key == 'a' then -- 166
		return love.event.quit() -- 167
	end -- 166
end -- 161

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

local never_pressed_time = -100 -- 194
local _anon_func_0 = function(kb, key, never_pressed_time) -- 196
	local _exp_0 = kb[key] -- 196
	if _exp_0 ~= nil then -- 196
		return _exp_0 -- 196
	else -- 196
		return never_pressed_time -- 196
	end -- 196
end -- 196
local was_just_pressed -- 195
was_just_pressed = function(key) -- 195
	local was_down_before = (_anon_func_0(kb, key, never_pressed_time)) > 0 -- 196
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 198
		kb[key] = love.timer.getTime() -- 199
	else -- 201
		kb[key] = never_pressed_time -- 201
	end -- 198
	return love.keyboard.isDown(key) and not was_down_before -- 202
end -- 195

local repeat_kb = { } -- 204
local is_pressed_with_repeat_allowed -- 205
is_pressed_with_repeat_allowed = function(key, repeat_time) -- 205
	if repeat_time == nil then -- 205
		repeat_time = .3 -- 205
	end -- 205
	if not love.keyboard.isDown(key) then -- 206
		repeat_kb[key] = nil -- 207
		return false -- 208
	end -- 206
	if repeat_kb[key] == nil or love.timer.getTime() - repeat_kb[key] >= repeat_time then -- 209
		repeat_kb[key] = love.timer.getTime() -- 210
		return true -- 211
	end -- 209
	return false -- 212
end -- 205

local bring_focus_to_neighbors -- 214
bring_focus_to_neighbors = function() -- 214
	local x_offset = 0 -- 215
	local y_offset = 0 -- 216
	if is_pressed_with_repeat_allowed("left") then -- 217
		print("left") -- 218
		x_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 219
	end -- 217
	if is_pressed_with_repeat_allowed("right") then -- 220
		print("right") -- 221
		x_offset = SMALLEST_SIZE_ALLOWED / 2 -- 222
	end -- 220

	if is_pressed_with_repeat_allowed("up") then -- 224
		print("up") -- 225
		y_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 226
	end -- 224
	if is_pressed_with_repeat_allowed("down") then -- 227
		print("down") -- 228
		y_offset = SMALLEST_SIZE_ALLOWED / 2 -- 229
	end -- 227

	-- print(x_offset, y_offset)
	if x_offset == 0 and y_offset == 0 then -- 232
		return -- 233
	end -- 232

	-- print(rects[selected_index]\get_center())
	local cur_x, cur_y = rects[selected_index]:get_center(-SMALLEST_SIZE_ALLOWED / 2, -SMALLEST_SIZE_ALLOWED / 2) -- 236
	if love.keyboard.isDown("lshift") then -- 237
		cur_x, cur_y = rects[selected_index]:get_center(SMALLEST_SIZE_ALLOWED / 2, SMALLEST_SIZE_ALLOWED / 2) -- 238
	end -- 237
	-- print(cur_x, cur_y)

	local screen_size_x = 800 -- 242
	local screen_size_y = 450 -- 243
	while -10 <= cur_x and cur_x <= screen_size_x and -10 <= cur_y and cur_y <= screen_size_y do -- 244
		cur_x = cur_x + x_offset -- 245
		cur_y = cur_y + y_offset -- 246
		-- print(cur_y, cur_x)
		for i, rect in ipairs(rects) do -- 248
			local _continue_0 = false -- 249
			repeat -- 249
				if rect == rects[selected_index] then -- 249
					_continue_0 = true -- 250
					break -- 250
				end -- 249
				if rect:contains(cur_x, cur_y) then -- 251
					selected_index = i -- 252
					return -- 253
				end -- 251
				_continue_0 = true -- 249
			until true -- 249
			if not _continue_0 then -- 249
				break -- 249
			end -- 249
		end -- 248
	end -- 244
end -- 214

local did_slice_action -- 255
did_slice_action = function(repeat_time) -- 255
	if repeat_time == nil then -- 255
		repeat_time = .2 -- 255
	end -- 255
	return is_pressed_with_repeat_allowed("s", repeat_time) or is_pressed_with_repeat_allowed("space", repeat_time) or is_pressed_with_repeat_allowed("return", repeat_time) -- 256
end -- 255

love.update = function(dt) -- 259
	do -- 260
		LuaReload.Monitor() -- 260
	end -- 260
	if love.window.hasFocus() then -- 261
		do -- 262
			LuaReload.Monitor() -- 262
		end -- 262
	end -- 261
	-- if love.keyboard.isDown "escape"
	if did_slice_action() then -- 264
		print("just pressed s") -- 265
		split_rect_at(selected_index) -- 266
	end -- 264
	bring_focus_to_neighbors() -- 267

	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 270
	-- dump(just_pressed)
end -- 259
local pingpong -- 272
pingpong = function(value, lower, upper) -- 272
	local dist = (upper - lower) -- 273
	if math.floor(value / dist) % 2 == 1 then -- 274
		local amount_over = value % dist -- 275
		return upper - amount_over -- 276
	end -- 274
	return (value % dist) + lower -- 277
end -- 272

love.draw = function() -- 280
	love.graphics.setFont(main_font) -- 281
	local tile_size = 100 -- 282
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 283
	-- print(mouse_pos_x, mouse_pos_y)
	for i, rect in ipairs(rects) do -- 285
		if i == selected_index then -- 286
			love.graphics.setColor(.8, .6, .1) -- 287
		else -- 289
			love.graphics.setColor(.3, .6, .7) -- 289
		end -- 286

		rect.age = rect.age + 1 -- 291

		-- if rect\contains(mouse_pos_x, mouse_pos_y)
		--     love.graphics.setColor(1, 1, 1)

		love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 296
		love.graphics.setColor(0, 0, 0) -- 297
		love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 298
		local eye_dist_from_center_x = rect.width / 5.0 -- 299
		local eye_dist_from_center_y = rect.height / 8.0 -- 300
		local center_x, center_y = rect:get_center() -- 301
		local x_radius = rect.width / 16.0 -- 302
		local y_radius = rect.width / 16.0 -- 303
		math.randomseed(rect:get_hash()) -- 304
		local eye_shake_time = 60 -- 305
		local eye_offset = 0 -- 306
		if rect.age < eye_shake_time then -- 307
			eye_offset = ((eye_shake_time - rect.age) ^ (1.6 - rect.age / eye_shake_time)) / 10 -- 308
		end -- 307
		love.graphics.ellipse("fill", center_x + eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y + eye_offset, x_radius, y_radius) -- 309
		love.graphics.ellipse("fill", center_x - eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y - eye_offset, x_radius, y_radius) -- 310
	end -- 285

	show_shadow_split_spot(selected_index) -- 312

	-- love.graphics.rectangle("fill", 10, 10, tile_size, tile_size)s
	love.graphics.setColor(1, 1, 1) -- 315
	if is_pressed_with_repeat_allowed("d", .2) then -- 316
		return print("registerd d") -- 317
	end -- 316
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
end -- 280
