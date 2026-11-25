-- [yue]: src/jelly_slicing/core.yue
local love = require("love") -- 1
-- import "lua_reload" as LuaReload
-- import p from "yue"

-- macro is_reloading = (debugging) ->
--   global debugMode = debugging == "true"
--   ""
-- macro is_reloading = (val) -> 




local dump -- 20
dump = function(cur_table, indent) -- 20
	if indent == nil then -- 20
		indent = "" -- 20
	end -- 20
	print(indent .. "{") -- 21
	if not cur_table then -- 22
		return -- 23
	end -- 22
	for k, v in pairs(cur_table) do -- 24
		if #indent > 0 then -- 25
			io.write(indent) -- 26
		end -- 25
		io.write(k .. ": ") -- 27
		if type(v) == 'table' then -- 28
			print() -- 29
			dump(v, indent .. "    ") -- 30
		else -- 32
			print(v) -- 32
		end -- 28
	end -- 24
	return print(indent .. "}") -- 33
end -- 20

local show -- 35
show = function(to_show, indent) -- 35
	if indent == nil then -- 35
		indent = "" -- 35
	end -- 35
	if to_show == nil then -- 36
		return "" -- 37
	end -- 36
	local ret = "{\n" -- 38
	for k, v in pairs(to_show) do -- 39
		if #indent > 0 then -- 40
			ret = ret .. indent -- 41
		end -- 40
		ret = ret .. (k .. ": ") -- 42
		if type(v) == 'table' then -- 43
			ret = ret .. "\n" -- 44
			ret = ret .. (show(v, indent .. "    ")) -- 45
		else -- 47
			ret = ret .. (tostring(v) .. "\n") -- 47
		end -- 43
	end -- 39
	ret = ret .. "}" -- 48
	if indent == "" then -- 49
		love.graphics.print(ret, 10, 10) -- 50
	end -- 49
	return ret -- 51
end -- 35

local _anon_func_0 = function(self, should_transfer_age) -- 88
	if should_transfer_age then -- 88
		return self.age -- 88
	else -- 88
		return 0 -- 88
	end -- 88
end -- 88
local Rectangle -- 53
do -- 53
	local _class_0 -- 53
	local _base_0 = { -- 53

		contains = function(self, point_x, point_y) -- 59
			return self.x <= point_x and point_x <= (self.x + self.width) and self.y <= point_y and point_y <= (self.y + self.height) -- 60
		end, -- 59

		get_center = function(self, offset_x, offset_y) -- 62
			if offset_x == nil then -- 62
				offset_x = 0 -- 62
			end -- 62
			if offset_y == nil then -- 62
				offset_y = 0 -- 62
			end -- 62
			return self.x + (self.width / 2) + offset_x, self.y + (self.height / 2) + offset_y -- 63
		end, -- 62

		get_center_as_table = function(self, offset_x, offset_y) -- 65
			if offset_x == nil then -- 65
				offset_x = 0 -- 65
			end -- 65
			if offset_y == nil then -- 65
				offset_y = 0 -- 65
			end -- 65
			return { -- 67
				x = self.x + (self.width / 2) + offset_x, -- 67
				y = self.y + (self.height / 2) + offset_y -- 68
			} -- 66
		end, -- 65

		get_top_left = function(self) -- 70
			return self.x, self.y -- 71
		end, -- 70

		get_bottom_right = function(self) -- 73
			return self.x + self.width, self.y + self.height -- 74
		end, -- 73

		get_hash = function(self) -- 76
			return self.x * 1000000 + self.width * 1000 + self.y * 100 + self.height -- 77
		end, -- 76

		get_clone = function(self) -- 79
			return Rectangle(self.x, self.y, self.width, self.height, self.age) -- 80
		end, -- 79

		get_adjusted_rect = function(self, x_add_amount, y_add_amount, should_transfer_age) -- 82
			if should_transfer_age == nil then -- 82
				should_transfer_age = false -- 82
			end -- 82
			return Rectangle(self.x + x_add_amount, self.y + y_add_amount, self.width - x_add_amount * 2, self.height - y_add_amount * 2, _anon_func_0(self, should_transfer_age)) -- 83
		end -- 82
	} -- 53
	if _base_0.__index == nil then -- 53
		_base_0.__index = _base_0 -- 53
	end -- 53
	_class_0 = setmetatable({ -- 53
		__init = function(self, x, y, width, height, new_age) -- 54
			if new_age == nil then -- 54
				new_age = 0 -- 54
			end -- 54
			self.x = x -- 54
			self.y = y -- 54
			self.width = width -- 54
			self.height = height -- 54
			self.age = new_age -- 55
			self.dx = 0 -- 56
			self.dy = 0 -- 57
		end, -- 54
		__base = _base_0, -- 53
		__name = "Rectangle" -- 53
	}, { -- 53
		__index = _base_0, -- 53
		__call = function(cls, ...) -- 53
			local _self_0 = setmetatable({ }, _base_0) -- 53
			cls.__init(_self_0, ...) -- 53
			return _self_0 -- 53
		end -- 53
	}) -- 53
	_base_0.__class = _class_0 -- 53
	Rectangle = _class_0 -- 53
