-- [yue]: examples/jelly_slicing/core.yue
local love = require("love") -- 1
-- import p from "yue"

-- macro is_reloading = (debugging) ->
--   global debugMode = debugging == "true"
--   ""
-- macro is_reloading = (val) -> 




local dump -- 20
dump = function(table, indent) -- 20
	if indent == nil then -- 20
		indent = "" -- 20
	end -- 20
	print(indent .. "{") -- 21
	for k, v in pairs(table) do -- 22
		if #indent > 0 then -- 23
			io.write(indent) -- 24
		end -- 23
		io.write(k .. ": ") -- 25
		if type(v) == 'table' then -- 26
			print() -- 27
			dump(v, indent .. "    ") -- 28
		else -- 30
			print(v) -- 30
		end -- 26
	end -- 22
	return print(indent .. "}") -- 31
end -- 20

local show -- 33
show = function(to_show, indent) -- 33
	if indent == nil then -- 33
		indent = "" -- 33
	end -- 33
	if to_show == nil then -- 34
		return "" -- 35
	end -- 34
	local ret = "{\n" -- 36
	for k, v in pairs(to_show) do -- 37
		if #indent > 0 then -- 38
			ret = ret .. indent -- 39
		end -- 38
		ret = ret .. (k .. ": ") -- 40
		if type(v) == 'table' then -- 41
			ret = ret .. "\n" -- 42
			ret = ret .. (show(v, indent .. "    ")) -- 43
		else -- 45
			ret = ret .. (tostring(v) .. "\n") -- 45
		end -- 41
	end -- 37
	ret = ret .. "}" -- 46
	if indent == "" then -- 47
		love.graphics.print(ret, 10, 10) -- 48
	end -- 47
	return ret -- 49
end -- 33

local Rectangle -- 51
do -- 51
	local _class_0 -- 51
	local _base_0 = { -- 51

		contains = function(self, point_x, point_y) -- 55
			return self.x <= point_x and point_x <= (self.x + self.width) and self.y <= point_y and point_y <= (self.y + self.height) -- 56
		end, -- 55

		get_center = function(self, offset_x, offset_y) -- 58
			if offset_x == nil then -- 58
				offset_x = 0 -- 58
			end -- 58
			if offset_y == nil then -- 58
				offset_y = 0 -- 58
			end -- 58
			return self.x + (self.width / 2) + offset_x, self.y + (self.height / 2) + offset_y -- 59
		end, -- 58

		get_top_left = function(self) -- 61
			return self.x, self.y -- 62
		end, -- 61

		get_bottom_right = function(self) -- 64
			return self.x + self.width, self.y + self.height -- 65
		end, -- 64

		get_hash = function(self) -- 67
			return self.x * 1000000 + self.width * 1000 + self.y * 100 + self.height -- 68
		end, -- 67

		get_clone = function(self) -- 70
			return Rectangle(self.x, self.y, self.width, self.height, self.age) -- 71
		end -- 70
	} -- 51
	if _base_0.__index == nil then -- 51
		_base_0.__index = _base_0 -- 51
	end -- 51
	_class_0 = setmetatable({ -- 51
		__init = function(self, x, y, width, height, new_age) -- 52
			if new_age == nil then -- 52
				new_age = 0 -- 52
			end -- 52
			self.x = x -- 52
			self.y = y -- 52
			self.width = width -- 52
			self.height = height -- 52
			self.age = new_age -- 53
		end, -- 52
		__base = _base_0, -- 51
		__name = "Rectangle" -- 51
	}, { -- 51
		__index = _base_0, -- 51
		__call = function(cls, ...) -- 51
			local _self_0 = setmetatable({ }, _base_0) -- 51
			cls.__init(_self_0, ...) -- 51
			return _self_0 -- 51
		end -- 51
	}) -- 51
	_base_0.__class = _class_0 -- 51
	Rectangle = _class_0 -- 51
end -- 51

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 74
local is_using_mouse_for_nav = false -- 75
local rects = { } -- 76
local goal = { } -- 77
local undo_stack = { } -- 78

local squish_sounds -- 80
do -- 80
	local _accum_0 = { } -- 80
	local _len_0 = 1 -- 80
	for i = 1, 3 do -- 80
		_accum_0[_len_0] = love.audio.newSource("sounds/squish" .. tostring(i) .. ".wav", "static") -- 80
		_len_0 = _len_0 + 1 -- 80
	end -- 80
	squish_sounds = _accum_0 -- 80
