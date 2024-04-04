local noclipToggle = false
local speed = 2
local hotkeys = {}

local function getEntity()
	if localplayer:is_in_vehicle() then
		return localplayer:get_current_vehicle()
	else
		return localplayer
	end
end

local function move(direction)
	if not noclipToggle then return end
	local entity = getEntity()
	local newPos = entity:get_position() + direction
	entity:set_position(newPos)
end

local function rotate(amount)
	if not noclipToggle then return end
	local entity = getEntity()
	local direction = entity:get_rotation()
	entity:set_rotation(direction + vector3(amount,0,0))
end


local function adjustSpeed(amount)
	if speed + amount > 0 then
		speed = speed + amount
	end
end

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
			setPhoneDisabled(true)
		else
			setPhoneDisabled(false)
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
