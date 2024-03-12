-------------------------------
-- Original Script by Quad_Plex
-- Pickup-Suite v0.4.20
-------------------------------

--TODO: Check if PICKUP_PORTABLE_FM_CONTENT_MISSION_ENTITY_SMALL can be created this way
--Could be used to create tr_prop_tr_chest_01a movie prop pickups

local sorted_model_names = {}
local duplicate_models = {}
for _, model_name in pairs(MODELS) do
	if duplicate_models[model_name:upper()] == nil then
		duplicate_models[model_name:upper()] = "there can be only one"
		table.insert(sorted_model_names, { model_name })
	else
		print("Duplicate Model Found! " .. model_name)
	end
end
table.sort(sorted_model_names, function(a, b)
	return a[1]:upper() < b[1]:upper()
end)

local sorted_pickup_names = {}
local duplicate_pickups = {}
for _, pickup_name in pairs(PICKUPS) do
	if duplicate_pickups[pickup_name:upper()] == nil then
		duplicate_pickups[pickup_name:upper()] = "there can be only one"
		table.insert(sorted_pickup_names, { pickup_name })
	else
		print("Duplicate Pickup Found! " .. pickup_name)
	end
end
table.sort(sorted_pickup_names, function(a, b)
	return a[1]:upper() < b[1]:upper()
end)

local function getPickupName(pickup)
	local pickupName = PICKUPS[pickup:get_pickup_hash()]
	if not pickupName then
		return "Not found!: ".. pickup:get_pickup_hash()
	else
		return pickupName
	end
end

local function getModelName(pickup)
	local modelName = MODELS[pickup:get_model_hash()]
	if not modelName then
		return "Not found!: ".. pickup:get_model_hash()
	else
		return modelName
	end
end

local function teleportCloseToPickup(pickup)
	--teleport just in front of the pickup, without collecting it
	if localplayer:is_in_vehicle() then
		localplayer:get_current_vehicle():set_position(pickup:get_position() + (localplayer:get_heading() * -2.4))
	else
		localplayer:set_position(pickup:get_position() + (localplayer:get_heading() * -2.4))
	end
end

local function tpToPickup(pickup)
	local pickupPos = pickup:get_position()
	localplayer:set_position(pickupPos + vector3(0,0,-0.35))
	--IsOnGround, toggling off and on updates the player and collects the pickup
	localplayer:set_config_flag(60, false)
	sleep(0.51)
end

local function collectPickups(singlePickup)
	local oldGodmode = localplayer:get_godmode()
	local oldHealth = localplayer:get_max_health()
	local oldPos = localplayer:get_position()

	localplayer:set_godmode(true)
	localplayer:set_max_health(0.0)

	if singlePickup then
		tpToPickup(singlePickup)
	else
		for pickup in replayinterface.get_pickups() do
			tpToPickup(pickup)
		end
	end
	local tries = 0
	while (localplayer:get_position() ~= oldPos and tries < 10) do
		for _ = 0, 100 do
			localplayer:set_position(oldPos)
		end
		tries = tries + 1
		sleep(0.8)
	end
	localplayer:set_godmode(oldGodmode)
	localplayer:set_max_health(oldHealth)
end

local function collectPickup(pickup)
	collectPickups(pickup)
end

local function collectAllPickups()
	collectPickups()
end

local function createCustomPickupWithCustomModel(pickup_hash, model, value, ply)
	local pos = ply and ply:get_position() or localplayer:get_position()
	local tries = 0
	if not value then value = 69 end
	createPickup(pos + vector3(0,0,2), value)
	--force the pickup hash fast enough for it to be changed before being picked up
	while (tries < 50) do
		for pickup in replayinterface.get_pickups() do
			if pickup:get_amount() == value then
				pickup:set_pickup_hash(joaat(pickup_hash))
				if model then
					pickup:set_model_hash(joaat(model))
				end
				return
			end
		end
	end
end

local function getAllWeapons()
	local startIdentifierAmount = 9000
	for _, pickupName in ipairs(sorted_pickup_names) do
		if string.find(pickupName[1], "PICKUP_WEAPON") then
			createCustomPickupWithCustomModel(pickupName[1], nil, startIdentifierAmount)
			startIdentifierAmount = startIdentifierAmount + 1
			sleep(0.09)
		end
	end
