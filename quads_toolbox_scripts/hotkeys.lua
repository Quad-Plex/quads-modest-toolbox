require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")
--F6, Max health and armor
menu.register_hotkey(117, function() displayHudBanner("CHEAT_HEALTH_ARMOR", "PIM_FULL1", "", 109) end)
-- F7, Repair
menu.register_hotkey(118, function() displayHudBanner("BLIP_402", "", "", 109) end)
--F8, Vehicle Godmode
menu.register_hotkey(119, function()
    if localplayer:is_in_vehicle() then
        localplayer:get_current_vehicle():set_godmode(not localplayer:get_current_vehicle():get_godmode())

        if localplayer:get_current_vehicle():get_godmode() then
            displayHudBanner("GBC_HUD_VH", "GREEN_LIV5", "", 109)
        else
            displayHudBanner("GBC_HUD_VH", "CELL_840", "", 109)
        end
    end
end)
--F9, Godmode + No Ragdoll
menu.register_hotkey(120, function()
    sleep(0.1)
    if localplayer:get_godmode() then
        localplayer:set_no_ragdoll(true)
        displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV1", "", 109)
    else
        localplayer:set_no_ragdoll(false)
        displayHudBanner("GREEN_LIV5", "PIM_NCL_PRIV0", "", 109)
    end
end)
--Del, Lose Wanted level
menu.register_hotkey(46, function() displayHudBanner("LOSE_WANTED", "LEST_NCOPS", "", 109) end)

--------------------------------
--Cops Ignore Hotkey (PgDwn)
--------------------------------
menu.register_hotkey(34, function()
    localplayer:set_police_ignore(not localplayer:get_police_ignore())
    if localplayer:get_police_ignore() then
        displayHudBanner("BLIP_3", "PIM_NCL_PRIV0", "", 109)
    else
        displayHudBanner("BLIP_3", "PIM_NCL_PRIV1", "", 109)
    end
end)