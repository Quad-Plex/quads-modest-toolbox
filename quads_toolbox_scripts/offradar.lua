--------------------------------
--UNDEAD OFFRADAR
--------------------------------
local function offRadar()
	if localplayer ~= nil then 
		if localplayer:get_max_health() > 100 then
			localplayer:set_max_health(0.0)
			displayHudBanner("PM_UCON_T32", "CANNON_CAM_ACTIVE", "", 109)
		else
			localplayer:set_max_health(328.0)
			displayHudBanner("PM_UCON_T32", "CANNON_CAM_INACTIVE", "", 109)
		end
	end
end

miscOptionsSub:add_toggle("Undead Offradar:", function()
    return localplayer:get_max_health() == 0.0
end, function(_)
    offRadar()
end)

local offradarHotkey
menu.register_callback('ToggleOffradarHotkey', function()
	if not offradarHotkey then
		offradarHotkey = menu.register_hotkey(keycodes.F10_KEY, offRadar)
	else
		menu.remove_hotkey(offradarHotkey)
		offradarHotkey = nil
	end
end)