end

menu.register_callback('getAllWeapons', getAllWeapons)

local function printToConsole(pickup)
	--pickup_array[n] = {pickupobj, pickup_name, distance, direction}
	print("Pickup "..pickup[2].." details:")
	print("Amount: "..pickup[1]:get_amount())
	print("Health: "..pickup[1]:get_health())
	print("Model Hash: "..pickup[1]:get_model_hash())
	print("Pickup Hash: "..pickup[1]:get_pickup_hash())
	print("Position: "..tostring(pickup[1]:get_position()))
end

local numbers = {0, 1, 5, 20, 69, 100, 420, 1000, 2500, 5000, 10000, 50000, 100000, 500000, 1000000}
local function amountChanger(pickup, sub)
	for _, num in ipairs(numbers) do
		sub:add_action(tostring(num), function() pickup:set_amount(num) end)
	end
end

local function healthChanger(pickup, sub)
	for _, num in ipairs(numbers) do
		sub:add_action(tostring(num), function() pickup:set_health(num) end)
	end
end

local function modelChanger(pickup, sub)
	for _, modelName in ipairs(sorted_model_names) do
		sub:add_action(modelName[1], function() pickup:set_model_hash(joaat(modelName[1])) end)
	end
end

local function pickupChanger(pickup, sub)
	for _, pickupName in ipairs(sorted_pickup_names) do
		sub:add_action(pickupName[1], function() pickup:set_pickup_hash(joaat(pickupName[1])) end)
		::skip::
	end
end

local function weaponMenu(sub)
	for _, pickupName in ipairs(sorted_pickup_names) do
		if string.find(pickupName[1], "PICKUP_WEAPON") then
			sub:add_action(string.gsub(pickupName[1], "PICKUP_WEAPON_", ""), function() createCustomPickupWithCustomModel(pickupName[1], nil, 6969) end)
		end
	end
end

local figurines = { "bkr_prop_coke_boxeddoll", "vw_prop_vw_colle_sasquatch", "vw_prop_vw_colle_beast", "vw_prop_vw_colle_rsrgeneric", "vw_prop_vw_colle_rsrcomm",
					"vw_prop_vw_colle_pogo", "vw_prop_vw_colle_prbubble", "vw_prop_vw_colle_imporage", "vw_prop_vw_colle_alien", "vw_prop_vw_lux_card_01a" }
local function collectibleMenu(sub)
	for _, figurine in pairs(figurines) do
		sub:add_action("Give " .. figurines[_], function() createCustomPickupWithCustomModel("PICKUP_CUSTOM_SCRIPT", figurine, 0) end)
	end
end

local function sortAndFillPickupArrayByDistance()
	local pickup_array = {}
	for pickup in replayinterface.get_pickups() do
		if pickup then
			--pickup_array[n] = {pickupobj, pickup_name, distance, direction}
			table.insert(pickup_array, {pickup, distanceBetween(localplayer, pickup), getDirectionalArrow(getDirectionToThing(pickup))})
		end
	end
	table.sort(pickup_array, function(a, b) return a[3] < b[3] end)
	return pickup_array
end

