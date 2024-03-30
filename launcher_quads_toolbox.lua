finishedLoading = false

--Load all required constants
require("scripts/quads_toolbox_scripts/toolbox_data/VEHICLES_WEAPONS")
require("scripts/quads_toolbox_scripts/toolbox_data/PED_FLAG_TABLE")
require("scripts/quads_toolbox_scripts/toolbox_data/KEYCODE_CONSTANTS")
require("scripts/quads_toolbox_scripts/toolbox_data/MODEL_HASHES")
require("scripts/quads_toolbox_scripts/toolbox_data/PICKUP_HASHES")
require("scripts/quads_toolbox_scripts/toolbox_data/EXPLOSION_TYPES")

--Initialize scripts one by one
require("scripts/quads_toolbox_scripts/toolbox_data/global_functions")
require("scripts/quads_toolbox_scripts/toolbox_data/util_functions")
toolboxSub = menu.add_submenu("--== ☣️ Quad's Modest Toolbox ☣️ ==--")

text(toolboxSub, centeredText("     ☣️ Quad's Modest Toolbox ☣️"))
toolboxSub:add_bare_item(centeredText("--__--¯¯-- 100% loaded --¯¯--__--"), function() return not finishedLoading and centeredText("--__--¯¯- Loading Scripts -¯¯--__--") or nil end, null, null, null)

require("scripts/quads_toolbox_scripts/ultimate_playerlist")
require("scripts/quads_toolbox_scripts/ambientPickupSuite")

vehicleSpawnMenu = toolboxSub:add_submenu("     ★🚗 Vehicle Spawner: ★🚗", function() addVehicleSpawnMenu(localplayer, vehicleSpawnMenu) end)

vehicleOptionsSub = toolboxSub:add_submenu(centeredText("    🔧 Vehicle Tools 🔧"))
greyText(vehicleOptionsSub, centeredText(" ----- 🚗 Vehicle Options 🚗 -----"))
require("scripts/quads_toolbox_scripts/trafficremover")
require("scripts/quads_toolbox_scripts/carCheats")
require("scripts/quads_toolbox_scripts/rainbow_vehicle")
require("scripts/quads_toolbox_scripts/misc_vehicle")

gunOptionsSub = toolboxSub:add_submenu(centeredText(" 🔫 Gun Scripts 🔫"))
greyText(gunOptionsSub, centeredText(" 🔫 Gun Options 🔫"))
require("scripts/quads_toolbox_scripts/car-a-pult")
require("scripts/quads_toolbox_scripts/weaponMods")

miscOptionsSub = toolboxSub:add_submenu(centeredText("❓ Misc Options ❓"))
greyText(miscOptionsSub, centeredText(" ❓ Misc Options ❓"))
require("scripts/quads_toolbox_scripts/noclip")
require("scripts/quads_toolbox_scripts/offradar")
require("scripts/quads_toolbox_scripts/misc")
require("scripts/quads_toolbox_scripts/stats")


require("scripts/quads_toolbox_scripts/hotkeys")

debugToolsSub = toolboxSub:add_submenu(centeredText(" 📟 Debug Tools 📟"))
greyText(debugToolsSub, centeredText(" 📟 Debug Tools "))
require("scripts/quads_toolbox_scripts/globalscanner")
require("scripts/quads_toolbox_scripts/globalupdater")

greyText(toolboxSub, "--------------------------------------")

local creditsSub = toolboxSub:add_submenu(centeredText(" \u{00A9} Quad_Plex"))
text(creditsSub, "Some people I want to thank:")
text(creditsSub, "(No particular order)")
text(creditsSub, "!!!Major thanks to Kiddion!!!")
text(creditsSub, "AppleVegass for lua script support")
text(creditsSub, "Alice2333 (spawner/lua stuff)")
text(creditsSub, "TeaTimeTea general lua forum stuff")
text(creditsSub, "AdventureBox the wise man")
text(creditsSub, "Yimura for YIMMenu as documentation")
text(creditsSub, "DMKiller's work on the forums")
text(creditsSub, "HUGE thanks to book4 for globals")
text(creditsSub, "LUKY6464 for activity in Megathread")
text(creditsSub, "gfsdjvbsio for PlayerVehicleBlipType")
text(creditsSub, "Don Reagan for help debugging globals")
text(creditsSub, "---------------------------------------")
text(creditsSub, "Surely others I've forgotten, please")
text(creditsSub, "contact me if you feel that your")
text(creditsSub, "name belongs here <3")
text(creditsSub, "        Peace, Quad_Plex")
local secretMenu
secretMenu = creditsSub:add_submenu("Secret Menu...")
secretMenu:add_action("Don't press this button!", function() displayHudBanner("FGTXT_F_F3", "RESPAWN_W", "", 109) end)

finishedLoading = true

menu.register_callback("OnScriptsLoaded", function() menu.emit_event("startModWatcher")  end)
