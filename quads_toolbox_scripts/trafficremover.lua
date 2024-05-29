--------------------------------
--traffic noclip
--------------------------------
local trafficNoclipToggle = false
function vehicleNoclipThread()
    if not localplayer:is_in_vehicle() then trafficNoclipToggle = false end
    while trafficNoclipToggle do
        if not localplayer:is_in_vehicle() or localplayer:get_health() == 0 then
            trafficNoclipToggle = false
            return
        end
        setPlayerRespawnState(getLocalplayerID(), 9)
        sleep(3.2) --The effect sticks around a bit so we don't need to spam it that hard
    end
end
menu.register_callback('vehicleNoclip', vehicleNoclipThread)

vehicleOptionsSub:add_toggle("Disable Traffic/Player Collisions", function()
    return trafficNoclipToggle
end, function(value)
    trafficNoclipToggle = value
    menu.emit_event('vehicleNoclip')
end)

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
                local pos = veh:get_position() + vector3(0, 0, -200)
                for _ = 0, 1000 do
                    veh:set_position(pos)
                end
            end
        end
        sleep(0.05)
    end
end
menu.register_callback('removeTraffic', removeTrafficThread)

vehicleOptionsSub:add_toggle("Remove nearby traffic", function()
    return removeTrafficToggle
end, function(value)
    removeTrafficToggle = value
    menu.emit_event('removeTraffic')
end)