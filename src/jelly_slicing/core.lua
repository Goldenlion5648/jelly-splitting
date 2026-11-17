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

local test = Rectangle(4) -- 73

local main_font = love.graphics.newFont("CourierPrime-Regular.ttf", 28) -- 76
local is_using_mouse_for_nav = false -- 77
local rects = { } -- 78
local goal = { } -- 79
local undo_stack = { } -- 80

local squish_sounds -- 82
do -- 82
	local _accum_0 = { } -- 82
	local _len_0 = 1 -- 82
	for i = 1, 3 do -- 82
		_accum_0[_len_0] = love.audio.newSource("sounds/squish" .. tostring(i) .. ".wav", "static") -- 82
		_len_0 = _len_0 + 1 -- 82
	end -- 82
	squish_sounds = _accum_0 -- 82
end -- 82
local scream_sounds -- 83
do -- 83
	local _accum_0 = { } -- 83
	local _len_0 = 1 -- 83
	for i = 1, 3 do -- 83
		_accum_0[_len_0] = love.audio.newSource("sounds/scream" .. tostring(i) .. ".wav", "static") -- 83
		_len_0 = _len_0 + 1 -- 83
	end -- 83
	scream_sounds = _accum_0 -- 83
end -- 83
local deny_sound = love.audio.newSource("sounds/deny.wav", "static") -- 84
local slide_sound = love.audio.newSource("sounds/slide1.wav", "static") -- 85
local undo_sound = love.audio.newSource("sounds/undo.wav", "static") -- 86
local win_sound = love.audio.newSource("sounds/win.wav", "static") -- 87
local selected_index = 1 -- 88
local kb = { } -- 89
local SMALLEST_SIZE_ALLOWED = 20 -- 90

-- macro hide_errors = (hide_errors) ->
--   global debugMode = debugging == "true"
--   ""
local hide_errors = true -- 95

if hide_errors then -- 97
	love.errorhandler = function(msg) -- 98
		msg = tostring(msg) -- 99
		print(msg) -- 100
		return love.graphics.print(msg, 10, 10) -- 102
	end -- 98
end -- 97

local has_done_initial_setup = false -- 104
local is_showing_goal_overlay = true -- 105
local has_won_current = false -- 106
local current_level = 1 -- 107
local split_rect_at -- 108
local start_next_level_cooldown = 0 -- 109

