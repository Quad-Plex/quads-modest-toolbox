--------------------------------
--traffic noclip
--------------------------------
vehicleOptionsSub:add_toggle("Disable Traffic/Player Collisions", function()
    return loopData.trafficNoclipToggle
end, function(value)
    if value then
        loopData.trafficNoclipToggle = true
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        menu.emit_event('vehicleNoclip')
    else
        loopData.trafficNoclipToggle = false
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
    end
end)

--------------------------------
--remove traffic loop
--------------------------------
vehicleOptionsSub:add_toggle("Remove nearby traffic", function()
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