end -- 53

local test = Rectangle(4) -- 91

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 94
local is_using_mouse_for_nav = false -- 95
local rects = { } -- 96
local goal = { } -- 97
local particles = { } -- 98
local undo_stack = { } -- 99

local squish_sounds -- 101
do -- 101
	local _accum_0 = { } -- 101
	local _len_0 = 1 -- 101
	for i = 1, 3 do -- 101
		_accum_0[_len_0] = love.audio.newSource("sounds/squish" .. tostring(i) .. ".wav", "static") -- 101
		_len_0 = _len_0 + 1 -- 101
	end -- 101
	squish_sounds = _accum_0 -- 101
end -- 101
local scream_sounds -- 102
do -- 102
	local _accum_0 = { } -- 102
	local _len_0 = 1 -- 102
	for i = 1, 3 do -- 102
		_accum_0[_len_0] = love.audio.newSource("sounds/scream" .. tostring(i) .. ".wav", "static") -- 102
		_len_0 = _len_0 + 1 -- 102
	end -- 102
	scream_sounds = _accum_0 -- 102
end -- 102
local deny_sound = love.audio.newSource("sounds/deny.wav", "static") -- 103
local slide_sound = love.audio.newSource("sounds/slide1.wav", "static") -- 104
local undo_sound = love.audio.newSource("sounds/undo.wav", "static") -- 105
local win_sound = love.audio.newSource("sounds/win.wav", "static") -- 106
local selected_index = 1 -- 107
local kb = { } -- 108
local SMALLEST_SIZE_ALLOWED = 20 -- 109

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = true -- 114

if hide_errors then -- 116
	love.errorhandler = function(msg) -- 117
		msg = tostring(msg) -- 118
		print(msg) -- 119
		do -- 120
			LuaReload.Monitor() -- 120
		end -- 120
		return love.graphics.print(msg, 10, 10) -- 121
	end -- 117
end -- 116

local has_done_initial_setup = false -- 123
local is_showing_goal_overlay = true -- 124
local has_won_current = false -- 125
local current_level = 1 -- 126
local split_rect_at -- 127
local start_next_level_cooldown = 0 -- 128

