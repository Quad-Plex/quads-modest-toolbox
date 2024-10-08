-------------------- Define the hotkeys data ------------------------------------------------
success, hotkeysData = pcall(json.loadfile, "QUAD_TOOLBOX_HOTKEYS.json")
if success then
    print("Hotkey Configuration loaded successfully!!")
else
    print("Couldn't find hotkey configuration, creating a new one...")
    hotkeysData = {
        {
            event = "ToggleAtomizerHotkey",
            keycode = 161,
            name = "Atomizer Gun",
            toggleVar = false
        },
        {
            event = "ToggleCarapultHotkey",
            keycode = 106,
            name = "Car Launcher",
            toggleVar = false
        },
        {
            event = "ToggleCarBoostHotkey",
            keycode = 45,
            name = "Car Boost",
            toggleVar = false
        },
        {
            event = "ToggleCarjumpHotkey",
            keycode = 18,
            name = "Carjump",
            toggleVar = false
        },
        {
            event = "ToggleEnterPVHotkey",
            keycode = 114,
            name = "Enter PV",
            toggleVar = false
        },
        {
            event = "ToggleExplosionGunHotkey",
            keycode = 163,
            name = "Explosive Gun",
            toggleVar = false
        },
        {
            event = "ToggleGodmodeRagdollHotkey",
            keycode = 120,
            name = "Godmode/Ragdoll/Inf Ammo",
            toggleVar = false
        },
        {
            event = "ToggleHealthAndArmorHotkey",
            keycode = 117,
            name = "Health/Armor Refill",
            toggleVar = false
        },
        {
            event = "ToggleMassiveCarHotkey",
            keycode = 123,
            name = "Massive Car",
            toggleVar = false
        },
        {
            event = "ToggleNoclipHotkey",
            keycode = 111,
            name = "Noclip",
            toggleVar = false
        },
        {
            event = "ToggleRandomVehicleHotkey",
            keycode = 122,
            name = "Random Veh. Spawner",
            toggleVar = false
        },
        {
            event = "ToggleWantedLevelHotkey",
            keycode = 46,
            name = "Remove Cops",
            toggleVar = false
        },
        {
            event = "ToggleRepairVehicleHotkey",
            keycode = 118,
            name = "Repair Vehicle",
            toggleVar = false
        },
        {
            event = "ToggleLoopStopHotkey",
            keycode = 110,
            name = "Stop Loop Actions",
            toggleVar = false
        },
        {
            event = "ToggleSuicideHotkey",
            keycode = 115,
            name = "Suicide",
            toggleVar = false
        },
        {
            event = "ToggleTeleportToObjectiveHotkey",
            keycode = 113,
            name = "TP to Objective",
            toggleVar = false
        },
        {
            event = "ToggleTeleportToWaypointHotkey",
            keycode = 112,
            name = "TP to Waypoint",
            toggleVar = false
        },
        {
            event = "ToggleOffradarHotkey",
            keycode = 121,
            name = "Offradar",
            toggleVar = false
        },
        {
            event = "ToggleVehicleGodmodeHotkey",
            keycode = 119,
            name = "Vehicle Godmode",
            toggleVar = false
        }
    }
    json.savefile("QUAD_TOOLBOX_HOTKEYS.json", hotkeysData)
end

table.sort(hotkeysData, function(a, b)
    return a.name < b.name
end)

indexedKeycodes = {}
for key, keyCode in pairs(keycodes) do
    indexedKeycodes[keyCode]=key
end

sortedKeycodes = {}
for k in pairs(keycodes) do
    table.insert(sortedKeycodes, k)
end
table.sort(sortedKeycodes)
--------------------------------------- HOTKEY FUNCTIONS ------------------------------------------------------
--numpad comma (decimal) key, emergency stop all auto actions button
local emergencyStopHotkey
menu.register_callback('ToggleLoopStopHotkey', function()
    if not emergencyStopHotkey then
        emergencyStopHotkey = menu.register_hotkey(find_keycode("ToggleLoopStopHotkey"), function()
            loopData = {}
            emergencyStopLoops()
        end)
    else
        menu.remove_hotkey(emergencyStopHotkey)
        emergencyStopHotkey = nil
    end
end)