local function pickupOptions(sub, pickup)
	sub:clear()
	greyText(sub, "------ Pickup Actions ------")
	sub:add_action("Collect Pickup (STAND STILL!)", function() collectPickup(pickup[1]) end)
	sub:add_action("Teleport close to Pickup", function() teleportCloseToPickup(pickup[1]) end)

	greyText(sub, "------Pickup Info:------")
	sub:add_bare_item("", function() return "Amount:  "..pickup[1]:get_amount() end, null, null, null)
	amountSub = sub:add_submenu("|Change Amount", function() amountSub:clear() amountChanger(pickup[1], amountSub) end)
	sub:add_bare_item("", function() return "Health:  "..pickup[1]:get_health() end, null, null, null)
	healthSub = sub:add_submenu("|Change Health", function() healthSub:clear() healthChanger(pickup[1], healthSub) end)
	sub:add_bare_item("", function() return "Pickup Hash:  "..pickup[1]:get_pickup_hash() end, null, null, null)
	sub:add_bare_item("", function() return "Pickup:  "..getPickupName(pickup[1]) end, null, null, null)
	pickupSub = sub:add_submenu("|Change Pickup Hash", function() pickupSub:clear() pickupChanger(pickup[1], pickupSub) end)
	sub:add_bare_item("", function() return "Model Hash:  "..pickup[1]:get_model_hash() end, null, null, null)
	sub:add_bare_item("", function() return "Model:  ".. getModelName(pickup[1]) end, null, null, null)
	modelSub = sub:add_submenu("|\u{26A0} Change Model Hash (doesn't show)", function() modelSub:clear() modelChanger(pickup[1], modelSub) end)
	sub:add_bare_item("", function() return "Direction:  "..distanceBetween(localplayer, pickup[1]).."m".."  "..getDirectionalArrow(getDirectionToThing(pickup[1])) end, null, null, null)
	greyText(sub, "-----------------")
	sub:add_action("(Debug) Print to Console", function() printToConsole(pickup) end)

end

local updateable = true
local ambientSubs = {}
local SortStyles = { [0] = "Pickup Names", "Model Names" }
local SortStyle = 0
local function initializePickups(sub)
	updateable = false
	local freemode_script = script("freemode")
	local displayName

	sub:clear()
	sub:add_array_item("=======  UPDATE: |show:", SortStyles, function()
		return SortStyle
	end, function(value)
		SortStyle = value
		if updateable then
			initializePickups(sub)
			return
		end
	end)

	if freemode_script:is_active() then
		greyText(sub, "-------- Quick Actions: --------")
		sub:add_action("Gimme $ome Money", function() createCustomPickupWithCustomModel("PICKUP_MONEY_VARIABLE", "prop_cash_pile_01", math.random(1500, 2000)) end)
		sub:add_action("Give Random Figurine", function() createCustomPickupWithCustomModel("PICKUP_CUSTOM_SCRIPT", figurines[math.random(#figurines)], 0) end)
		sub:add_action("Debug Pickup", function() local pos = localplayer:get_position()+localplayer:get_heading()*3 pos.z = pos.z + 1 createPickup(pos, 69) end)
		sub:add_action("Give Fireworks Launcher", function() createCustomPickupWithCustomModel("PICKUP_WEAPON_FIREWORK", nil, 6969) end)
		sub:add_action("Give All Weapons", function() menu.emit_event('getAllWeapons') end)
		weaponSub = sub:add_submenu("Give Specific Weapon:", function() weaponMenu(weaponSub) end)
		collectiblesSub = sub:add_submenu("Give Specific Collectible:", function() collectibleMenu(collectiblesSub) end)
	end
	greyText(sub, "-------- Nearby Pickups: -------")
	local pickupArray = sortAndFillPickupArrayByDistance()

	for _, pickup in pairs(pickupArray) do
		if SortStyles[SortStyle] == "Pickup Names" then
			displayName = string.gsub(getPickupName(pickup[1]), "PICKUP_", "")
		else
			displayName = getModelName(pickup[1])
		end
		ambientSubs[_] = sub:add_submenu(displayName .. "|"..pickup[2].."m".." "..pickup[3], function() pickupOptions(ambientSubs[_], pickup) end)
	end


	if #pickupArray > 0 then
		greyText(sub, "-----------------")
		sub:add_action("   - Collect All (STAND STILL!) -", function() collectAllPickups() end)
	end
	updateable = true
end
local pickupMenu
pickupMenu = toolboxSub:add_submenu("     ///// Pickup-Suite \\\\\\\\\\", function() initializePickups(pickupMenu) end)

--Debug function to test pickups syncing (spoiler: they never do.)
--menu.add_player_action("Give Railgun", function(player_index)
--	local ply = player.get_player_ped(player_index)
--	createCustomPickupWithCustomModel(joaat("PICKUP_WEAPON_RAILGUNXM3"), "W_AR_RailGun_XM3", 69, ply)
--end)
