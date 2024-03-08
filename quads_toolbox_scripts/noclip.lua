require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")
local enable = false
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
	if not enable then return end
	local entity = getEntity()
	local newPos = entity:get_position() + direction
	entity:set_position(newPos)
end

local function rotate(amount)
	if not enable then return end
	local entity = getEntity()
	local direction = entity:get_rotation()
	entity:set_rotation(direction + vector3(amount,0,0))
end


local function adjustSpeed(amount)
	if speed + amount > 0 then
		speed = speed + amount
	end
end

local function NoClip(noclipToggle)
	if localplayer ~= nil then
		if noclipToggle then
			localplayer:set_freeze_momentum(true)
			localplayer:set_no_ragdoll(true)
			localplayer:set_config_flag(292, true)
			hotkeys = {
				menu.register_hotkey(16, function() move(vector3(0,0,speed)) end),
				menu.register_hotkey(17, function() move(vector3(0,0,speed * -1)) end),
				menu.register_hotkey(38, function() move(localplayer:get_heading() * speed) end),
				menu.register_hotkey(40, function() move(localplayer:get_heading() * speed * -1) end),
				menu.register_hotkey(37, function() rotate(0.25) end),
				menu.register_hotkey(39, function() rotate(0.25 * -1) end),
				menu.register_hotkey(107, function() adjustSpeed(1) end),
				menu.register_hotkey(109, function() adjustSpeed(-1) end)
			}
			displayHudBanner("PSF_FLYING", "PIM_NCL_PRIV1", "", 109)
		else
			localplayer:set_freeze_momentum(false)
			localplayer:set_no_ragdoll(false)
			localplayer:set_config_flag(292, false)
			for _, hotkey in ipairs(hotkeys) do
				menu.remove_hotkey(hotkey)
			end
			hotkeys = {}
			displayHudBanner("PSF_FLYING", "PIM_NCL_PRIV0", "", 109)
		end
	end
end

menu.register_hotkey(111, function()
	enable = not enable
	NoClip(enable)
end)
