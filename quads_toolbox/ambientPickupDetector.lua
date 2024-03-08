-------------------------------
-- Original Script by Quad_Plex
-- Pickup-Detector v0.4.20
-------------------------------

--TODO: Check if PICKUP_PORTABLE_FM_CONTENT_MISSION_ENTITY_SMALL can be created this way
--Could be used to create tr_prop_tr_chest_01a movie prop pickups

require("scripts/quads_toolbox/toolbox_data/PICKUPS")
require("scripts/quads_toolbox/toolbox_data/globals_and_utils")

local pickup_array = {}

local sorted_model_hashes = {}
local duplicate_models = {}
for hash, pickup_data in pairs(AMBIENT) do
	if duplicate_models[pickup_data[2]:upper()] == nil then
		duplicate_models[pickup_data[2]:upper()] = "there can be only one"
		table.insert(sorted_model_hashes, {hash, pickup_data})
	end
end
table.sort(sorted_model_hashes, function(a, b) return a[2][2]:upper() < b[2][2]:upper() end)

local sorted_pickup_hashes = {}
local duplicate_pickups = {}
for hash, pickup_data in pairs(AMBIENT) do 
	if duplicate_pickups[pickup_data[1]:upper()] == nil then
		duplicate_pickups[pickup_data[1]:upper()] = "there can be only one"
		table.insert(sorted_pickup_hashes, {hash, pickup_data})
	end
end
table.sort(sorted_pickup_hashes, function(a, b) return a[2][1]:upper() < b[2][1]:upper() end)

local function getPickupName(pickup)
	local ambient = AMBIENT[pickup:get_pickup_hash()]
	if not ambient then 
		return "Not found!: "..pickup:get_pickup_hash() 
	else
		return string.gsub(ambient[1], "#", "")
	end
end

local function sortAndFillPickupArrayByDistance()
	for pickup in replayinterface.get_pickups() do
		if pickup then
			--pickup_array[n] = {pickupobj, pickup_name, distance, direction}
			table.insert(pickup_array, {pickup, getPickupName(pickup), distanceBetween(localplayer, pickup), getDirectionalArrow(getDirectionToThing(pickup))})
		end
	end
	table.sort(pickup_array, function(a, b) return a[3] < b[3] end)
end

local function teleportToPickup(pickup)
	--teleport just in front of the pickup, without collecting it
	if localplayer:is_in_vehicle() then
		localplayer:get_current_vehicle():set_position(pickup:get_position() + (localplayer:get_heading() * -2.4))
	else
		localplayer:set_position(pickup:get_position() + (localplayer:get_heading() * -2.4))
	end
end

local function collectPickup(pickup)
	local oldGodmode = localplayer:get_godmode()
	local oldHealth = localplayer:get_max_health()
	local oldPos = localplayer:get_position()
	
	localplayer:set_godmode(true)
	localplayer:set_max_health(0.0)
	
	local pickuppos = pickup:get_position()
	pickuppos.z = pickuppos.z - 0.3
	sleep(0.1)
	for _ = 0, 100 do
		localplayer:set_position(pickuppos)
	end
	sleep(0.4)
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

local function collectAllPickups()
	if #pickup_array > 0 then
		local oldGodmode = localplayer:get_godmode()
		local oldHealth = localplayer:get_max_health()
		local oldPos = localplayer:get_position()

		localplayer:set_godmode(true)
		localplayer:set_max_health(0.0)
		
		for pickup in replayinterface.get_pickups() do
			local pickuppos = pickup:get_position()
			pickuppos.z = pickuppos.z - 0.25
			sleep(0.2)
			for _ = 0, 100 do
				localplayer:set_position(pickuppos)
			end
			sleep(0.3)
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
end

function createCustomPickupWithCustomModel(pickup_hash, model, value, ply)
	local pos = ply and ply:get_position() or localplayer:get_position()
	local tries = 0
	if not value then value = 69 end
	createPickup(pos + vector3(0,0,2), value)
	--force the pickup hash fast enough for it to be changed before being picked up
	while (tries < 50) do
		for pickup in replayinterface.get_pickups() do
			if pickup:get_amount() == value then
				pickup:set_pickup_hash(pickup_hash)
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
	-- pickup_data = { pickup_hash { pickup_hash_text, pickup_hash_model_text } }
	for _, pickup_data in ipairs(sorted_pickup_hashes) do
		if string.find(pickup_data[2][1], "PICKUP_WEAPON") then
			createCustomPickupWithCustomModel(pickup_data[2][1], nil, startIdentifierAmount)
			startIdentifierAmount = startIdentifierAmount + 1
			sleep(0.09)
		end
	end
end

menu.register_callback('getAllWeapons', getAllWeapons)

local function printToConsole(pickup)
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
	-- pickup_data = { pickup_hash { pickup_hash_text, pickup_hash_model_text } }
	for _, pickup_data in pairs(sorted_model_hashes) do
		sub:add_action(pickup_data[2][2], function() pickup:set_model_hash(pickup_data[2][2]) end)
	end
end

local function pickupChanger(pickup, sub)	
	-- pickup_data = { pickup_hash { pickup_hash_text, pickup_hash_model_text } }
	for _, pickup_data in ipairs(sorted_pickup_hashes) do
		if string.find(pickup_data[2][1], "#") then
			goto skip
		end
		sub:add_action(pickup_data[2][1], function() pickup:set_pickup_hash(pickup_data[1]) end)
		::skip::
	end
end

local function weaponMenu(sub)
-- pickup_data = { pickup_hash { pickup_hash_text, pickup_hash_model_text } }
	for _, pickup_data in ipairs(sorted_pickup_hashes) do
		if string.find(pickup_data[2][1], "PICKUP_WEAPON") then
			sub:add_action(string.gsub(pickup_data[2][1], "PICKUP_WEAPON_", ""), function() createCustomPickupWithCustomModel(pickup_data[2][1], nil, 6969) end)
		end
	end
