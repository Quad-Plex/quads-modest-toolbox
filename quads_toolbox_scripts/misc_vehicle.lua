greyText(vehicleOptionsSub, "---- Pers. Vehicle Remote Control ----")

----------------- Remote Control Vehicle -----------------
local doorStates = {[0]="Driver", "Passenger", "Back Left", "Back Right", "All", "None"}
local engineStates = {[0]="Off", "On"}
local stanceStates = {[0]="Default", "Lowered"}
local roofStates = {[0]="Up", "Down"}
local hydraulicStates = { [0]="All", "Front", "Rear", "Off"}
local doorState = 0
local engineState = 0
local headlightState = 0
local neonLightState = 0
local radioState = 0
local stanceState = 0
local roofState = 0
local hydraulicState = 0
local flappyDoors = false
local strobeLights = false
local rcSpamRunning = false
vehicleOptionsSub:add_toggle("Flappy Vehicle Doors", function() return flappyDoors end, function(toggle)
    flappyDoors = toggle
    if flappyDoors then
        if not rcSpamRunning then
            menu.emit_event("startRCSpamThread")
        end
    end
end)

vehicleOptionsSub:add_toggle("Strobe Vehicle Lights", function() return strobeLights end, function(toggle)
    strobeLights = toggle
    if strobeLights then
        if not rcSpamRunning then
            menu.emit_event("startRCSpamThread")
        end
    end
end)

vehicleOptionsSub:add_array_item("Pers. Vehicle Engine:", engineStates, function() return engineState end, function(state)
    engineState = state
    if engineStates[engineState] == "On" then
        toggleVehicleState("engine_on")
    else
        toggleVehicleState("engine_off")
    end
end)

vehicleOptionsSub:add_array_item("Headlights:", engineStates, function() return headlightState end, function(state)
    headlightState = state
    if engineStates[headlightState] == "On" then
        toggleVehicleState("headlights_on")
    else
        toggleVehicleState("headlights_off")
    end
end)

vehicleOptionsSub:add_array_item("Neon Lights:", engineStates, function() return neonLightState end, function(state)
    neonLightState = state
    if engineStates[neonLightState] == "On" then
        toggleVehicleState("neon_lights_on")
    else
        toggleVehicleState("neon_lights_off")
    end
end)

vehicleOptionsSub:add_array_item("Radio:", engineStates, function() return radioState end, function(state)
    radioState = state
    if engineStates[radioState] == "On" then
        toggleVehicleState("radio_on")
    else
        toggleVehicleState("radio_off")
    end
end)

vehicleOptionsSub:add_array_item("Stance:", stanceStates, function() return stanceState end, function(state)
    stanceState = state
    if stanceStates[stanceState] == "Default" then
        toggleVehicleState("stance_default")
    else
        toggleVehicleState("stance_lowered")
    end
end)

vehicleOptionsSub:add_array_item("Roof:", roofStates, function() return roofState end, function(state)
    roofState = state
    if roofStates[roofState] == "Up" then
        toggleVehicleState("roof_up")
    else
        toggleVehicleState("roof_down")
    end
end)

vehicleOptionsSub:add_array_item("Hydraulics:", hydraulicStates, function() return hydraulicState end, function(state)
    hydraulicState = state
    if hydraulicStates[hydraulicState] == "All" then
        toggleVehicleState("hydraulics_all")
    elseif hydraulicStates[hydraulicState] == "Front" then
        toggleVehicleState("hydraulics_front")
    elseif hydraulicStates[hydraulicState] == "Rear" then
        toggleVehicleState("hydraulics_rear")
    elseif hydraulicStates[hydraulicState] == "Off" then
        toggleVehicleState("hydraulics_off")
    end
end)

vehicleOptionsSub:add_array_item("Open Vehicle Doors:", doorStates, function() return doorState end, function(state)
    doorState = state
    if doorStates[doorState] == "Driver" then
        setDoorBit(0, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "Passenger" then
        setDoorBit(1, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "Back Left" then
        setDoorBit(2, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "Back Right" then
        setDoorBit(3, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "All" then
        setDoorBit(0,1)
        setDoorBit(1, 1)
        setDoorBit(2, 1)
        setDoorBit(3, 1)
        toggleVehicleState("open_door")
    else
        setDoorBit(0,0)
        setDoorBit(1, 0)
        setDoorBit(2, 0)
        setDoorBit(3, 0)
        toggleVehicleState("open_door")
    end
end)

local function rcSpamThread()
    rcSpamRunning = true
    local counter = 0
    local counter2 = 0
    while strobeLights or flappyDoors do
        if not localplayer:is_in_vehicle() then
            strobeLights = false
            flappyDoors = false
            rcSpamRunning = false
            return
        end
        counter = counter + 1
        if counter < 6 then
            if strobeLights then
                toggleVehicleState("headlights_on", "neon_lights_on")
            end
            sleep(0.04)
            if strobeLights then
                toggleVehicleState("headlights_off", "neon_lights_off")
            end
            sleep(0.04)
        elseif flappyDoors and strobeLights then
            if flappyDoors then
                if counter2 == 0 then
                    setDoorBit(0,1)
                    setDoorBit(1, 1)
                    setDoorBit(2, 1)
                    setDoorBit(3, 1)
                else
                    setDoorBit(0,0)
                    setDoorBit(1, 0)
                    setDoorBit(2, 0)
                    setDoorBit(3, 0)
                end
            end
            toggleVehicleState("headlights_on", "neon_lights_on", "open_door")
            sleep(0.04)
            toggleVehicleState("headlights_off", "neon_lights_off")
            sleep(0.04)
            counter = 0
            counter2 = 1 - counter2
        elseif flappyDoors then
            if counter2 == 0 then
                setDoorBit(0,1)
                setDoorBit(1, 1)
                setDoorBit(2, 1)
                setDoorBit(3, 1)
            else
                setDoorBit(0,0)
                setDoorBit(1, 0)
                setDoorBit(2, 0)
                setDoorBit(3, 0)
            end
            toggleVehicleState("open_door")
            sleep(0.04)
            counter = 0
            counter2 = 1 - counter2
        else
            counter = 0
        end
    end
    rcSpamRunning = false
end
menu.register_callback("startRCSpamThread", rcSpamThread)

------------------------------ Vehicle TP Options -----------------------------
greyText(vehicleOptionsSub, "------------ Misc -----------")
vehicleOptionsSub:add_action("Enter last spawned car", function()
    local vehicleNetID = getNetIDOfLastSpawnedVehicle()
    if vehicleNetID then setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position()) end
end)