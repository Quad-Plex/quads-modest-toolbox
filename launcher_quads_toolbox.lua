--Initialize all scripts
require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")
toolbox = menu.add_submenu("___--=== Quad's Modest Toolbox ===--___")

greyText(toolbox,centeredText( "========= Submenus: ========="))
require("scripts/quads_toolbox_scripts/ultimate_playerlist")
require("scripts/quads_toolbox_scripts/ambientPickupDetector")

greyText(toolbox,centeredText( "========= Vehicle Options ========="))
require("scripts/quads_toolbox_scripts/trafficremover")
require("scripts/quads_toolbox_scripts/carCheats")
require("scripts/quads_toolbox_scripts/rainbow_vehicle")

greyText(toolbox, centeredText("========= Gun Options ========="))
require("scripts/quads_toolbox_scripts/car-a-pult")
require("scripts/quads_toolbox_scripts/weapon")

greyText(toolbox, centeredText("========= Misc Options ========="))
require("scripts/quads_toolbox_scripts/noclip")
require("scripts/quads_toolbox_scripts/offradar")
require("scripts/quads_toolbox_scripts/stats")
require("scripts/quads_toolbox_scripts/misc")

greyText(toolbox, centeredText("========= Hotkey Config ========="))
require("scripts/quads_toolbox_scripts/hotkeys")

greyText(toolbox, centeredText("========= Debug Tools ========="))
require("scripts/quads_toolbox_scripts/globalscanner")