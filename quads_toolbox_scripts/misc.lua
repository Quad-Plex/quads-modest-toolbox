--displayboxtype = 39
--menu.add_int_range("Display Box Type Tester", 1, -100, 500, function()
--	return displayboxtype
--end, function(n)
--	displayboxtype = n
--	displayHudBanner("EPS_CASH", "~s~", 0, n, true)
--end)

--------------------------------
--Nightclub Popularity
--------------------------------

function mpx() return "MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_" end --Returns 0 or 1

miscOptionsSub:add_action("Make Nightclub Popular", function()
	stats.set_int(mpx() .. "CLUB_POPULARITY", 1000)
end)

--------------------------------
--Snack refill
--------------------------------

local function refillInventory()
	stats.set_int(mpx().."NO_BOUGHT_YUM_SNACKS", 30)
	stats.set_int(mpx().."NO_BOUGHT_HEALTH_SNACKS", 15)
	stats.set_int(mpx().."NO_BOUGHT_EPIC_SNACKS", 5)
	stats.set_int(mpx().."NUMBER_OF_ORANGE_BOUGHT", 10)
	stats.set_int(mpx().."NUMBER_OF_BOURGE_BOUGHT", 10)
	stats.set_int(mpx().."NUMBER_OF_CHAMP_BOUGHT", 5)
	stats.set_int(mpx().."CIGARETTES_BOUGHT", 20)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_1_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_2_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_3_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_4_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_5_COUNT", 10)
end

miscOptionsSub:add_action("Refill Inventory", function()
	refillInventory()
end)

----------------Sessanta shit------------------
baseGlobals.sessantaShit = {}
baseGlobals.sessantaShit.base_local = 307
local function newSessantaVehicle()
	local shop_controller = script("shop_controller")
	if shop_controller and shop_controller:is_active() then
		stats.set_int("MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_TUNER_CLIENT_VEHICLE_POSSIX", 1)
		shop_controller:set_int(baseGlobals.sessantaShit.base_local + 1, 0)
		shop_controller:set_int(baseGlobals.sessantaShit.base_local + 2, 0)
		shop_controller:set_int(baseGlobals.sessantaShit.base_local + 3, 1)
		shop_controller:set_int(baseGlobals.sessantaShit.base_local, 3)
	end
end
baseGlobals.sessantaShit.testFunction = function()
	newSessantaVehicle()
end
baseGlobals.sessantaShit.testFunctionExplanation = "Trigger new Sessanta Vehicle"
miscOptionsSub:add_action("New Sessanta Vehicle", function() newSessantaVehicle() end , function()
	return script("shop_controller"):is_active()
end)


-----------------Podium Changer-------------------
--Create Vehicle Spawn Menu
--Pre-sort this table so we only do it once
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

local function podiumChanger(sub)
	sub:clear()
	text(sub, "WARNING! This can corrupt garage spots!")
	text(sub, "Be careful which vehicle you obtain!")
	text(sub, "I am NOT responsible for your garages!")
	text(sub, "--------------------------------------")
	local vehSubs = {}

	-- vehicle = { hash, { name, class} }
	for _, vehicle in ipairs(sorted_vehicles) do
		local current_category = vehicle[2][2]
		if vehSubs[current_category] == nil then
			vehSubs[current_category] = sub:add_submenu(current_category)
		end

		vehSubs[current_category]:add_action(vehicle[2][1], function()
			setPodiumVehicle(vehicle[1])
		end)
	end
end
local podiumSub
podiumSub = miscOptionsSub:add_submenu("\u{26A0} Change Casino Podium vehicle \u{26A0} ", function() podiumChanger(podiumSub) end)