end -- 80
local scream_sounds -- 81
do -- 81
	local _accum_0 = { } -- 81
	local _len_0 = 1 -- 81
	for i = 1, 3 do -- 81
		_accum_0[_len_0] = love.audio.newSource("sounds/scream" .. tostring(i) .. ".wav", "static") -- 81
		_len_0 = _len_0 + 1 -- 81
	end -- 81
	scream_sounds = _accum_0 -- 81
end -- 81
local deny_sound = love.audio.newSource("sounds/deny.wav", "static") -- 82
local slide_sound = love.audio.newSource("sounds/slide1.wav", "static") -- 83
local undo_sound = love.audio.newSource("sounds/undo.wav", "static") -- 84
local win_sound = love.audio.newSource("sounds/win.wav", "static") -- 85
local selected_index = 1 -- 86
local kb = { } -- 87
local SMALLEST_SIZE_ALLOWED = 20 -- 88

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = true -- 93

if hide_errors then -- 95
	love.errorhandler = function(msg) -- 96
		msg = tostring(msg) -- 97
		print(msg) -- 98
		do -- 99
			LuaReload.Monitor() -- 99
		end -- 99
		return love.graphics.print(msg, 10, 10) -- 100
	end -- 96
end -- 95

local make_goal -- 103
make_goal = function() -- 103
	for i = 1, 4 do -- 104
		split_rect_at(goal, math.random(#goal)) -- 105
	end -- 104
end -- 103

local has_done_initial_setup = false -- 107
local is_showing_goal_overlay = true -- 108
local has_won_current = false -- 109
local current_level = 1 -- 110
local reset_state_as_needed -- 111
reset_state_as_needed = function() -- 111
	if has_done_initial_setup then -- 112
		return -- 113
	end -- 112
	rects = { } -- 114
	goal = { } -- 115
	selected_index = 1 -- 116
	has_won_current = false -- 117
	table.insert(rects, Rectangle(10, 10, 750, 400)) -- 118
	table.insert(goal, Rectangle(10, 10, 750, 400)) -- 119
	make_goal() -- 120
	is_showing_goal_overlay = false -- 121
	has_done_initial_setup = true -- 122
end -- 111

-- macro debugLog = ()->
--     if show_logs
--         print() 

local play_random_sound_from -- 129
play_random_sound_from = function(some_table) -- 129
	return some_table[math.random(#some_table)]:clone():play() -- 130
end -- 129

local on_split_success -- 132
on_split_success = function() -- 132
	if love.keyboard.isDown("lshift") then -- 133
		selected_index = #rects -- 134
	end -- 133
	play_random_sound_from(scream_sounds) -- 135
	return play_random_sound_from(squish_sounds) -- 136
end -- 132

local choose_random_from -- 138
choose_random_from = function(some_table) -- 138
	return some_table[math.random(#some_table)] -- 139
end -- 138

local add_to_undo_stack -- 141
add_to_undo_stack = function() -- 141
	do -- 142
		local _accum_0 = { } -- 142
		local _len_0 = 1 -- 142
		for _index_0 = 1, #rects do -- 142
			local rect = rects[_index_0] -- 142
			_accum_0[_len_0] = rect:get_clone() -- 142
			_len_0 = _len_0 + 1 -- 142
		end -- 142
		undo_stack[#undo_stack + 1] = _accum_0 -- 142
	end -- 142
	dump(undo_stack) -- 143
	return print("end undo stack") -- 144
end -- 141

local remove_from_undo_stack -- 147
remove_from_undo_stack = function() -- 147
	do -- 148
		local _accum_0 = { } -- 148
		local _len_0 = 1 -- 148
		local _list_0 = undo_stack[#undo_stack] -- 148
		for _index_0 = 1, #_list_0 do -- 148
			local rect = _list_0[_index_0] -- 148
			_accum_0[_len_0] = rect:get_clone() -- 148
			_len_0 = _len_0 + 1 -- 148
		end -- 148
		rects = _accum_0 -- 148
	end -- 148
	undo_stack[#undo_stack] = nil -- 149
	return undo_sound:clone():play() -- 150
end -- 147

split_rect_at = function(to_split, index) -- 152
	do -- 153
		local _with_0 = to_split[index] -- 153
		if _with_0.width > _with_0.height then -- 154
			if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 155
				if to_split == rects then -- 156
					add_to_undo_stack() -- 157
				end -- 156
				local width_before = _with_0.width -- 158
				_with_0.width = _with_0.width / 2 -- 159
				local half_width = _with_0.width -- 160
				_with_0.age = 0 -- 161
				table.insert(to_split, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 162
				if to_split == rects then -- 163
					on_split_success() -- 164
				end -- 163
				return -- 165
			end -- 155
		else -- 168
			if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 168
				if to_split == rects then -- 169
					add_to_undo_stack() -- 170
				end -- 169
				local height_before = _with_0.height -- 171
				_with_0.height = _with_0.height / 2 -- 172
				local half_height = _with_0.height -- 173
				_with_0.age = 0 -- 174
				table.insert(to_split, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 175
				if to_split == rects then -- 176
					on_split_success() -- 177
				end -- 176
				return -- 178
			end -- 168
		end -- 154
	end -- 153
	-- deny_sound
	return deny_sound:clone():play() -- 180
end -- 152

local show_shadow_split_spot -- 182
show_shadow_split_spot = function(index) -- 182
	local _with_0 = rects[index] -- 183
	if _with_0.width > _with_0.height then -- 184
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 185
			local line_width = _with_0.width * .03 -- 186
			local half_line_width = line_width / 2 -- 187
			-- vertical line
			local width_before = _with_0.width -- 189
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.height * .1) -- 190
			local half_rect_width = _with_0.width / 2 -- 191
			love.graphics.rectangle("fill", _with_0.x + half_rect_width - half_line_width, _with_0.y + moving_offset, line_width, _with_0.height) -- 192
		end -- 185
	else -- 196
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 196
			local line_width = _with_0.height * .05 -- 197
			local half_line_width = line_width / 2 -- 198
			-- horizontal line
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.width * .1) -- 200
			local height_before = _with_0.height -- 201
			local half_height = _with_0.height / 2 -- 202
			love.graphics.rectangle("fill", _with_0.x + moving_offset, _with_0.y + half_height - half_line_width, _with_0.width, line_width) -- 203
		end -- 196
	end -- 184
	return _with_0 -- 183
end -- 182

love.keypressed = function(key) -- 206
	if key == "r" then -- 207
		has_done_initial_setup = false -- 208
	end -- 207
	if ("q" == key or "escape" == key) then -- 209
		love.event.quit() -- 210
	end -- 209
	if key == 'a' then -- 211
		return love.event.quit() -- 212
	end -- 211
end -- 206

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

local never_pressed_time = -100 -- 239
local _anon_func_0 = function(kb, key, never_pressed_time) -- 241
	local _exp_0 = kb[key] -- 241
	if _exp_0 ~= nil then -- 241
		return _exp_0 -- 241
	else -- 241
		return never_pressed_time -- 241
	end -- 241
end -- 241
local was_just_pressed -- 240
was_just_pressed = function(key) -- 240
	local was_down_before = (_anon_func_0(kb, key, never_pressed_time)) > 0 -- 241
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 243
		kb[key] = love.timer.getTime() -- 244
	else -- 246
		kb[key] = never_pressed_time -- 246
	end -- 243
	return love.keyboard.isDown(key) and not was_down_before -- 247
end -- 240

local repeat_kb = { } -- 249
local is_pressed_with_repeat_allowed -- 250
is_pressed_with_repeat_allowed = function(key, repeat_time) -- 250
	if repeat_time == nil then -- 250
		repeat_time = .3 -- 250
	end -- 250
	if not love.keyboard.isDown(key) then -- 251
		repeat_kb[key] = nil -- 252
		return false -- 253
	end -- 251
	if repeat_kb[key] == nil or love.timer.getTime() - repeat_kb[key] >= repeat_time then -- 254
		repeat_kb[key] = love.timer.getTime() -- 255
		return true -- 256
	end -- 254
	return false -- 257
end -- 250

local mouse_before = { } -- 259
local is_mouse_pressed_once -- 260
is_mouse_pressed_once = function() -- 260
	if not love.mouse.isDown(1) then -- 261
		mouse_before[1] = false -- 262
		return false -- 263
	end -- 261
	if love.mouse.isDown(1) then -- 264
		if not mouse_before[1] then -- 265
			mouse_before[1] = true -- 266
			return true -- 267
		end -- 265
	end -- 264
	return false -- 268
end -- 260

local bring_focus_to_neighbors -- 270
bring_focus_to_neighbors = function() -- 270
	local x_offset = 0 -- 271
	local y_offset = 0 -- 272
	if is_pressed_with_repeat_allowed("left") then -- 273
		x_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 274
		is_using_mouse_for_nav = false -- 275
	end -- 273
	if is_pressed_with_repeat_allowed("right") then -- 276
		x_offset = SMALLEST_SIZE_ALLOWED / 2 -- 277
		is_using_mouse_for_nav = false -- 278
	end -- 276

	if is_pressed_with_repeat_allowed("up") then -- 280
		y_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 281
		is_using_mouse_for_nav = false -- 282
	end -- 280
	if is_pressed_with_repeat_allowed("down") then -- 283
		y_offset = SMALLEST_SIZE_ALLOWED / 2 -- 284
		is_using_mouse_for_nav = false -- 285
	end -- 283

	if x_offset == 0 and y_offset == 0 then -- 287
		return -- 288
	end -- 287

	local cur_x, cur_y = rects[selected_index]:get_center(-SMALLEST_SIZE_ALLOWED / 2, -SMALLEST_SIZE_ALLOWED / 2) -- 290
	if love.keyboard.isDown("lshift") then -- 291
		cur_x, cur_y = rects[selected_index]:get_center(SMALLEST_SIZE_ALLOWED / 2, SMALLEST_SIZE_ALLOWED / 2) -- 292
	end -- 291

	local screen_size_x = 800 -- 294
	local screen_size_y = 450 -- 295
	while -10 <= cur_x and cur_x <= screen_size_x and -10 <= cur_y and cur_y <= screen_size_y do -- 296
		cur_x = cur_x + x_offset -- 297
		cur_y = cur_y + y_offset -- 298
		-- print(cur_y, cur_x)
		for i, rect in ipairs(rects) do -- 300
			local _continue_0 = false -- 301
			repeat -- 301
				if rect == rects[selected_index] then -- 301
					_continue_0 = true -- 302
					break -- 302
				end -- 301
				if rect:contains(cur_x, cur_y) then -- 303
					-- love.audio.play(slide_sound)
					slide_sound:clone():play() -- 305
					selected_index = i -- 306
					return -- 307
				end -- 303
				_continue_0 = true -- 301
			until true -- 301
			if not _continue_0 then -- 301
				break -- 301
			end -- 301
		end -- 300
	end -- 296
end -- 270

local did_slice_action -- 309
did_slice_action = function(repeat_time) -- 309
	if repeat_time == nil then -- 309
		repeat_time = .3 -- 309
	end -- 309
	return is_pressed_with_repeat_allowed("s", repeat_time) or is_pressed_with_repeat_allowed("space", repeat_time) or is_pressed_with_repeat_allowed("return", repeat_time) or is_mouse_pressed_once() -- 310
end -- 309

local old_mouse_pos_x = -10 -- 315
local old_mouse_pos_y = -10 -- 316
local pingpong -- 317
pingpong = function(value, lower, upper) -- 317
	local dist = (upper - lower) -- 318
	if math.floor(value / dist) % 2 == 1 then -- 319
		local amount_over = value % dist -- 320
		return upper - amount_over -- 321
	end -- 319
	return (value % dist) + lower -- 322
end -- 317

local does_match_goal -- 324
does_match_goal = function() -- 324
	for _index_0 = 1, #goal do -- 325
		local rect_to_find = goal[_index_0] -- 325
		local found = false -- 326
		for _index_1 = 1, #rects do -- 327
			local player_placed = rects[_index_1] -- 327
			if rect_to_find:get_hash() == player_placed:get_hash() then -- 328
				found = true -- 329
				break -- 330
			end -- 328
		end -- 327
		if not found then -- 331
			return false -- 332
		end -- 331
	end -- 325
	return true -- 333
end -- 324

love.update = function(dt) -- 336
	do -- 337
		LuaReload.Monitor() -- 337
	end -- 337
	if love.window.hasFocus() then -- 338
		do -- 339
			LuaReload.Monitor() -- 339
		end -- 339
	end -- 338
	reset_state_as_needed() -- 340
	-- print("before", is_using_mouse_for_nav)
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 342
	if old_mouse_pos_x ~= mouse_pos_x or old_mouse_pos_y ~= mouse_pos_y then -- 343
		old_mouse_pos_x = mouse_pos_x -- 344
		old_mouse_pos_y = mouse_pos_y -- 345
		is_using_mouse_for_nav = true -- 346
		-- print(old_mouse_pos_x, old_mouse_pos_y)
	end -- 343
	-- print("after", is_using_mouse_for_nav)
	if was_just_pressed("tab") or was_just_pressed("t") or was_just_pressed("c") then -- 349
		is_showing_goal_overlay = not is_showing_goal_overlay -- 350
	end -- 349

	if is_pressed_with_repeat_allowed("z", .3) then -- 352
		remove_from_undo_stack() -- 353
	end -- 352

	if is_using_mouse_for_nav then -- 355
		for i, rect in ipairs(rects) do -- 356
			if rect:contains(mouse_pos_x, mouse_pos_y) then -- 357
				selected_index = i -- 358
				break -- 359
			end -- 357
		end -- 356
	end -- 355

	if does_match_goal() and not has_won_current then -- 361
		print("matches") -- 362
		has_won_current = true -- 363
		current_level = current_level + 1 -- 364

		win_sound:clone():play() -- 366
	end -- 361

	-- if love.keyboard.isDown "escape"
	if did_slice_action() then -- 369
		split_rect_at(rects, selected_index) -- 370
	end -- 369
	bring_focus_to_neighbors() -- 371
	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 372
end -- 336

love.draw = function() -- 374
	love.graphics.setFont(main_font) -- 375
	local tile_size = 100 -- 376
	-- print(mouse_pos_x, mouse_pos_y)
	local should_draw = { -- 378
		true -- 378
	} -- 378
	if is_showing_goal_overlay then -- 379
		should_draw[#should_draw + 1] = true -- 380
	end -- 379
	local rect_tables = { -- 381
		rects, -- 381
		goal -- 381
	} -- 381
	for table_num, rect_table in ipairs(rect_tables) do -- 382
		if not should_draw[table_num] then -- 383
			return -- 384
		end -- 383
		for i, rect in ipairs(rect_table) do -- 385
			rect.age = rect.age + 1 -- 386
			local normal_view_alpha = 1 -- 387
			local ghost_alpha = ((math.sin(love.timer.getTime() * 3) + 1) / 16.0) + .2 -- 388
			if table_num == 1 then -- 389
				if is_showing_goal_overlay then -- 390
					normal_view_alpha = .2 -- 390
				else -- 390
					normal_view_alpha = 1 -- 390
				end -- 390
				if i == selected_index then -- 391
					love.graphics.setColor(.8, .6, .1, normal_view_alpha) -- 392
				else -- 394
					love.graphics.setColor(.3, .6, .7, normal_view_alpha) -- 394
				end -- 391
			end -- 389
			if table_num == 2 then -- 395
				love.graphics.setColor(.3, .2, .0, ghost_alpha) -- 396
			end -- 395

			love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 399
			local shrink_amount = rect.height * .05 -- 400
			local r, g, b, a = love.graphics.getColor() -- 401
			love.graphics.setColor(r, g * .75, b, a) -- 402
			love.graphics.rectangle("fill", rect.x + shrink_amount, rect.y + shrink_amount, rect.width - (shrink_amount * 2), rect.height - (shrink_amount * 2)) -- 403
			if table_num == 1 then -- 404
				love.graphics.setColor(0, 0, 0, normal_view_alpha) -- 405
			else -- 407
				love.graphics.setColor(1, 1, 0, ghost_alpha) -- 407
			end -- 404
			love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 408
			local eye_dist_from_center_x = rect.width / 5.0 -- 409
			local eye_dist_from_center_y = rect.height / 8.0 -- 410
			local mouth_dist_from_center_y = rect.height / 10.0 -- 411
			local center_x, center_y = rect:get_center() -- 412
			local x_radius = rect.width / 16.0 -- 413
			local y_radius = rect.width / 16.0 -- 414
			math.randomseed(rect:get_hash()) -- 415
			local eye_shake_time = 60 -- 416
			local mouth_size = math.min(rect.height, rect.width) * .03 -- 417
			local eye_offset = 0 -- 418
			if rect.age < eye_shake_time then -- 419
				eye_offset = ((eye_shake_time - rect.age) ^ (1.6 - rect.age / eye_shake_time)) / 10 -- 420
			end -- 419
			love.graphics.ellipse("fill", center_x + eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y + eye_offset, x_radius, y_radius) -- 421
			love.graphics.ellipse("fill", center_x - eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y - eye_offset, x_radius, y_radius) -- 422
			local mouth_func -- 423
			mouth_func = function(func) -- 423
				local clamped = math.min(rect.age, 30) -- 424
				return ((func(clamped / 1.5 + rect:get_hash()) + 3) * mouth_size) -- 425
			end -- 423
			love.graphics.ellipse("fill", center_x, center_y + mouth_dist_from_center_y, mouth_func(math.cos), mouth_func(math.sin)) -- 426

			if table_num == 1 then -- 429
				show_shadow_split_spot(selected_index) -- 430
			end -- 429
			love.graphics.setColor(1, 1, 1, 1) -- 431
		end -- 385
	end -- 382

	-- love.graphics.rectangle("fill", 10, 10, tile_size, tile_size)s
	return love.graphics.setColor(1, 1, 1) -- 434
	-- if is_pressed_with_repeat_allowed("d", .2)
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
end -- 374

love.load = function() -- 454
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 455
end -- 454
