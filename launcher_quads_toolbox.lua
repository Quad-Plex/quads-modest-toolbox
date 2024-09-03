finishedLoading = false
require_game_build(3274)

--Load all required constants
local folderTest, unused = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json")
if not folderTest then
	error("\n!!!!!!!!!!! READ THIS !!!!!!!!!!\n\nError! Couldn't find required lua files.\nMake sure that you've extracted the \n'quads_toolbox_scripts' folder aswell as\nthe two .lua files (launcher_quads_toolbox.lua)\nand (loops_quads_toolbox.lua) directly into\nyour modest-menu/scripts folder!")
	return
end
unused = nil
require("scripts/quads_toolbox_scripts/toolbox_data/enums/VEHICLE_ENUMS")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/WEAPONS")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/PED_FLAGS")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/PED_MODELS")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/KEYCODE_CONSTANTS")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/MODEL_HASHES")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/PICKUP_HASHES")
require("scripts/quads_toolbox_scripts/toolbox_data/enums/EXPLOSION_TYPES")

--Initialize scripts one by one
require("scripts/quads_toolbox_scripts/toolbox_data/playerlist_loop_functions")
toolboxSub = menu.add_submenu("--== ☣️ Quad's Modest Toolbox ☣️ ==--")

addText(toolboxSub, centeredText("     ☣️ Quad's Modest Toolbox ☣️"))
toolboxSub:add_bare_item(centeredText("--__--¯¯-- 100% loaded --¯¯--__--"), function() return not finishedLoading and centeredText("--__--¯¯- Loading Scripts -¯¯--__--") or nil end, null, null, null)

require("scripts/quads_toolbox_scripts/ultimate_playerlist")
require("scripts/quads_toolbox_scripts/ambientPickupSuite")

require("scripts/quads_toolbox_scripts/vehicle_spawner")
vehicleSpawnMenu = toolboxSub:add_submenu("     ★🚗 Vehicle Spawner ★🚗", function() addVehicleSpawnMenu(localplayer, vehicleSpawnMenu) end)

require("scripts/quads_toolbox_scripts/carMeetHelper")

vehicleOptionsSub = toolboxSub:add_submenu(centeredText(" 🔧 Vehicle Tools 🔧"))
greyText(vehicleOptionsSub, centeredText(" ----- 🚗 Vehicle Options 🚗 -----"))
require("scripts/quads_toolbox_scripts/carCheats")
require("scripts/quads_toolbox_scripts/rainbow_vehicle")
require("scripts/quads_toolbox_scripts/misc_vehicle")

gunOptionsSub = toolboxSub:add_submenu(centeredText(" 🔫 Gun Scripts 🔫"))
greyText(gunOptionsSub, centeredText(" 🔫 Gun Options 🔫"))
gunOptionsSub:add_bare_item("", function() return "== Current Gun: " .. getCurrentWeaponName() .. " ==" end, null, null, null)
greyText(gunOptionsSub, "----------------------------")
require("scripts/quads_toolbox_scripts/weaponMods")
require("scripts/quads_toolbox_scripts/car-a-pult")
require("scripts/quads_toolbox_scripts/gunmenu")

pedChangerSub = toolboxSub:add_submenu(centeredText("    ★🏃 Ped Changer 🏃★"))
require("scripts/quads_toolbox_scripts/pedchanger")

playerOptionsSub = toolboxSub:add_submenu(centeredText("👤 Player Options 👤"))
require("scripts/quads_toolbox_scripts/playeroptions")

worldOptionsSub = toolboxSub:add_submenu(centeredText("🌍 World Options 🌍"))
require("scripts/quads_toolbox_scripts/worldoptions")

miscOptionsSub = toolboxSub:add_submenu(centeredText("❓ Misc Options ❓"))
greyText(miscOptionsSub, centeredText(" ❓ Misc Options ❓"))
require("scripts/quads_toolbox_scripts/noclip")
require("scripts/quads_toolbox_scripts/misc")
require("scripts/quads_toolbox_scripts/stats")


require("scripts/quads_toolbox_scripts/hotkeys")

