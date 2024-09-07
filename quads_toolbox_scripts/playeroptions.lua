--------------------------------
--HIDE NAME FROM LIST AND BLIP
--------------------------------
greyText(playerOptionsSub, "-------- Player Options --------")
playerOptionsSub:add_action("Remove Blood from player", function() clearBlood() end)

playerOptionsSub:add_toggle("Tiny Player", function()
    if not localplayer then return nil	end
    return localplayer:get_config_flag(223) --see PED_FLAG_TABLE[223] = "Shrink"
end, function(value)
    localplayer:set_config_flag(223, value)
end)

function offRadar()
    if localplayer ~= nil then
        if not isHidden() then
            displayHudBanner("PM_UCON_T32", "CANNON_CAM_ACTIVE", "", 108)
            hidePlayer(true)
        else
            displayHudBanner("PM_UCON_T32", "CANNON_CAM_INACTIVE", "", 108)
            hidePlayer(false)
        end
    end
end

playerOptionsSub:add_toggle("Hide Name/Blip from Map:  |👻", function()
    return isHidden()
end, function(_)
    offRadar()
end)

local offradarHotkey
menu.register_callback('ToggleOffradarHotkey', function()
    if not offradarHotkey then
        offradarHotkey = menu.register_hotkey(find_keycode("ToggleOffradarHotkey"), offRadar)
    else
        menu.remove_hotkey(offradarHotkey)
        offradarHotkey = nil
    end
end)

--------------------------------
-- Phone Disabler
--------------------------------
playerOptionsSub:add_toggle("Disable Phone  |🚫📱", function() return phoneDisabledState end, function(toggle) setPhoneDisabled(toggle) end)

--------------------------------
--Snack refill
--------------------------------

local function refillInventory()
    stats.set_int(mpx().."NO_BOUGHT_YUM_SNACKS", 30)
    stats.set_int(mpx().."NO_BOUGHT_HEALTH_SNACKS", 15)
    stats.set_int(mpx().."NO_BOUGHT_EPIC_SNACKS", 5)
    stats.set_int(mpx().."NUMBER_OF_ORANGE_BOUGHT", 10)
    stats.set_int(mpx().."NUMBER_OF_BOURGE_BOUGHT", 10)
    stats.set_int(mpx().."NUMBER_OF_CHAMP_BOUGHT", 5)
    stats.set_int(mpx().."CIGARETTES_BOUGHT", 20)
    stats.set_int(mpx().."MP_CHAR_ARMOUR_1_COUNT", 10)
    stats.set_int(mpx().."MP_CHAR_ARMOUR_2_COUNT", 10)
    stats.set_int(mpx().."MP_CHAR_ARMOUR_3_COUNT", 10)
    stats.set_int(mpx().."MP_CHAR_ARMOUR_4_COUNT", 10)
    stats.set_int(mpx().."MP_CHAR_ARMOUR_5_COUNT", 10)
    displayHudBanner("PIM_TINVE", "CC_BLUSH_0", "", 108)
end

playerOptionsSub:add_action("Refill Inventory |🍪🍫🍾", function()
    refillInventory()
end)

----------------------Respawn State changer----------------------
greyText(playerOptionsSub, "-------- Unstuck Options --------")
local stateToSet = 7
playerOptionsSub:add_int_range("Trigger Respawn (Unstuck) |🔁", 1, -10, 100, function() return stateToSet end, function(n)
    displayHudBanner("TRI_WARP", "", "", 108)
    sleep(0.3)
    stateToSet = n
    setPlayerRespawnState(getLocalplayerID(), n)
end)

playerOptionsSub:add_action("Reset Character/Give Back Weapons", function() enableWeapons() end)

playerOptionsSub:add_action("\u{26A0} Fix Stuck Loading Screen \u{26A0}", function()
    clearBlood()
    enableWeapons()
    noclip(true, true)
    sleep(0.1)
    noclip(false, true)
    fixPedVehTeleport()
end)


---------------- Money Remover -------------------
greyText(playerOptionsSub, "------ Money Remover ------")
greyText(playerOptionsSub, "This changes how much money you lose")
greyText(playerOptionsSub, "from the 'Make it Rain' gesture")
greyText(playerOptionsSub, "Can be used to remove money quick")
playerOptionsSub:add_int_range("Increase Make It Rain amount", 100000, 0, 5000000, function() return getMakeItRainAmount() end, function(n) setMakeItRainAmount(n) end)
playerOptionsSub:add_action("Reset Make It Rain to 1000$", function() setMakeItRainAmount(1000) end)


---------------------Stat Increaser ----------------------
greyText(playerOptionsSub, "-------- Player Stats --------")

local statsList = {
    {"Stamina", "STAMINA", "STAM"},
    {"Shooting", "SHOOTING_ABILITY", "SHO"},
    {"Strength", "STRENGTH", "STRN"},
    {"Stealth", "STEALTH_ABILITY", "STL"},
    {"Flying", "FLYING_ABILITY", "FLY"},
    {"Driving", "WHEELIE_ABILITY", "DRIV"},
    {"Lung capacity", "LUNG_CAPACITY", "LUNG"},
    {"Mental State", "PLAYER_MENTAL_STATE", "PLAYER_MENTAL_STATE"}
}

local function playerStatChanger(sub)
    sub:clear()
    for _, stat in pairs(statsList) do
        local statName, statGet, statSet = table.unpack(stat)

        if statName == "Mental State" then
            sub:add_float_range("Change " .. statName, 2, 0, 100, function()
                return stats.get_float(mpx() .. statGet)
            end, function(state)
                stats.set_float(mpx() .. statGet, state)
            end)
        else
            sub:add_int_range(statName, 1, 0, 100, function()
                return stats.get_int(mpx() .. statGet)
            end, null)
            sub:add_action("Add +10 to " .. statName, function()
                stats.set_int(mpx() .. "SCRIPT_INCREASE_" .. statSet, 10)
            end, function() return stats.get_int(mpx() .. statGet) < 100 end)
        end
    end
end

local playerStatsSub
playerStatsSub = playerOptionsSub:add_submenu("Change Player Stats", function() playerStatChanger(playerStatsSub) end)