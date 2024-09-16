--------------------------------
--Nightclub Options
--------------------------------
greyText(miscOptionsSub, "-------- Nightclub --------")

function mpx() return "MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_" end

miscOptionsSub:add_action("Make Nightclub Popular |🪩🕺🏻", function()
	stats.set_int(mpx() .. "CLUB_POPULARITY", 1000)
	displayHudBanner("BB_BM_PC_SUCC_S", "", "", 108)
end)

miscOptionsSub:add_action("$ Fill Nightclub Safe (!DONT ABUSE!) $", function()
	stats.set_int(mpx() .. "CLUB_POPULARITY", 1000)
	stats.set_int(mpx() .. "CLUB_PAY_TIME_LEFT", -1)
end)
---------------------- Sessanta Options ----------------------
greyText(miscOptionsSub, "-------- Sessanta Options --------")

miscOptionsSub:add_action("Trigger Sessanta Vehicle Delivery", function() newSessantaVehicle() end , function()
	return script("shop_controller"):is_active()
end)

local function buildSpecialExportSubmenu(sub)
	sub:clear()
	local specialExportVehicles = getSpecialExportVehiclesList()
	if not specialExportVehicles then
		addText(sub, "!!Couldn't get Export Vehicle List!!")
		addText(sub, "You have to be loaded into Online")
		addText(sub, "and own the Auto Shop!")
		return
	end
	addText(sub, "--- Special Export Vehicles: ---")
	greyText(sub, "Wait ~2 min between selling vehicles")
	greyText(sub, "or the transaction might fail")
	for i, hash in ipairs(specialExportVehicles) do
		local veh_name
		local veh_mods
		local veh_data = VEHICLE[hash]
		if not veh_data then
			veh_name = "Unknown :("
			veh_mods = empty_mods
		else
			veh_name = veh_data[1]
			veh_mods = generateRandomMods(veh_data[3])
		end
		sub:add_action("Spawn #" .. i .. ": " .. veh_name, function()
			local vector = localplayer:get_heading()
			local angle = math.deg(math.atan(vector.y, vector.x))
			local oldNetID = getNetIDOfLastSpawnedVehicle()
			createVehicle(hash, localplayer:get_position() + localplayer:get_heading() * 7, angle, false, veh_mods, true)
			sleep(0.1)
			local newNetID = getNetIDOfLastSpawnedVehicle()
			if newNetID ~= oldNetID then
				setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
			end
			sleep(0.2)
			createVehicle(hash, vector3(2000,2000,2000), angle) --Create a second vehicle, which causes the first one to be considered deliverable
			sleep(0.2)
			setWayPoint(1169.2, -2972.9)
		end)
	end
	greyText(sub, "-------------------------")
	sub:add_action("TP to Docks (Deliver instantly)", function() nativeTeleport(vector3(1169.2, -2972.9, 5)) end)
end
local specialExportSub
specialExportSub = miscOptionsSub:add_submenu("$🚗 Get Weekly Export Vehicles 🚗$", function() buildSpecialExportSubmenu(specialExportSub) end)

--------------------------Casino Options-----------------------------------
greyText(miscOptionsSub, "-------- Casino Options --------")
-----------------Podium Changer-------------------
--Create Vehicle Spawn Menu
--Pre-sort this table in order to only do it once
local sorted_vehicles = {}
for hash, vehicle in pairs(VEHICLE) do
	table.insert(sorted_vehicles, { hash, vehicle })
end
--sort by Name if classes are the same, otherwise sort by class
table.sort(sorted_vehicles, function(a, b)
	if a[2][2] == b[2][2] then
		return a[2][1]:upper() < b[2][1]:upper()
	end
	return a[2][2] < b[2][2]
end)

local oldPodiumVehicle
local function podiumChanger(sub)
	sub:clear()
	addText(sub, "WARNING! This can corrupt garage spots!")
	addText(sub, "Be careful which vehicle you obtain!")
	addText(sub, "I am NOT responsible for your garages!")
	addText(sub, "--------------------------------------")
	local vehSubs = {}

	-- vehicle = { hash, { name, class} }
	for _, vehicle in ipairs(sorted_vehicles) do
		local current_category = vehicle[2][2]
		if vehSubs[current_category] == nil then
			vehSubs[current_category] = sub:add_submenu(current_category)
		end

		vehSubs[current_category]:add_action(vehicle[2][1], function()
			if not oldPodiumVehicle then
				oldPodiumVehicle = getPodiumVehicle()
				greyText(sub, "------------------------")
				sub:add_action("Reset Podium Vehicle to " .. VEHICLE[oldPodiumVehicle][1], function()
					setPodiumVehicle(oldPodiumVehicle)
				end)
			end
			setPodiumVehicle(vehicle[1])
		end)
	end

	if oldPodiumVehicle and getPodiumVehicle() ~= oldPodiumVehicle then
		greyText(sub, "------------------------")
		sub:add_action("Reset Podium Vehicle to " .. VEHICLE[oldPodiumVehicle][1], function()
			setPodiumVehicle(oldPodiumVehicle)
		end)
	end
end
local podiumSub
podiumSub = miscOptionsSub:add_submenu("\u{26A0} Change Casino Podium vehicle \u{26A0} ", function() podiumChanger(podiumSub) end)