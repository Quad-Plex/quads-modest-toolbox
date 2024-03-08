require("scripts/quads_toolbox/toolbox_data/globals_and_utils")
--------------------------------
--UNDEAD OFFRADAR
--------------------------------
local function offradar()
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

menu.register_hotkey(121, offradar) --F10