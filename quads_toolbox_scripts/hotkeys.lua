require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")

--Todo: add elements to configSub to enable/disable hotkeys and more settings
-- Define the hotkeys data
local success, hotkeysData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/HOTKEY_CONFIG.json")
if success then
    print("Hotkey Configuration loaded successfully!!")
else
    error("Error loading Hotkey Configuration!", 0)
end

--Del, Lose Wanted level
local loseWantedLevelHotkey
menu.register_callback('ToggleWantedLevelHotkey', function()
    if not loseWantedLevelHotkey then
        loseWantedLevelHotkey = menu.register_hotkey(46, function()
            menu.clear_wanted_level()
            displayHudBanner("LOSE_WANTED", "LEST_NCOPS", "", 109)
        end)
    else
        menu.remove_hotkey(loseWantedLevelHotkey)
        loseWantedLevelHotkey = nil
    end
end)

--F6, Max health and armor
local maxHealthArmorHotkey
menu.register_callback('ToggleHealthAndArmorHotkey', function()
    if not maxHealthArmorHotkey then
        maxHealthArmorHotkey = menu.register_hotkey(117, function()
            menu.heal_all()
            menu.max_all_ammo()
            displayHudBanner("CHEAT_HEALTH_ARMOR", "PIM_FULL1", "", 109)
        end)
    else
        menu.remove_hotkey(maxHealthArmorHotkey)
        maxHealthArmorHotkey = nil
    end
end)

-- F7, Repair
local repairVehicleHotkey
menu.register_callback('ToggleRepairVehicleHotkey', function()
    if not repairVehicleHotkey then
        repairVehicleHotkey = menu.register_hotkey(118, function()
            menu.repair_online_vehicle()
            displayHudBanner("BLIP_402", "", "", 109)
        end)
    else
        menu.remove_hotkey(repairVehicleHotkey)
        repairVehicleHotkey = nil
    end
end)

--F8, Vehicle Godmode
local vehicleGodmodeHotkey
menu.register_callback('ToggleVehicleGodmodeHotkey', function()
    if not vehicleGodmodeHotkey then
        vehicleGodmodeHotkey = menu.register_hotkey(119, function()
            if localplayer:is_in_vehicle() then
                localplayer:get_current_vehicle():set_godmode(not localplayer:get_current_vehicle():get_godmode())

                if localplayer:get_current_vehicle():get_godmode() then
                    displayHudBanner("GBC_HUD_VH", "GREEN_LIV5", "", 109)
                else
                    displayHudBanner("GBC_HUD_VH", "CELL_840", "", 109)
                end
            end
        end)
    else
        menu.remove_hotkey(vehicleGodmodeHotkey)
        vehicleGodmodeHotkey = nil
    end
end)

--F9, Godmode + No Ragdoll
local godmodeRagdollHotkey
menu.register_callback('ToggleGodmodeRagdollHotkey', function()
    if not godmodeRagdollHotkey then
        godmodeRagdollHotkey = menu.register_hotkey(120, function()
            localplayer:set_godmode(not localplayer:get_godmode())
            if localplayer:get_godmode() then
                localplayer:set_no_ragdoll(true)
                localplayer:set_infinite_ammo(true)
                localplayer:set_infinite_clip(true)
                displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV1", "", 109)
            else
                localplayer:set_no_ragdoll(false)
                localplayer:set_infinite_ammo(false)
                localplayer:set_infinite_clip(false)
                displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV0", "", 109)
            end
        end)
    else
        menu.remove_hotkey(godmodeRagdollHotkey)
        godmodeRagdollHotkey = nil
    end
end)

local suicideHotkey
menu.register_callback('ToggleSuicideHotkey', function()
    if not suicideHotkey then
        suicideHotkey = menu.register_hotkey(115, function()
            menu.suicide_player()
        end)
    else
        menu.remove_hotkey(suicideHotkey)
        suicideHotkey = nil
    end
end)

local enterPVHotkey
menu.register_callback('ToggleEnterPVHotkey', function()
    if not enterPVHotkey then
        enterPVHotkey = menu.register_hotkey(114, function()
            menu.enter_personal_vehicle()
        end)
    else
        menu.remove_hotkey(enterPVHotkey)
        enterPVHotkey = nil
    end
end)

local teleportWaypointHotkey
menu.register_callback('ToggleTeleportToWaypointHotkey', function()
    if not teleportWaypointHotkey then
        teleportWaypointHotkey = menu.register_hotkey(112, function()
            menu.teleport_to_waypoint()
        end)
    else
        menu.remove_hotkey(teleportWaypointHotkey)
        teleportWaypointHotkey = nil
    end
end)

local teleportObjectiveHotkey
menu.register_callback('ToggleTeleportToObjectiveHotkey', function()
    if not teleportObjectiveHotkey then
        teleportObjectiveHotkey = menu.register_hotkey(113, function()
            menu.teleport_to_objective()
        end)
    else
        menu.remove_hotkey(teleportObjectiveHotkey)
        teleportObjectiveHotkey = nil
    end
end)

local function sortHotkeysData()
    table.sort(hotkeysData, function(a, b)
        return a.name < b.name
    end)
end

-- Function to add all the hotkey toggles
local function addHotkeyToggles()
    sortHotkeysData()
    for _, hotkeyData in ipairs(hotkeysData) do
        configSub:add_toggle(hotkeyData.name .. " Hotkey", function()
            return hotkeyData.toggleVar
        end, function(toggle)
            hotkeyData.toggleVar = toggle
            menu.emit_event(hotkeyData.event)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/HOTKEY_CONFIG.json", hotkeysData)
        end)
        if hotkeyData.toggleVar then menu.emit_event(hotkeyData.event) end
    end
end

greyText(configSub, "Changes are saved automatically!!")
greyText(configSub, "---------------------------------")

addHotkeyToggles()