--Initialize all scripts
require("scripts/quads_toolbox/toolbox_data/globals_and_utils")
toolbox = menu.add_submenu("___--=== Quad's Modest Toolbox ===--___")

greyText(toolbox,centeredText( "========= Submenus: ========="))
require("scripts/quads_toolbox/ultimate_playerlist")
require("scripts/quads_toolbox/ambientPickupDetector")

greyText(toolbox,centeredText( "========= Vehicle Options ========="))
require("scripts/quads_toolbox/trafficremover")
require("scripts/quads_toolbox/carCheats")
require("scripts/quads_toolbox/rainbow_vehicle")

greyText(toolbox, centeredText("========= Gun Options ========="))
require("scripts/quads_toolbox/car-a-pult")
require("scripts/quads_toolbox/weapon")

greyText(toolbox, centeredText("========= Misc Options ========="))
require("scripts/quads_toolbox/heist passed")
require("scripts/quads_toolbox/noclip")
require("scripts/quads_toolbox/offradar")
require("scripts/quads_toolbox/stats")
require("scripts/quads_toolbox/misc")

greyText(toolbox, centeredText("========= Hotkey Config ========="))
require("scripts/quads_toolbox/hotkeys")

greyText(toolbox, centeredText("========= Debug Tools ========="))
require("scripts/quads_toolbox/globalscanner")