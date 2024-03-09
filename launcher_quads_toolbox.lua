--Initialize all scripts
require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")
toolboxSub = menu.add_submenu("___--=== Quad's Modest Toolbox ===--___")

listsSub = toolBox:add_submenu(centeredText( "========= 📄 Submenus: ========="))
require("scripts/quads_toolbox_scripts/ultimate_playerlist")
require("scripts/quads_toolbox_scripts/ambientPickupDetector")

vehicleOptionsSub = toolboxSub:add_submenu(centeredText( "======== 🚗 Vehicle Options ========"))
require("scripts/quads_toolbox_scripts/trafficremover")
require("scripts/quads_toolbox_scripts/carCheats")
require("scripts/quads_toolbox_scripts/rainbow_vehicle")

gunOptionsSub = toolboxSub:add_submenu(centeredText("========= 🔫 Gun Options ========="))
require("scripts/quads_toolbox_scripts/car-a-pult")
require("scripts/quads_toolbox_scripts/weaponMods")

miscOptionsSub = toolboxSub:add_submenu(centeredText("========= ❓ Misc Options ========="))
require("scripts/quads_toolbox_scripts/noclip")
require("scripts/quads_toolbox_scripts/offradar")
require("scripts/quads_toolbox_scripts/stats")
require("scripts/quads_toolbox_scripts/misc")

configSub = toolboxSub:add_submenu(centeredText("========= ⚙️ Hotkey Config ========="))
require("scripts/quads_toolbox_scripts/hotkeys")

debugToolsSub = toolboxSub:add_submenu(centeredText("========= 📟 Debug Tools ========="))
require("scripts/quads_toolbox_scripts/globalscanner")