--Del, Lose Wanted level
local loseWantedLevelHotkey
menu.register_callback('ToggleWantedLevelHotkey', function()
    if not loseWantedLevelHotkey then
        loseWantedLevelHotkey = menu.register_hotkey(find_keycode("ToggleWantedLevelHotkey"), function()
            menu.clear_wanted_level()
            --menu.set_bribe_authorities(not menu.get_bribe_authorities())
            menu.set_cops_turn_blind_eye(not menu.get_cops_turn_blind_eye())
            displayHudBanner("LOSE_WANTED", "LEST_NCOPS", "", 108)
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
        maxHealthArmorHotkey = menu.register_hotkey(find_keycode("ToggleHealthAndArmorHotkey"), function()
            menu.heal_all()
            menu.max_all_ammo()
            clearBlood()
            displayHudBanner("CHEAT_HEALTH_ARMOR", "PIM_FULL1", "", 108)
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
        repairVehicleHotkey = menu.register_hotkey(find_keycode("ToggleRepairVehicleHotkey"), function()
            menu.repair_online_vehicle()
            displayHudBanner("BLIP_402", "", "", 108)
        end)
    else
        menu.remove_hotkey(repairVehicleHotkey)
        repairVehicleHotkey = nil
    end
end)

--F8, Vehicle Godmode
local vehicleGodmodeHotkey
local oldDefMul
menu.register_callback('ToggleVehicleGodmodeHotkey', function()
    if not vehicleGodmodeHotkey then
        vehicleGodmodeHotkey = menu.register_hotkey(find_keycode("ToggleVehicleGodmodeHotkey"), function()
            if localplayer:is_in_vehicle() then
                localplayer:get_current_vehicle():set_godmode(not localplayer:get_current_vehicle():get_godmode())
                local defMul = localplayer:get_current_vehicle():get_deformation_damage_multiplier()
                if localplayer:get_current_vehicle():get_godmode() then
                    oldDefMul = defMul
                    localplayer:get_current_vehicle():set_deformation_damage_multiplier(0)
                else
                    if oldDefMul then
                        localplayer:get_current_vehicle():set_deformation_damage_multiplier(oldDefMul)
                    end
                end

                if localplayer:get_current_vehicle():get_godmode() then
                    displayHudBanner("GBC_HUD_VH", "GREEN_LIV5", "", 108)
                else
                    displayHudBanner("GBC_HUD_VH", "CELL_840", "", 108)
                end
            end
        end)
    else
        menu.remove_hotkey(vehicleGodmodeHotkey)
        vehicleGodmodeHotkey = nil
    end
end)

local godmodeEnabled = false
local godmodeRunning = false
local function godmodeChecker()
    while godmodeEnabled do
        if not localplayer then
            godmodeEnabled = false
            godmodeRunning = false
            return
        end
        godmodeRunning = true
        if not localplayer:get_godmode() then
            localplayer:set_godmode(true)
            localplayer:set_no_ragdoll(true)
            localplayer:set_infinite_ammo(true)
            localplayer:set_infinite_clip(true)
        end
        sleep(2)
    end
    godmodeRunning = false
    localplayer:set_godmode(false)
    localplayer:set_no_ragdoll(false)
    localplayer:set_infinite_ammo(false)
    localplayer:set_infinite_clip(false)
end

menu.register_callback('GodmodeChecker', godmodeChecker)

--F9, Godmode + No Ragdoll
local godmodeRagdollHotkey
menu.register_callback('ToggleGodmodeRagdollHotkey', function()
    if not godmodeRagdollHotkey then
        godmodeRagdollHotkey = menu.register_hotkey(find_keycode("ToggleGodmodeRagdollHotkey"), function()
            if not localplayer:get_godmode() then
                godmodeEnabled = true
                localplayer:set_godmode(true)
                localplayer:set_no_ragdoll(true)
                localplayer:set_infinite_ammo(true)
                localplayer:set_infinite_clip(true)
                displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV1", "", 108)
                if not godmodeRunning then
                    menu.emit_event('GodmodeChecker')
                end
            else
                godmodeEnabled = false
                localplayer:set_godmode(false)
                localplayer:set_no_ragdoll(false)
                localplayer:set_infinite_ammo(false)
                localplayer:set_infinite_clip(false)
                displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV0", "", 108)
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
        suicideHotkey = menu.register_hotkey(find_keycode("ToggleSuicideHotkey"), function()
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
        enterPVHotkey = menu.register_hotkey(find_keycode("ToggleEnterPVHotkey"), function()
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
        teleportWaypointHotkey = menu.register_hotkey(find_keycode("ToggleTeleportToWaypointHotkey"), function()
            menu.teleport_to_waypoint()
            local tpPos = localplayer:get_position()
            tpPos.z = -200
            nativeTeleport(tpPos)
            sleep(0.1)
            nativeTeleport(tpPos)
        end)
    else
        menu.remove_hotkey(teleportWaypointHotkey)
        teleportWaypointHotkey = nil
    end
end)

local teleportObjectiveHotkey
menu.register_callback('ToggleTeleportToObjectiveHotkey', function()
    if not teleportObjectiveHotkey then
        teleportObjectiveHotkey = menu.register_hotkey(find_keycode("ToggleTeleportToObjectiveHotkey"), function()
            menu.teleport_to_objective()
            local tpPos = localplayer:get_position()
            tpPos.z = -200
            nativeTeleport(tpPos)
            sleep(0.1)
            nativeTeleport(tpPos)
        end)
    else
        menu.remove_hotkey(teleportObjectiveHotkey)
        teleportObjectiveHotkey = nil
    end
end)

-- Function to add all the hotkey toggles
local function addHotkeyToggles(hotkeyMenu)
    hotkeyMenu:clear()
    addText(hotkeyMenu, centeredText("    ⚙️ Hotkey Config ⚙️"))
    greyText(hotkeyMenu, "Changes are saved automatically!!")
    greyText(hotkeyMenu, "----------------------------------")
    for i, hotkeyData in ipairs(hotkeysData) do
        hotkeyMenu:add_toggle(hotkeyData.name .. " Hotkey", function()
            return hotkeyData.toggleVar
        end, function(toggle)
            hotkeyData.toggleVar = toggle
            hotkeysData[i]=hotkeyData
            json.savefile("QUAD_TOOLBOX_HOTKEYS.json", hotkeysData)
            if hotkeyData.toggleVar then
                displayHudBanner("PM_PANE_KEYS", "CANNON_CAM_ACTIVE", "", 108)
            else
                displayHudBanner("PM_PANE_KEYS", "CANNON_CAM_INACTIVE", "", 108)
            end
            menu.emit_event(hotkeyData.event)
        end)
        hotkeyMenu:add_array_item("", indexedKeycodes, function()
            return hotkeyData.keycode
        end, function(value)
            hotkeyData.keycode = value
            hotkeysData[i]=hotkeyData
            json.savefile("QUAD_TOOLBOX_HOTKEYS.json", hotkeysData)
            if hotkeyData.toggleVar then
                displayHudBanner("PM_PANE_KEYS", "HEIST_IB_NAV2", "", 108)
                --Hotkey is already enabled, so to toggle it twice to un-set it and then set it to the new keycode
                menu.emit_event(hotkeyData.event)
                sleep(0.1)
                menu.emit_event(hotkeyData.event)
            end
        end)
    end
end

local hotkeyMenu
hotkeyMenu = toolboxSub:add_submenu(centeredText("    ⚙️ Hotkey Configuration ⚙️"), function()
    if finishedLoading then
        addHotkeyToggles(hotkeyMenu)
    end
end)

--Enable all Hotkeys once when this script is loaded
for _, hotkeyData in ipairs(hotkeysData) do
    if hotkeyData.toggleVar then menu.emit_event(hotkeyData.event) end
end