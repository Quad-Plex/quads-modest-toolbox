--Thanks to Alice2333 on UKC!
toolbox:add_action("finish mission/heist", function()
	if script("fm_mission_controller"):is_active() then
		if script("fm_mission_controller"):get_bool(3234) then
			script("fm_mission_controller"):set_int(31672, joaat("Quad_Plex"))
			script("fm_mission_controller"):set_int(19728, 12)
		end
	end
	if script("fm_mission_controller_2020"):is_active() then
		if script("fm_mission_controller_2020"):get_bool(18943) then
			script("fm_mission_controller_2020"):set_int(50279, joaat("Quad_Plex"))
			script("fm_mission_controller_2020"):set_int(48513, 9)
		end
	end
end)