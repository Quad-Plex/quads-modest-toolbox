local noclipToggle = false
local speed = 2
local hotkeys = {}
local initialPos
local initialHeading
local initialRotation
local initialYawAngle
local initialPitchAngle

local function getLocalplayerOrCar()
	if localplayer:is_in_vehicle() then
		return localplayer:get_current_vehicle()
	else
		return localplayer
	end
end

local function move(direction)
	if not noclipToggle then return end
	initialPos = initialPos + direction
	if not localplayer:is_in_vehicle() then
		nativeTeleport(initialPos, initialHeading)
	else
		nativeTeleport(initialPos, vector3(initialYawAngle, 0, initialPitchAngle))
		initialHeading = localplayer:get_heading()
	end
end

local function rotate(amount, pitch)
	if not noclipToggle then return end
	local entity = getLocalplayerOrCar()
	if not localplayer:is_in_vehicle() then
		initialRotation = initialRotation + vector3(amount,0,0)
		entity:set_rotation(initialRotation)
		initialHeading = entity:get_heading()
	else
		if not pitch then
			initialYawAngle = initialYawAngle + amount * 90
			nativeTeleport(initialPos, vector3(initialYawAngle, 0, initialPitchAngle))
			initialHeading = entity:get_heading()
		else
			initialPitchAngle = initialPitchAngle + amount * 90
			if initialPitchAngle > 89 then initialPitchAngle = 89 end
			if initialPitchAngle < -89 then initialPitchAngle = -89 end
			nativeTeleport(initialPos, vector3(initialYawAngle, 0, initialPitchAngle))
			initialHeading = entity:get_heading()
		end
	end
end

local function adjustSpeed(amount)
	if speed * amount > 1 then
		speed = speed * amount
	end
end

local oldGrav
local oldGodmode
function noclip(toggle, skipBanner)
	if localplayer ~= nil then
		if toggle then
			if localplayer:is_in_vehicle() then
				oldGrav = localplayer:get_current_vehicle():get_gravity()
				oldGodmode = localplayer:get_current_vehicle():get_godmode()
				localplayer:get_current_vehicle():set_gravity(0)
			end
			localplayer:set_freeze_momentum(true)
			localplayer:set_no_ragdoll(true)
			localplayer:set_config_flag(292, true)
			nativeTeleport(localplayer:get_position())
			initialPos = localplayer:get_position()
			initialHeading = localplayer:get_heading()
			initialRotation = localplayer:get_rotation()
			initialYawAngle = math.deg(math.atan(initialHeading.y, initialHeading.x)) - 90
			initialPitchAngle = math.deg(math.atan(initialHeading.z, math.sqrt(initialHeading.x^2 + initialHeading.y^2)))
			hotkeys = {
				menu.register_hotkey(keycodes.SHIFT_KEY, function()
					if not localplayer:is_in_vehicle() then
						move(vector3(0,0,speed))
					else
						rotate(-0.2, true)
					end
				end),
				menu.register_hotkey(keycodes.CTRL_KEY, function()
					if not localplayer:is_in_vehicle() then
						move(vector3(0,0,speed * -1))
					else
						rotate(0.2, true)
					end
				end),
				menu.register_hotkey(keycodes.W_KEY, function() move(initialHeading * speed) end),
				menu.register_hotkey(keycodes.S_KEY, function() move(initialHeading * speed * -1) end),
				menu.register_hotkey(keycodes.A_KEY, function() rotate(0.25) end),
				menu.register_hotkey(keycodes.D_KEY, function() rotate(0.25 * -1) end),
				menu.register_hotkey(keycodes.ADD_KEY, function() adjustSpeed(2) end),
				menu.register_hotkey(keycodes.SUBTRACT_KEY, function() adjustSpeed(0.5) end)
			}
			if not skipBanner then
				displayHudBanner("SG_CLIP", "PIM_NCL_PRIV1", "", 108)
			end
		else
			speed = 2
			if oldGrav and localplayer:is_in_vehicle() and localplayer:get_current_vehicle():get_gravity() == 0 then
				localplayer:get_current_vehicle():set_gravity(oldGrav)
			end
			localplayer:set_freeze_momentum(false)
			localplayer:set_no_ragdoll(false)
			localplayer:set_config_flag(292, false)
			for _, hotkey in ipairs(hotkeys) do
				menu.remove_hotkey(hotkey)
			end
			hotkeys = {}
			if not skipBanner then
				displayHudBanner("SG_CLIP", "PIM_NCL_PRIV0", "", 108)
			end
			oldGrav = nil
			sleep(0.3)
			if localplayer:is_in_vehicle() then
				setPlayerRespawnState(getLocalplayerID(), 9) --fix the vehicle being stuck
				if oldGodmode then
					local vehicle = localplayer:get_current_vehicle()
					sleep(3) --the nativeteleport removes godmode, so we gotta wait for that to happen and re-enable
					for _ = 0, 12 do
						vehicle:set_godmode(oldGodmode)
						sleep(0.08)
					end
				end
			end
			fixPedVehTeleport()
		end
	end
end

miscOptionsSub:add_toggle("Noclip:|🚀", function() return noclipToggle end, function(n) noclipToggle = n noclip(noclipToggle)  end)
miscOptionsSub:add_int_range("|Noclip Speed: ", 1, 0, 100, function() return speed end, function(v) speed=v end)


--Numpad Divide Key
local noclipHotkey
menu.register_callback('ToggleNoclipHotkey', function()
	if not noclipHotkey then
		noclipHotkey = menu.register_hotkey(find_keycode("ToggleNoclipHotkey"), function()
			noclipToggle = not noclipToggle
			noclip(noclipToggle)
		end)
	else
		menu.remove_hotkey(noclipHotkey)
		noclipHotkey = nil
	end
end)