debugToolsSub = toolboxSub:add_submenu(centeredText(" 📟 Debug Tools 📟"))
greyText(debugToolsSub, centeredText(" 📟 Debug Tools "))
require("scripts/quads_toolbox_scripts/globalscanner")
require("scripts/quads_toolbox_scripts/globalupdater")
displayboxtype = 108
debugToolsSub:add_int_range("Display Box Type Tester", 1, -100, 500, function()
	return displayboxtype
end, function(n)
	displayboxtype = n
	displayHudBanner("EPS_CASH", "~s~", 0, n, true)
end)
local function saveClosestVehicleModData(lastSpawnedVehicleHash)
	local currentMods = {}
	for i = 1, globals.get_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9) do
		currentMods[i] = tostring(globals.get_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9 + i))
	end
	local modsResultString = table.concat(currentMods, ", ")

	local spawnedVehicle
	repeat
		local minDistance
		for veh in replayinterface.get_vehicles() do
			local lastDistance = distanceBetween(localplayer, veh)
			if not minDistance then
				minDistance = lastDistance
				spawnedVehicle = veh
			elseif lastDistance < minDistance then
				minDistance = lastDistance
				spawnedVehicle = veh
			end
		end
	until spawnedVehicle ~= nil
	local spawnedVehicleHash = spawnedVehicle:get_model_hash()
	if not lastSpawnedVehicleHash or spawnedVehicleHash ~= lastSpawnedVehicleHash then
		if not VEHICLE[spawnedVehicleHash] then
			print("!!!!! UNKNOWN HASH!!!!!")
			print("VEHICLE[" .. spawnedVehicleHash .."] = { \"VehName\", \"VehClass\", {" .. modsResultString .. "}}")
		else
			print("VEHICLE[" .. spawnedVehicleHash .."] = { \"" .. VEHICLE[spawnedVehicleHash][1] .. "\", \""  .. VEHICLE[spawnedVehicleHash][2] .. "\", {" .. modsResultString .. "}}")
		end
	end
	return spawnedVehicleHash
end

debugToolsSub:add_action("Print mod data for closest vehicle", function()
	saveClosestVehicleModData()
end)
greyText(debugToolsSub, "Spawn with 'Anonymous (maxed)' before using")

greyText(toolboxSub, "--------------------------------------")

local creditsSub = toolboxSub:add_submenu(centeredText("\u{00A9} Quad_Plex"))
addText(creditsSub, "Some people I want to thank:")
addText(creditsSub, "(No particular order)")
addText(creditsSub, "!!!Major thanks to Kiddion!!!")
addText(creditsSub, "AppleVegass for lua script support")
addText(creditsSub, "Alice2333 (spawner/lua stuff)")
addText(creditsSub, "rf2007 for finding any and all globals")
addText(creditsSub, "Slon for lua stuff on UKC")
addText(creditsSub, "AdventureBox the wise man")
addText(creditsSub, "Yimura for YIMMenu as documentation")
addText(creditsSub, "DMKiller's work on the forums")
addText(creditsSub, "HUGE thanks to book4 for globals")
addText(creditsSub, "LUKY6464 for help in Megathread")
addText(creditsSub, "gfsdjvbsio for PlayerVehicleBlipType")
addText(creditsSub, "Don Reagan for help debugging globals")
addText(creditsSub, "--------------- Testers: ----------------")
addText(creditsSub, "Ronald Weaselby")
addText(creditsSub, "ErGabibbo")
addText(creditsSub, "PΛNTHΞRΛ")
addText(creditsSub, "-----------------------------------")
addText(creditsSub, "Surely others I've forgotten, please")
addText(creditsSub, "contact me if you feel that your")
addText(creditsSub, "name belongs here <3")
local secretMenu
secretMenu = creditsSub:add_submenu("        Peace, Quad_Plex")
greyText(secretMenu, "   === SECRET MENU ===")
secretMenu:add_action("Don't press this button!", function() menu.suicide_player() sleep(0.3) displayHudBanner("FGTXT_F_F3", "RESPAWN_W", "", 108) end)

finishedLoading = true

menu.register_callback("OnScriptsLoaded", function() menu.emit_event("startModWatcher")  end)