end

local figurines = { "bkr_prop_coke_boxeddoll", "vw_prop_vw_colle_sasquatch", "vw_prop_vw_colle_beast", "vw_prop_vw_colle_rsrgeneric", "vw_prop_vw_colle_rsrcomm",
					"vw_prop_vw_colle_pogo", "vw_prop_vw_colle_prbubble", "vw_prop_vw_colle_imporage", "vw_prop_vw_colle_alien", "vw_prop_vw_lux_card_01a" }
local function collectibleMenu(sub)
	for _, figurine in pairs(figurines) do
		sub:add_action("Give " .. figurines[_], function() createCustomPickupWithCustomModel(joaat("PICKUP_CUSTOM_SCRIPT"), figurine, 0) end)
	end
end


local function lookupModel(pickup_model_hash)
	for _, pickup_data in pairs(AMBIENT) do
		if pickup_model_hash == joaat(pickup_data[2]) then
			return pickup_data[2]
		end
	end
	return "Unknown!"
end

local function pickupOptions(sub, pickup)
	sub:clear()
	greyText(sub, "------ Pickup Actions ------")
	sub:add_action("Collect Pickup (First Person)", function() collectPickup(pickup[1]) end)
	sub:add_action("Teleport close to Pickup", function() teleportToPickup(pickup[1]) end)
	
	greyText(sub, "------Pickup Info:------")
	sub:add_bare_item("", function() return "Amount:  "..pickup[1]:get_amount() end, null, null, null)
	amountSub = sub:add_submenu("|Change Amount", function() amountSub:clear() amountChanger(pickup[1], amountSub) end)
	sub:add_bare_item("", function() return "Health:  "..pickup[1]:get_health() end, null, null, null)
	healthSub = sub:add_submenu("|Change Health", function() healthSub:clear() healthChanger(pickup[1], healthSub) end)
	sub:add_bare_item("", function() return "Pickup Hash:  "..pickup[1]:get_pickup_hash() end, null, null, null)
	sub:add_bare_item("", function() return "Pickup:  "..getPickupName(pickup[1]) end, null, null, null)
	pickupSub = sub:add_submenu("|Change Pickup Hash", function() pickupSub:clear() pickupChanger(pickup[1], pickupSub) end)
	sub:add_bare_item("", function() return "Model Hash:  "..pickup[1]:get_model_hash() end, null, null, null)
	sub:add_bare_item("", function() return "Model:  "..lookupModel(pickup[1]:get_model_hash()) end, null, null, null)
	modelSub = sub:add_submenu("|\u{26A0} Change Model Hash (doesn't show)", function() modelSub:clear() modelChanger(pickup[1], modelSub) end)
	sub:add_bare_item("", function() return "Direction:  "..distanceBetween(localplayer, pickup[1]).."m".."  "..getDirectionalArrow(getDirectionToThing(pickup[1])) end, null, null, null)
	greyText(sub, "-----------------")
	sub:add_action("(Debug) Print to Console", function() printToConsole(pickup) end)
	
end

local updateable = true
local ambientSubs = {}
local function initializePickups(sub)
	updateable = false
	sub:clear()
	pickup_array = {}
	local freemode_script = script("freemode")
	sub:add_bare_item(("............Updating..........."), function() if updateable then return "===========Update List===========" end end, function() if updateable then initializePickups(sub) end end, null, null)
	
	if freemode_script:is_active() then
		greyText(sub, "-------- Quick Actions: --------")
		sub:add_action("Gimme $ome Money", function() createCustomPickupWithCustomModel(-31919185, "prop_cash_pile_01", math.random(1500, 2000)) end)
		sub:add_action("Give Random Figurine", function() createCustomPickupWithCustomModel(joaat("PICKUP_CUSTOM_SCRIPT"), figurines[math.random(#figurines)], 0) end)
		sub:add_action("Debug Pickup", function() local pos = localplayer:get_position()+localplayer:get_heading()*3 pos.z = pos.z + 1 createPickup(pos, 69) end)
		sub:add_action("Give Fireworks Launcher", function() createCustomPickupWithCustomModel(joaat("PICKUP_WEAPON_FIREWORK"), nil, 6969) end)
		sub:add_action("Give All Weapons", function() menu.emit_event('getAllWeapons') end)
		weaponSub = sub:add_submenu("Give Specific Weapon:", function() weaponMenu(weaponSub) end)
		collectiblesSub = sub:add_submenu("Give Collectibles:", function() collectibleMenu(collectiblesSub) end)
	end
	greyText(sub, "-------- Nearby Pickups: -------")
	sortAndFillPickupArrayByDistance()
	for _, pickup in pairs(pickup_array) do
		ambientSubs[_] = sub:add_submenu(string.gsub(pickup[2], "#", "").."|"..pickup[3].."m".." "..pickup[4], function() pickupOptions(ambientSubs[_], pickup) end)
	end
	if #pickup_array > 0 then
		greyText(sub, "-----------------")
		sub:add_action("   - Collect All (First Person) -", function() collectAllPickups() end)
	end
	updateable = true
end
pickupMenu = toolbox:add_submenu("     ///// Pickup-Tools \\\\\\\\\\", function() initializePickups(pickupMenu) end)

menu.add_player_action("Give Railgun", function(player_index)
	local ply = player.get_player_ped(player_index)
	createCustomPickupWithCustomModel(joaat("PICKUP_WEAPON_RAILGUNXM3"), "W_AR_RailGun_XM3", 69, ply)
end)


