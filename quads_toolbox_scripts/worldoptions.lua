greyText(worldOptionsSub, centeredText("🌍 World Options 🌍"))
--------------------------------
--remove traffic loop
--------------------------------
worldOptionsSub:add_toggle("🚫🚗 Remove nearby traffic 🚗🚫", function()
    return loopData.removeTrafficToggle
end, function(value)
    if value then
        loopData.removeTrafficToggle = true
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        menu.emit_event('removeTraffic')
    else
        loopData.removeTrafficToggle = false
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
    end end)

--------------------------------
--remove peds loop
--------------------------------
worldOptionsSub:add_toggle("🚫🚶 Remove nearby NPCs 🚶🚫", function()
    return loopData.removeNpcToggle
end, function(value)
    if value then
        loopData.removeNpcToggle = true
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        menu.emit_event('autoRemoveNpcs')
    else
        loopData.removeNpcToggle = false
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
    end end)

----------------------Respawn State changer----------------------
greyText(worldOptionsSub, "-------- Unstuck Options --------")
local stateToSet = 7
worldOptionsSub:add_int_range("Trigger Respawn (Unstuck) |🔁", 1, -10, 100, function() return stateToSet end, function(n)
    displayHudBanner("TRI_WARP", "", "", 108)
    sleep(0.3)
    stateToSet = n
    setPlayerRespawnState(getLocalplayerID(), n)
end)

worldOptionsSub:add_action("Reset Character/Give Back Weapons", function() enableWeapons() end)

greyText(worldOptionsSub, "-------- Map Options --------")
worldOptionsSub:add_toggle("❄️ Turn Snow On/Off ❄️", function() return isSnowTurnedOn() end, function(n) changeSnowGlobal(n) end)

greyText(worldOptionsSub, "-------- Game Options --------")
worldOptionsSub:add_action("⏩ End Cutscene ⏩", function() menu.end_cutscene() end)
worldOptionsSub:add_action("🚫 Empty Session 🚫", function() menu.empty_session() end)
worldOptionsSub:add_action("❌ Force Close GTA ❌", function() setPlayerModel(joaat("slod_small_quadped")) end)