local make_goal -- 130
make_goal = function() -- 130
	goal = { } -- 131
	table.insert(goal, Rectangle(10, 10, 750, 400)) -- 132
	math.randomseed(current_level) -- 133
	if current_level == 1 then -- 134
		for i = 1, 4 do -- 135
			split_rect_at(goal, math.random(#goal)) -- 136
		end -- 135
	elseif current_level == 2 then -- 137
		for i = 1, 5 do -- 138
			split_rect_at(goal, 1) -- 139
		end -- 138
	else -- 141
		for i = 1, 7 do -- 141
			split_rect_at(goal, math.random(#goal)) -- 142
		end -- 141
	end -- 134
end -- 130

is_showing_goal_overlay = false -- 144

local reset_state_as_needed -- 146
reset_state_as_needed = function() -- 146
	if has_done_initial_setup then -- 147
		return -- 148
	end -- 147
	rects = { } -- 149
	undo_stack = { } -- 150
	particles = { } -- 151
	selected_index = 1 -- 152
	has_won_current = false -- 153
	table.insert(rects, Rectangle(10, 10, 750, 400)) -- 154
	make_goal() -- 155
	has_done_initial_setup = true -- 156
end -- 146

local play_random_sound_from -- 158
play_random_sound_from = function(some_table, pitch_lo, pitch_hi) -- 158
	if pitch_lo == nil then -- 158
		pitch_lo = 1.0 -- 158
	end -- 158
	if pitch_hi == nil then -- 158
		pitch_hi = 1.0 -- 158
	end -- 158
	local new = some_table[math.random(#some_table)]:clone() -- 159
	new:setPitch(math.random(pitch_lo, pitch_hi)) -- 160
	return new:play() -- 161
end -- 158

local on_split_success -- 163
on_split_success = function() -- 163
	if love.keyboard.isDown("lshift") then -- 164
		selected_index = #rects -- 165
	end -- 164
	play_random_sound_from(scream_sounds, 0.7, 1.3) -- 166
	return play_random_sound_from(squish_sounds, 0.9, 1.4) -- 167
end -- 163

local choose_random_from -- 169
choose_random_from = function(some_table) -- 169
	return some_table[math.random(#some_table)] -- 170
end -- 169

local add_to_undo_stack -- 172
add_to_undo_stack = function() -- 172
	do -- 173
		local _accum_0 = { } -- 173
		local _len_0 = 1 -- 173
		for _index_0 = 1, #rects do -- 173
			local rect = rects[_index_0] -- 173
			_accum_0[_len_0] = rect:get_clone() -- 173
			_len_0 = _len_0 + 1 -- 173
		end -- 173
		undo_stack[#undo_stack + 1] = _accum_0 -- 173
	end -- 173
	undo_stack[#undo_stack]["selected_index"] = selected_index -- 174
	-- print("end undo stack")
end -- 172

local remove_from_undo_stack -- 178
remove_from_undo_stack = function() -- 178
	if #undo_stack > 0 then -- 179
		do -- 180
			local _accum_0 = { } -- 180
			local _len_0 = 1 -- 180
			local _list_0 = undo_stack[#undo_stack] -- 180
			for _index_0 = 1, #_list_0 do -- 180
				local rect = _list_0[_index_0] -- 180
				_accum_0[_len_0] = rect:get_clone() -- 180
				_len_0 = _len_0 + 1 -- 180
			end -- 180
			rects = _accum_0 -- 180
		end -- 180
		selected_index = undo_stack[#undo_stack]["selected_index"] -- 181
		undo_stack[#undo_stack] = nil -- 182
		return undo_sound:clone():play() -- 183
	else -- 185
		return deny_sound:clone():play() -- 185
	end -- 179
end -- 178

local _anon_func_1 = function(x_amount) -- 196
	if x_amount > 0 then -- 196
		return 1 -- 196
	else -- 196
		return -1 -- 196
	end -- 196
end -- 196
local add_split_particle -- 187
add_split_particle = function(center_table, particle_width, spawn_radius) -- 187
	local x_amount = (math.random() - .5) * 2 * spawn_radius -- 188
	local y_amount = (math.random() - .5) * 2 * spawn_radius -- 189
	local new_particle = Rectangle(center_table.x + x_amount, center_table.y + y_amount, particle_width, particle_width) -- 190
	new_particle.dx = 8 * (_anon_func_1(x_amount)) -- 196
	particles[#particles + 1] = new_particle -- 197
end -- 187

split_rect_at = function(to_split, index) -- 199
	local center_table_before = to_split[index]:get_center_as_table() -- 200
	do -- 201
		local _with_0 = to_split[index] -- 201
		if _with_0.width > _with_0.height then -- 202
			-- vertical line
			if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 204
				if to_split == rects then -- 205
					add_to_undo_stack() -- 206
				end -- 205
				local width_before = _with_0.width -- 207
				_with_0.width = _with_0.width / 2 -- 208
				local half_width = _with_0.width -- 209
				_with_0.age = 0 -- 210
				table.insert(to_split, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 211
				if to_split == rects then -- 212
					for i = 0, 5 do -- 213
						local center_table -- 214
						do -- 214
							local _tbl_0 = { } -- 214
							for k, v in pairs(center_table_before) do -- 214
								_tbl_0[k] = v -- 214
							end -- 214
							center_table = _tbl_0 -- 214
						end -- 214
						center_table.y = _with_0.y + (_with_0.height / 5) * i -- 215
						local size_divider -- 216
						if half_width < 100 then -- 216
							size_divider = 4 -- 216
						else -- 216
							size_divider = 7 -- 216
						end -- 216
						add_split_particle(center_table, half_width / size_divider, 20) -- 217
					end -- 213
					-- dump(particles)
					on_split_success() -- 219
				end -- 212
				return -- 220
			end -- 204
		else -- 223
			-- horizontal line
			if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 224
				if to_split == rects then -- 225
					add_to_undo_stack() -- 226
				end -- 225
				local height_before = _with_0.height -- 227
				_with_0.height = _with_0.height / 2 -- 228
				local half_height = _with_0.height -- 229
				_with_0.age = 0 -- 230
				table.insert(to_split, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 231
				if to_split == rects then -- 232
					for i = 0, 5 do -- 233
						local center_table -- 234
						do -- 234
							local _tbl_0 = { } -- 234
							for k, v in pairs(center_table_before) do -- 234
								_tbl_0[k] = v -- 234
							end -- 234
							center_table = _tbl_0 -- 234
						end -- 234
						center_table.y = _with_0.y + (_with_0.height / 5) * i -- 235
						local size_divider -- 236
						if half_height < 100 then -- 236
							size_divider = 4 -- 236
						else -- 236
							size_divider = 7 -- 236
						end -- 236
						add_split_particle(center_table, half_height / size_divider, 20) -- 237
					end -- 233
					on_split_success() -- 238
				end -- 232
				return -- 239
			end -- 224
		end -- 202
	end -- 201
	-- deny_sound
	return deny_sound:clone():play() -- 241
end -- 199

local show_shadow_split_spot -- 243
show_shadow_split_spot = function(index) -- 243
	local _with_0 = rects[index] -- 244
	if _with_0.width > _with_0.height then -- 245
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 246
			local line_width = _with_0.width * .03 -- 247
			local half_line_width = line_width / 2 -- 248
			-- vertical line
			local width_before = _with_0.width -- 250
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.height * .1) -- 251
			local half_rect_width = _with_0.width / 2 -- 252
			love.graphics.rectangle("fill", _with_0.x + half_rect_width - half_line_width, _with_0.y + moving_offset, line_width, _with_0.height) -- 253
		end -- 246
	else -- 257
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 257
			local line_width = _with_0.height * .05 -- 258
			local half_line_width = line_width / 2 -- 259
			-- horizontal line
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.width * .1) -- 261
			local height_before = _with_0.height -- 262
			local half_height = _with_0.height / 2 -- 263
			love.graphics.rectangle("fill", _with_0.x + moving_offset, _with_0.y + half_height - half_line_width, _with_0.width, line_width) -- 264
		end -- 257
	end -- 245
	return _with_0 -- 244
end -- 243

love.keypressed = function(key) -- 267
	if key == "r" then -- 268
		has_done_initial_setup = false -- 269
	end -- 268
	if ("q" == key or "escape" == key) then -- 270
		love.event.quit() -- 271
	end -- 270
	if key == 'a' then -- 272
		return love.event.quit() -- 273
	end -- 272
end -- 267

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

local never_pressed_time = -100 -- 300
local _anon_func_2 = function(kb, key, never_pressed_time) -- 302
	local _exp_0 = kb[key] -- 302
	if _exp_0 ~= nil then -- 302
		return _exp_0 -- 302
	else -- 302
		return never_pressed_time -- 302
	end -- 302
end -- 302
local was_just_pressed -- 301
was_just_pressed = function(key) -- 301
	local was_down_before = (_anon_func_2(kb, key, never_pressed_time)) > 0 -- 302
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 304
		kb[key] = love.timer.getTime() -- 305
	else -- 307
		kb[key] = never_pressed_time -- 307
	end -- 304
	return love.keyboard.isDown(key) and not was_down_before -- 308
end -- 301

local repeat_kb = { } -- 310
local is_pressed_with_repeat_allowed -- 311
is_pressed_with_repeat_allowed = function(key, repeat_time) -- 311
	if repeat_time == nil then -- 311
		repeat_time = .3 -- 311
	end -- 311
	if not love.keyboard.isDown(key) then -- 312
		repeat_kb[key] = nil -- 313
		return false -- 314
	end -- 312
	if repeat_kb[key] == nil or love.timer.getTime() - repeat_kb[key] >= repeat_time then -- 315
		repeat_kb[key] = love.timer.getTime() -- 316
		return true -- 317
	end -- 315
	return false -- 318
end -- 311

local mouse_before = { } -- 320
local is_mouse_pressed_once -- 321
is_mouse_pressed_once = function() -- 321
	if not love.mouse.isDown(1) then -- 322
		mouse_before[1] = false -- 323
		return false -- 324
	end -- 322
	if love.mouse.isDown(1) then -- 325
		if not mouse_before[1] then -- 326
			mouse_before[1] = true -- 327
			return true -- 328
		end -- 326
	end -- 325
	return false -- 329
end -- 321

local bring_focus_to_neighbors -- 331
bring_focus_to_neighbors = function() -- 331
	local x_offset = 0 -- 332
	local y_offset = 0 -- 333
	if is_pressed_with_repeat_allowed("left") then -- 334
		x_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 335
		is_using_mouse_for_nav = false -- 336
	end -- 334
	if is_pressed_with_repeat_allowed("right") then -- 337
		x_offset = SMALLEST_SIZE_ALLOWED / 2 -- 338
		is_using_mouse_for_nav = false -- 339
	end -- 337

	if is_pressed_with_repeat_allowed("up") then -- 341
		y_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 342
		is_using_mouse_for_nav = false -- 343
	end -- 341
	if is_pressed_with_repeat_allowed("down") then -- 344
		y_offset = SMALLEST_SIZE_ALLOWED / 2 -- 345
		is_using_mouse_for_nav = false -- 346
	end -- 344

	if x_offset == 0 and y_offset == 0 then -- 348
		return -- 349
	end -- 348

	local cur_x, cur_y = rects[selected_index]:get_center(-SMALLEST_SIZE_ALLOWED / 2, -SMALLEST_SIZE_ALLOWED / 2) -- 351
	if love.keyboard.isDown("lshift") then -- 352
		cur_x, cur_y = rects[selected_index]:get_center(SMALLEST_SIZE_ALLOWED / 2, SMALLEST_SIZE_ALLOWED / 2) -- 353
	end -- 352

	local screen_size_x = 800 -- 355
	local screen_size_y = 450 -- 356
	while -10 <= cur_x and cur_x <= screen_size_x and -10 <= cur_y and cur_y <= screen_size_y do -- 357
		cur_x = cur_x + x_offset -- 358
		cur_y = cur_y + y_offset -- 359
		-- print(cur_y, cur_x)
		for i, rect in ipairs(rects) do -- 361
			local _continue_0 = false -- 362
			repeat -- 362
				if rect == rects[selected_index] then -- 362
					_continue_0 = true -- 363
					break -- 363
				end -- 362
				if rect:contains(cur_x, cur_y) then -- 364
					-- love.audio.play(slide_sound)
					slide_sound:clone():play() -- 366
					selected_index = i -- 367
					return -- 368
				end -- 364
				_continue_0 = true -- 362
			until true -- 362
			if not _continue_0 then -- 362
				break -- 362
			end -- 362
		end -- 361
	end -- 357
end -- 331

local did_slice_action -- 370
did_slice_action = function(repeat_time) -- 370
	if repeat_time == nil then -- 370
		repeat_time = .3 -- 370
	end -- 370
	if has_won_current then -- 371
		return false -- 372
	end -- 371
	return is_pressed_with_repeat_allowed("s", repeat_time) or is_pressed_with_repeat_allowed("space", repeat_time) or is_pressed_with_repeat_allowed("return", repeat_time) or is_mouse_pressed_once() -- 373
end -- 370

local old_mouse_pos_x = -10 -- 378
local old_mouse_pos_y = -10 -- 379
local pingpong -- 380
pingpong = function(value, lower, upper) -- 380
	local dist = (upper - lower) -- 381
	if math.floor(value / dist) % 2 == 1 then -- 382
		local amount_over = value % dist -- 383
		return upper - amount_over -- 384
	end -- 382
	return (value % dist) + lower -- 385
end -- 380

local does_match_goal -- 387
does_match_goal = function() -- 387
	for _index_0 = 1, #goal do -- 388
		local rect_to_find = goal[_index_0] -- 388
		local found = false -- 389
		for _index_1 = 1, #rects do -- 390
			local player_placed = rects[_index_1] -- 390
			if rect_to_find:get_hash() == player_placed:get_hash() then -- 391
				found = true -- 392
				break -- 393
			end -- 391
		end -- 390
		if not found then -- 394
			return false -- 395
		end -- 394
	end -- 388
	return true -- 396
end -- 387

local update_particles -- 398
update_particles = function() -- 398
	for i, particle in pairs(particles) do -- 399
		particle.age = particle.age + 1 -- 400
		particle.y = particle.y + (particle.age / 2) -- 401
		particle.x = particle.x + particle.dx -- 402
		particle.dx = particle.dx * .93 -- 403
		if particle.y > 1000 then -- 404
			particles[i] = nil -- 405
		end -- 404
	end -- 399
end -- 398

love.update = function(dt) -- 407
	do -- 408
		LuaReload.Monitor() -- 408
	end -- 408
	if love.window.hasFocus() then -- 409
		do -- 410
			LuaReload.Monitor() -- 410
		end -- 410
	end -- 409
	reset_state_as_needed() -- 411
	-- print("before", is_using_mouse_for_nav)
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 413
	if old_mouse_pos_x ~= mouse_pos_x or old_mouse_pos_y ~= mouse_pos_y then -- 414
		old_mouse_pos_x = mouse_pos_x -- 415
		old_mouse_pos_y = mouse_pos_y -- 416
		is_using_mouse_for_nav = true -- 417
		-- print(old_mouse_pos_x, old_mouse_pos_y)
	end -- 414
	-- print("after", is_using_mouse_for_nav)
	if was_just_pressed("tab") or was_just_pressed("t") or was_just_pressed("c") then -- 420
		is_showing_goal_overlay = not is_showing_goal_overlay -- 421
	end -- 420

	if is_pressed_with_repeat_allowed("z", .3) then -- 423
		remove_from_undo_stack() -- 424
	end -- 423

	if is_using_mouse_for_nav then -- 426
		for i, rect in ipairs(rects) do -- 427
			if rect:contains(mouse_pos_x, mouse_pos_y) then -- 428
				selected_index = i -- 429
				break -- 430
			end -- 428
		end -- 427
	end -- 426

	if does_match_goal() and not has_won_current then -- 432
		print("matches") -- 433
		has_won_current = true -- 434
		current_level = current_level + 1 -- 435
		win_sound:clone():play() -- 436
		start_next_level_cooldown = 60 -- 437
	end -- 432

	start_next_level_cooldown = math.max(start_next_level_cooldown - 1, 0) -- 439
	if start_next_level_cooldown == 1 then -- 440
		has_done_initial_setup = false -- 441
	end -- 440

	-- if love.keyboard.isDown "escape"
	if did_slice_action() then -- 445
		split_rect_at(rects, selected_index) -- 446
	end -- 445
	update_particles() -- 447
	bring_focus_to_neighbors() -- 448
	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 449
end -- 407

local blue_coloring = { -- 452
	.3, -- 452
	.6, -- 453
	.7, -- 454
	1 -- 455
} -- 451
local draw_grids -- 457
draw_grids = function() -- 457
	local should_draw = { -- 458
		true -- 458
	} -- 458
	if is_showing_goal_overlay then -- 459
		should_draw[#should_draw + 1] = true -- 460
	end -- 459
	local rect_tables = { -- 461
		rects, -- 461
		goal -- 461
	} -- 461
	for table_num, rect_table in ipairs(rect_tables) do -- 462
		if not should_draw[table_num] then -- 463
			return -- 464
		end -- 463
		for i, rect in ipairs(rect_table) do -- 465
			rect.age = rect.age + 1 -- 466
			local normal_view_alpha = 1 -- 467
			local ghost_alpha = ((math.sin(love.timer.getTime() * 3) + 1) / 16.0) + .2 -- 468
			if table_num == 1 then -- 469
				if is_showing_goal_overlay then -- 470
					normal_view_alpha = .2 -- 470
				else -- 470
					normal_view_alpha = 1 -- 470
				end -- 470
				if i == selected_index then -- 471
					love.graphics.setColor(.8, .6, .1, normal_view_alpha) -- 472
				else -- 474
					love.graphics.setColor(blue_coloring) -- 474
				end -- 471
			end -- 469
			if table_num == 2 then -- 475
				love.graphics.setColor(.3, .2, .0, ghost_alpha) -- 476
			end -- 475

			if table_num == 1 then -- 479
				love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 480
				local shrink_amount = rect.height * .05 -- 481
				local r, g, b, a = love.graphics.getColor() -- 482
				love.graphics.setColor(r, g * .75, b, a) -- 483
				love.graphics.rectangle("fill", rect.x + shrink_amount, rect.y + shrink_amount, rect.width - (shrink_amount * 2), rect.height - (shrink_amount * 2)) -- 484
			end -- 479
			if table_num == 1 then -- 485
				love.graphics.setColor(0, 0, 0, normal_view_alpha) -- 486
			else -- 488
				love.graphics.setColor(1, 1, 0, ghost_alpha) -- 488
			end -- 485
			love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 489
			local eye_dist_from_center_x = rect.width / 5.0 -- 490
			local eye_dist_from_center_y = rect.height / 8.0 -- 491
			local mouth_dist_from_center_y = rect.height / 10.0 -- 492
			local center_x, center_y = rect:get_center() -- 493
			local x_radius = rect.width / 16.0 -- 494
			local y_radius = rect.width / 16.0 -- 495
			math.randomseed(rect:get_hash()) -- 496
			local eye_shake_time = 60 -- 497
			local mouth_size = math.min(rect.height, rect.width) * .03 -- 498
			local eye_offset = 0 -- 499
			if rect.age < eye_shake_time then -- 500
				eye_offset = ((eye_shake_time - rect.age) ^ (1.6 - rect.age / eye_shake_time)) / 10 -- 501
			end -- 500
			love.graphics.ellipse("fill", center_x + eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y + eye_offset, x_radius, y_radius) -- 502
			love.graphics.ellipse("fill", center_x - eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y - eye_offset, x_radius, y_radius) -- 503
			local mouth_func -- 504
			mouth_func = function(func) -- 504
				local clamped = math.min(rect.age, 30) -- 505
				return ((func(clamped / 1.5 + rect:get_hash()) + 3) * mouth_size) -- 506
			end -- 504
			love.graphics.ellipse("fill", center_x, center_y + mouth_dist_from_center_y, mouth_func(math.cos), mouth_func(math.sin)) -- 507

			if table_num == 1 then -- 510
				show_shadow_split_spot(selected_index) -- 511
			end -- 510
			love.graphics.setColor(1, 1, 1, 1) -- 512
		end -- 465
		math.randomseed() -- 513
		love.graphics.print("Read instructions below", 10, 420) -- 514
	end -- 462
end -- 457

love.draw = function() -- 516
	love.graphics.setFont(main_font) -- 517
	local tile_size = 100 -- 518
	-- print(mouse_pos_x, mouse_pos_y)
	draw_grids() -- 520
	local blue_copy -- 521
	do -- 521
		local _tbl_0 = { } -- 521
		for k, v in pairs(blue_coloring) do -- 521
			_tbl_0[k] = v -- 521
		end -- 521
		blue_copy = _tbl_0 -- 521
	end -- 521
	-- blue_copy[3] *= .9
	for i, particle in pairs(particles) do -- 523
		math.randomseed(i) -- 524
		blue_copy = { -- 525
			.2, -- 525
			.3 + (math.random(-10, 30) / 100), -- 525
			.8, -- 525
			1 -- 525
		} -- 525
		love.graphics.setColor(blue_copy) -- 526
		love.graphics.rectangle("fill", particle.x, particle.y, particle.width, particle.height) -- 527
	end -- 523
	return love.graphics.setColor(1, 1, 1) -- 528
end -- 516

love.load = function() -- 531
	print(_VERSION) -- 532
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 533
end -- 531
