-----------------------------------
--Original Script by Quad_Plex
--V2.1 updated for gta 2944
-----------------------------------#
require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")

local weapon_data = {}
local enabled = false
local isActive = false
local function spawnCarWhereAiming()
	if not enabled then return end
	isActive = true
	--check weapon hit force and put in table
	local weapon = localplayer:get_current_weapon()
	if weapon ~= nil then
		local force = weapon:get_vehicle_force()
		if force ~= nil and force < 100000 then
			weapon_data[weapon:get_name_hash()] = force
			weapon:set_vehicle_force(99900000)
		end
	end
	local spawnPos = (localplayer:get_position() + localplayer:get_heading()*2.4)
	if localplayer:is_in_vehicle() then
		spawnPos = localplayer:get_position() + (localplayer:get_heading() * 10) + (localplayer:get_velocity()*0.9)
	end
	local angle = math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x))
	if angle < 0 then angle = angle + 360 end
	createVehicle(joaat("Youga4"), spawnPos + vector3(0,0,1), angle)
	sleep(0.2)
	isActive = false
end

local hotkey
local function carAPult()
	if not localplayer or localplayer == nil then return end
	
	enabled = not enabled
	if enabled then
		--register hotkey to left click for continually spawning cars
		hotkey = menu.register_hotkey(1, function() if not isActive then spawnCarWhereAiming() end end)
		displayHudBanner("GR_PWD_LA", "PIM_NCL_PRIV1","", 109)
	else
		--reset weapon hit force from table
		local weapon = localplayer:get_current_weapon()
		if weapon ~= nil and weapon:get_vehicle_force() == 99900000 then
			local force = weapon_data[weapon:get_name_hash()]
			if force ~= nil then
				weapon:set_vehicle_force(force)
			end
		end
		
		--unregister hotkey
		menu.remove_hotkey(hotkey)
		displayHudBanner("GR_PWD_LA", "PIM_NCL_PRIV0", "", 109)
	end
end

toolbox:add_toggle("Enable Car-A-Pult", function() return enabled end, carAPult)

--multiply key on numpad
menu.register_hotkey(106, carAPult)