local make_goal -- 111
make_goal = function() -- 111
	goal = { } -- 112
	table.insert(goal, Rectangle(10, 10, 750, 400)) -- 113
	math.randomseed(current_level) -- 114
	if current_level == 1 then -- 115
		for i = 1, 4 do -- 116
			split_rect_at(goal, math.random(#goal)) -- 117
		end -- 116
	elseif current_level == 2 then -- 118
		for i = 1, 5 do -- 119
			split_rect_at(goal, 1) -- 120
		end -- 119
	else -- 122
		for i = 1, 7 do -- 122
			split_rect_at(goal, math.random(#goal)) -- 123
		end -- 122
	end -- 115
end -- 111

is_showing_goal_overlay = false -- 125

local reset_state_as_needed -- 127
reset_state_as_needed = function() -- 127
	if has_done_initial_setup then -- 128
		return -- 129
	end -- 128
	rects = { } -- 130
	undo_stack = { } -- 131
	selected_index = 1 -- 132
	has_won_current = false -- 133
	table.insert(rects, Rectangle(10, 10, 750, 400)) -- 134
	make_goal() -- 135
	has_done_initial_setup = true -- 136
end -- 127

-- macro debugLog = ()->
--     if show_logs
--         print() 

local play_random_sound_from -- 143
play_random_sound_from = function(some_table) -- 143
	return some_table[math.random(#some_table)]:clone():play() -- 144
end -- 143

local on_split_success -- 146
on_split_success = function() -- 146
	if love.keyboard.isDown("lshift") then -- 147
		selected_index = #rects -- 148
	end -- 147
	play_random_sound_from(scream_sounds) -- 149
	return play_random_sound_from(squish_sounds) -- 150
end -- 146

local choose_random_from -- 152
choose_random_from = function(some_table) -- 152
	return some_table[math.random(#some_table)] -- 153
end -- 152

local add_to_undo_stack -- 155
add_to_undo_stack = function() -- 155
	do -- 156
		local _accum_0 = { } -- 156
		local _len_0 = 1 -- 156
		for _index_0 = 1, #rects do -- 156
			local rect = rects[_index_0] -- 156
			_accum_0[_len_0] = rect:get_clone() -- 156
			_len_0 = _len_0 + 1 -- 156
		end -- 156
		undo_stack[#undo_stack + 1] = _accum_0 -- 156
	end -- 156
	undo_stack[#undo_stack]["selected_index"] = selected_index -- 157
	-- print("end undo stack")
end -- 155

local remove_from_undo_stack -- 161
remove_from_undo_stack = function() -- 161
	if #undo_stack > 0 then -- 162
		do -- 163
			local _accum_0 = { } -- 163
			local _len_0 = 1 -- 163
			local _list_0 = undo_stack[#undo_stack] -- 163
			for _index_0 = 1, #_list_0 do -- 163
				local rect = _list_0[_index_0] -- 163
				_accum_0[_len_0] = rect:get_clone() -- 163
				_len_0 = _len_0 + 1 -- 163
			end -- 163
			rects = _accum_0 -- 163
		end -- 163
		selected_index = undo_stack[#undo_stack]["selected_index"] -- 164
		undo_stack[#undo_stack] = nil -- 165
		return undo_sound:clone():play() -- 166
	else -- 168
		return deny_sound:clone():play() -- 168
	end -- 162
end -- 161

split_rect_at = function(to_split, index) -- 170
	do -- 171
		local _with_0 = to_split[index] -- 171
		if _with_0.width > _with_0.height then -- 172
			if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 173
				if to_split == rects then -- 174
					add_to_undo_stack() -- 175
				end -- 174
				local width_before = _with_0.width -- 176
				_with_0.width = _with_0.width / 2 -- 177
				local half_width = _with_0.width -- 178
				_with_0.age = 0 -- 179
				table.insert(to_split, Rectangle(_with_0.x + half_width, _with_0.y, half_width, _with_0.height)) -- 180
				if to_split == rects then -- 181
					on_split_success() -- 182
				end -- 181
				return -- 183
			end -- 173
		else -- 186
			if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 186
				if to_split == rects then -- 187
					add_to_undo_stack() -- 188
				end -- 187
				local height_before = _with_0.height -- 189
				_with_0.height = _with_0.height / 2 -- 190
				local half_height = _with_0.height -- 191
				_with_0.age = 0 -- 192
				table.insert(to_split, Rectangle(_with_0.x, _with_0.y + half_height, _with_0.width, half_height)) -- 193
				if to_split == rects then -- 194
					on_split_success() -- 195
				end -- 194
				return -- 196
			end -- 186
		end -- 172
	end -- 171
	-- deny_sound
	return deny_sound:clone():play() -- 198
end -- 170

local show_shadow_split_spot -- 200
show_shadow_split_spot = function(index) -- 200
	local _with_0 = rects[index] -- 201
	if _with_0.width > _with_0.height then -- 202
		if _with_0.width / 2 >= SMALLEST_SIZE_ALLOWED then -- 203
			local line_width = _with_0.width * .03 -- 204
			local half_line_width = line_width / 2 -- 205
			-- vertical line
			local width_before = _with_0.width -- 207
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.height * .1) -- 208
			local half_rect_width = _with_0.width / 2 -- 209
			love.graphics.rectangle("fill", _with_0.x + half_rect_width - half_line_width, _with_0.y + moving_offset, line_width, _with_0.height) -- 210
		end -- 203
	else -- 214
		if _with_0.height / 2 >= SMALLEST_SIZE_ALLOWED then -- 214
			local line_width = _with_0.height * .05 -- 215
			local half_line_width = line_width / 2 -- 216
			-- horizontal line
			local moving_offset = math.sin(love.timer.getTime() * 10) * (_with_0.width * .1) -- 218
			local height_before = _with_0.height -- 219
			local half_height = _with_0.height / 2 -- 220
			love.graphics.rectangle("fill", _with_0.x + moving_offset, _with_0.y + half_height - half_line_width, _with_0.width, line_width) -- 221
		end -- 214
	end -- 202
	return _with_0 -- 201
end -- 200

love.keypressed = function(key) -- 224
	if key == "r" then -- 225
		has_done_initial_setup = false -- 226
	end -- 225
	if ("q" == key or "escape" == key) then -- 227
		love.event.quit() -- 228
	end -- 227
	if key == 'a' then -- 229
		return love.event.quit() -- 230
	end -- 229
end -- 224

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

local never_pressed_time = -100 -- 257
local _anon_func_0 = function(kb, key, never_pressed_time) -- 259
	local _exp_0 = kb[key] -- 259
	if _exp_0 ~= nil then -- 259
		return _exp_0 -- 259
	else -- 259
		return never_pressed_time -- 259
	end -- 259
end -- 259
local was_just_pressed -- 258
was_just_pressed = function(key) -- 258
	local was_down_before = (_anon_func_0(kb, key, never_pressed_time)) > 0 -- 259
	-- $mark_key_state(key)
	if love.keyboard.isDown(key) then -- 261
		kb[key] = love.timer.getTime() -- 262
	else -- 264
		kb[key] = never_pressed_time -- 264
	end -- 261
	return love.keyboard.isDown(key) and not was_down_before -- 265
end -- 258

local repeat_kb = { } -- 267
local is_pressed_with_repeat_allowed -- 268
is_pressed_with_repeat_allowed = function(key, repeat_time) -- 268
	if repeat_time == nil then -- 268
		repeat_time = .3 -- 268
	end -- 268
	if not love.keyboard.isDown(key) then -- 269
		repeat_kb[key] = nil -- 270
		return false -- 271
	end -- 269
	if repeat_kb[key] == nil or love.timer.getTime() - repeat_kb[key] >= repeat_time then -- 272
		repeat_kb[key] = love.timer.getTime() -- 273
		return true -- 274
	end -- 272
	return false -- 275
end -- 268

local mouse_before = { } -- 277
local is_mouse_pressed_once -- 278
is_mouse_pressed_once = function() -- 278
	if not love.mouse.isDown(1) then -- 279
		mouse_before[1] = false -- 280
		return false -- 281
	end -- 279
	if love.mouse.isDown(1) then -- 282
		if not mouse_before[1] then -- 283
			mouse_before[1] = true -- 284
			return true -- 285
		end -- 283
	end -- 282
	return false -- 286
end -- 278

local bring_focus_to_neighbors -- 288
bring_focus_to_neighbors = function() -- 288
	local x_offset = 0 -- 289
	local y_offset = 0 -- 290
	if is_pressed_with_repeat_allowed("left") then -- 291
		x_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 292
		is_using_mouse_for_nav = false -- 293
	end -- 291
	if is_pressed_with_repeat_allowed("right") then -- 294
		x_offset = SMALLEST_SIZE_ALLOWED / 2 -- 295
		is_using_mouse_for_nav = false -- 296
	end -- 294

	if is_pressed_with_repeat_allowed("up") then -- 298
		y_offset = -SMALLEST_SIZE_ALLOWED / 2 -- 299
		is_using_mouse_for_nav = false -- 300
	end -- 298
	if is_pressed_with_repeat_allowed("down") then -- 301
		y_offset = SMALLEST_SIZE_ALLOWED / 2 -- 302
		is_using_mouse_for_nav = false -- 303
	end -- 301

	if x_offset == 0 and y_offset == 0 then -- 305
		return -- 306
	end -- 305

	local cur_x, cur_y = rects[selected_index]:get_center(-SMALLEST_SIZE_ALLOWED / 2, -SMALLEST_SIZE_ALLOWED / 2) -- 308
	if love.keyboard.isDown("lshift") then -- 309
		cur_x, cur_y = rects[selected_index]:get_center(SMALLEST_SIZE_ALLOWED / 2, SMALLEST_SIZE_ALLOWED / 2) -- 310
	end -- 309

	local screen_size_x = 800 -- 312
	local screen_size_y = 450 -- 313
	while -10 <= cur_x and cur_x <= screen_size_x and -10 <= cur_y and cur_y <= screen_size_y do -- 314
		cur_x = cur_x + x_offset -- 315
		cur_y = cur_y + y_offset -- 316
		-- print(cur_y, cur_x)
		for i, rect in ipairs(rects) do -- 318
			local _continue_0 = false -- 319
			repeat -- 319
				if rect == rects[selected_index] then -- 319
					_continue_0 = true -- 320
					break -- 320
				end -- 319
				if rect:contains(cur_x, cur_y) then -- 321
					-- love.audio.play(slide_sound)
					slide_sound:clone():play() -- 323
					selected_index = i -- 324
					return -- 325
				end -- 321
				_continue_0 = true -- 319
			until true -- 319
			if not _continue_0 then -- 319
				break -- 319
			end -- 319
		end -- 318
	end -- 314
end -- 288

local did_slice_action -- 327
did_slice_action = function(repeat_time) -- 327
	if repeat_time == nil then -- 327
		repeat_time = .3 -- 327
	end -- 327
	if has_won_current then -- 328
		return false -- 329
	end -- 328
	return is_pressed_with_repeat_allowed("s", repeat_time) or is_pressed_with_repeat_allowed("space", repeat_time) or is_pressed_with_repeat_allowed("return", repeat_time) or is_mouse_pressed_once() -- 330
end -- 327

local old_mouse_pos_x = -10 -- 335
local old_mouse_pos_y = -10 -- 336
local pingpong -- 337
pingpong = function(value, lower, upper) -- 337
	local dist = (upper - lower) -- 338
	if math.floor(value / dist) % 2 == 1 then -- 339
		local amount_over = value % dist -- 340
		return upper - amount_over -- 341
	end -- 339
	return (value % dist) + lower -- 342
end -- 337

local does_match_goal -- 344
does_match_goal = function() -- 344
	for _index_0 = 1, #goal do -- 345
		local rect_to_find = goal[_index_0] -- 345
		local found = false -- 346
		for _index_1 = 1, #rects do -- 347
			local player_placed = rects[_index_1] -- 347
			if rect_to_find:get_hash() == player_placed:get_hash() then -- 348
				found = true -- 349
				break -- 350
			end -- 348
		end -- 347
		if not found then -- 351
			return false -- 352
		end -- 351
	end -- 345
	return true -- 353
end -- 344

love.update = function(dt) -- 356
	if love.window.hasFocus() then -- 358
	end -- 358
	reset_state_as_needed() -- 360
	-- print("before", is_using_mouse_for_nav)
	local mouse_pos_x, mouse_pos_y = love.mouse.getPosition() -- 362
	if old_mouse_pos_x ~= mouse_pos_x or old_mouse_pos_y ~= mouse_pos_y then -- 363
		old_mouse_pos_x = mouse_pos_x -- 364
		old_mouse_pos_y = mouse_pos_y -- 365
		is_using_mouse_for_nav = true -- 366
		-- print(old_mouse_pos_x, old_mouse_pos_y)
	end -- 363
	-- print("after", is_using_mouse_for_nav)
	if was_just_pressed("tab") or was_just_pressed("t") or was_just_pressed("c") then -- 369
		is_showing_goal_overlay = not is_showing_goal_overlay -- 370
	end -- 369

	if is_pressed_with_repeat_allowed("z", .3) then -- 372
		remove_from_undo_stack() -- 373
	end -- 372

	if is_using_mouse_for_nav then -- 375
		for i, rect in ipairs(rects) do -- 376
			if rect:contains(mouse_pos_x, mouse_pos_y) then -- 377
				selected_index = i -- 378
				break -- 379
			end -- 377
		end -- 376
	end -- 375

	if does_match_goal() and not has_won_current then -- 381
		print("matches") -- 382
		has_won_current = true -- 383
		current_level = current_level + 1 -- 384
		win_sound:clone():play() -- 385
		start_next_level_cooldown = 60 -- 386
	end -- 381

	start_next_level_cooldown = math.max(start_next_level_cooldown - 1, 0) -- 388
	if start_next_level_cooldown == 1 then -- 389
		has_done_initial_setup = false -- 390
	end -- 389

	-- if love.keyboard.isDown "escape"
	if did_slice_action() then -- 394
		split_rect_at(rects, selected_index) -- 395
	end -- 394
	bring_focus_to_neighbors() -- 396
	return love.graphics.setBackgroundColor(0.5, 0.8, 0.5, 1) -- 397
end -- 356

love.draw = function() -- 399
	love.graphics.setFont(main_font) -- 400
	local tile_size = 100 -- 401
	-- print(mouse_pos_x, mouse_pos_y)
	local should_draw = { -- 403
		true -- 403
	} -- 403
	if is_showing_goal_overlay then -- 404
		should_draw[#should_draw + 1] = true -- 405
	end -- 404
	local rect_tables = { -- 406
		rects, -- 406
		goal -- 406
	} -- 406
	for table_num, rect_table in ipairs(rect_tables) do -- 407
		if not should_draw[table_num] then -- 408
			return -- 409
		end -- 408
		for i, rect in ipairs(rect_table) do -- 410
			rect.age = rect.age + 1 -- 411
			local normal_view_alpha = 1 -- 412
			local ghost_alpha = ((math.sin(love.timer.getTime() * 3) + 1) / 16.0) + .2 -- 413
			if table_num == 1 then -- 414
				if is_showing_goal_overlay then -- 415
					normal_view_alpha = .2 -- 415
				else -- 415
					normal_view_alpha = 1 -- 415
				end -- 415
				if i == selected_index then -- 416
					love.graphics.setColor(.8, .6, .1, normal_view_alpha) -- 417
				else -- 419
					love.graphics.setColor(.3, .6, .7, normal_view_alpha) -- 419
				end -- 416
			end -- 414
			if table_num == 2 then -- 420
				love.graphics.setColor(.3, .2, .0, ghost_alpha) -- 421
			end -- 420

			if table_num == 1 then -- 424
				love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height) -- 425
				local shrink_amount = rect.height * .05 -- 426
				local r, g, b, a = love.graphics.getColor() -- 427
				love.graphics.setColor(r, g * .75, b, a) -- 428
				love.graphics.rectangle("fill", rect.x + shrink_amount, rect.y + shrink_amount, rect.width - (shrink_amount * 2), rect.height - (shrink_amount * 2)) -- 429
			end -- 424
			if table_num == 1 then -- 430
				love.graphics.setColor(0, 0, 0, normal_view_alpha) -- 431
			else -- 433
				love.graphics.setColor(1, 1, 0, ghost_alpha) -- 433
			end -- 430
			love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height) -- 434
			local eye_dist_from_center_x = rect.width / 5.0 -- 435
			local eye_dist_from_center_y = rect.height / 8.0 -- 436
			local mouth_dist_from_center_y = rect.height / 10.0 -- 437
			local center_x, center_y = rect:get_center() -- 438
			local x_radius = rect.width / 16.0 -- 439
			local y_radius = rect.width / 16.0 -- 440
			math.randomseed(rect:get_hash()) -- 441
			local eye_shake_time = 60 -- 442
			local mouth_size = math.min(rect.height, rect.width) * .03 -- 443
			local eye_offset = 0 -- 444
			if rect.age < eye_shake_time then -- 445
				eye_offset = ((eye_shake_time - rect.age) ^ (1.6 - rect.age / eye_shake_time)) / 10 -- 446
			end -- 445
			love.graphics.ellipse("fill", center_x + eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y + eye_offset, x_radius, y_radius) -- 447
			love.graphics.ellipse("fill", center_x - eye_dist_from_center_x, center_y + -1 * eye_dist_from_center_y - eye_offset, x_radius, y_radius) -- 448
			local mouth_func -- 449
			mouth_func = function(func) -- 449
				local clamped = math.min(rect.age, 30) -- 450
				return ((func(clamped / 1.5 + rect:get_hash()) + 3) * mouth_size) -- 451
			end -- 449
			love.graphics.ellipse("fill", center_x, center_y + mouth_dist_from_center_y, mouth_func(math.cos), mouth_func(math.sin)) -- 452

			if table_num == 1 then -- 455
				show_shadow_split_spot(selected_index) -- 456
			end -- 455
			love.graphics.setColor(1, 1, 1, 1) -- 457
		end -- 410
		love.graphics.print("Read instructions below", 10, 420) -- 458
	end -- 407
	-- love.graphics.rectangle("fill", 10, 10, tile_size, tile_size)s
	return love.graphics.setColor(1, 1, 1) -- 460
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
end -- 399

love.load = function() -- 480
	return love.graphics.setBackgroundColor(0.5, 0.1, 0.5, 1) -- 481
end -- 480
