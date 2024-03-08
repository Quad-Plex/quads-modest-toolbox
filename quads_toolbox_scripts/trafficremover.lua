require("scripts/quads_toolbox_scripts/toolbox_data/globals_and_utils")
--------------------------------
--remove traffic loop
--------------------------------
local removeTrafficToggle = false
local stopOnLeaving = false
function removeTrafficThread()
    if localplayer:is_in_vehicle() then stopOnLeaving = true end
    while removeTrafficToggle do
        if stopOnLeaving and not localplayer:is_in_vehicle() then
            stopOnLeaving, removeTrafficToggle = false, false
            return
        end
        local nonPlayerVehicles = getNonPlayerVehicles()
        for _, veh in pairs(nonPlayerVehicles) do
            if distanceBetween(localplayer, veh) < 80 then
                local pos = veh:get_position() + vector3(0, 0, -690)
                for _ = 0, 690 do
                    veh:set_position(pos)
                end
            end
        end
        sleep(0.05)
    end
end
menu.register_callback('removeTraffic', removeTrafficThread)

toolbox:add_toggle("Remove nearby traffic", function()
    return removeTrafficToggle
end, function(value)
    removeTrafficToggle = value
    menu.emit_event('removeTraffic')
end)