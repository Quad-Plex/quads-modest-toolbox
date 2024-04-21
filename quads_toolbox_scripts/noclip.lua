local noclipToggle = false
local speed = 2
local hotkeys = {}

local function getLocalplayerOrCar()
	if localplayer:is_in_vehicle() then
		return localplayer:get_current_vehicle()
	else
		return localplayer
	end
end

function nativeTeleport(vector)
	if ((localplayer:get_pedtype() == 2) and not localplayer:is_in_vehicle()) then -- localplayer is netplayer and not in vehicle
		globals.set_float(4521801 + 946 + 0, vector.x)
		globals.set_float(4521801 + 946 + 1, vector.y)
		globals.set_float(4521801 + 946 + 2, vector.z)
		globals.set_float(4521801 + 949, math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x)) - 90)
		globals.set_int(4521801 + 943, 20)
		repeat
		until (globals.get_int(4521801 + 943) ~= 20)
		globals.set_int(4521801 + 943, -1)
	elseif localplayer:is_in_vehicle() then
		localplayer:get_current_vehicle():set_position(vector)
	end
end

local function move(direction)
	if not noclipToggle then return end
	local tpPos = localplayer:get_position()
	if not localplayer:is_in_vehicle() then tpPos = tpPos + vector3(0,0,0.3) end
	nativeTeleport(tpPos + direction)
end

local function rotate(amount)
	if not noclipToggle then return end
	local entity = getLocalplayerOrCar()
	local direction = entity:get_rotation()
	entity:set_rotation(direction + vector3(amount,0,0))
end


local function adjustSpeed(amount)
	if speed + amount > 0 then
		speed = speed + amount
	end
end

local oldPhoneDisableState
local function NoClip(toggle)
	if localplayer ~= nil then
		if toggle then
			localplayer:set_freeze_momentum(true)
			localplayer:set_no_ragdoll(true)
			localplayer:set_config_flag(292, true)
			hotkeys = {
				menu.register_hotkey(keycodes.SHIFT_KEY, function() move(vector3(0,0,speed)) end),
				menu.register_hotkey(keycodes.CTRL_KEY, function() move(vector3(0,0,speed * -1)) end),
				menu.register_hotkey(keycodes.UP_ARROW_KEY, function() move(localplayer:get_heading() * speed) end),
				menu.register_hotkey(keycodes.DOWN_ARROW_KEY, function() move(localplayer:get_heading() * speed * -1) end),
				menu.register_hotkey(keycodes.LEFT_ARROW_KEY, function() rotate(0.25) end),
				menu.register_hotkey(keycodes.RIGHT_ARROW_KEY, function() rotate(0.25 * -1) end),
				menu.register_hotkey(keycodes.ADD_KEY, function() adjustSpeed(1) end),
				menu.register_hotkey(keycodes.SUBTRACT_KEY, function() adjustSpeed(-1) end)
			}
			displayHudBanner("SG_CLIP", "PIM_NCL_PRIV1", "", 109)
			oldPhoneDisableState = phoneDisabledState
			setPhoneDisabled(true, true)
		else
			setPhoneDisabled(oldPhoneDisableState, true)
			localplayer:set_freeze_momentum(false)
			localplayer:set_no_ragdoll(false)
			localplayer:set_config_flag(292, false)
			for _, hotkey in ipairs(hotkeys) do
				menu.remove_hotkey(hotkey)
			end
			hotkeys = {}
			displayHudBanner("SG_CLIP", "PIM_NCL_PRIV0", "", 109)
		end
	end
end

miscOptionsSub:add_toggle("Noclip:|🚀", function() return noclipToggle end, function(n) noclipToggle = n NoClip(noclipToggle)  end)


--Numpad Divide Key
local noclipHotkey
menu.register_callback('ToggleNoclipHotkey', function()
	if not noclipHotkey then
		noclipHotkey = menu.register_hotkey(find_keycode("ToggleNoclipHotkey"), function()
			noclipToggle = not noclipToggle
			NoClip(noclipToggle)
		end)
	else
		menu.remove_hotkey(noclipHotkey)
		noclipHotkey = nil
	end
end)
