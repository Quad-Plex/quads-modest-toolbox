greyText(vehicleOptionsSub, "---- Pers. Vehicle Remote Control ----")
greyText(vehicleOptionsSub, "-- ONLY WORKS ON PERSONAL VEH.! --")


----------------- Remote Control Vehicle -----------------
local doorStates = {[0]="Driver", "Passenger", "Back Left", "Back Right", "Hood", "Trunk", "All", "None"}
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
--Not a local because we need it for the global check
flappyDoors = false
rcSpamRunning = false
strobeLights = false
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
    elseif doorStates[doorState] == "Hood" then
        setDoorBit(4, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "Trunk" then
        setDoorBit(5, 1)
        toggleVehicleState("open_door")
    elseif doorStates[doorState] == "All" then
        setDoorBit(0,1)
        setDoorBit(1, 1)
        setDoorBit(2, 1)
        setDoorBit(3, 1)
        setDoorBit(4, 1)
        setDoorBit(5, 1)
        toggleVehicleState("open_door")
    else
        setDoorBit(0,0)
        setDoorBit(1, 0)
        setDoorBit(2, 0)
        setDoorBit(3, 0)
        setDoorBit(4, 0)
        setDoorBit(5, 0)
        toggleVehicleState("open_door")
    end
end)

local function rcSpamThread()
    rcSpamRunning = true
    local counter = 0
    local counter2 = 0
    local disableVehicleCheck
    if not localplayer:is_in_vehicle() then
        disableVehicleCheck = true
    end
    while strobeLights or flappyDoors do
        if not localplayer:is_in_vehicle() and not disableVehicleCheck then
            strobeLights = false
            flappyDoors = false
            break
        end
        counter = counter + 1
        if counter < 5 then
            if strobeLights then
                toggleVehicleState("headlights_on", "neon_lights_on")
            end
            sleep(0.06)
            if strobeLights then
                toggleVehicleState("headlights_off", "neon_lights_off")
            end
            sleep(0.06)
        elseif flappyDoors and strobeLights then
            if flappyDoors then
                if counter2 == 0 then
                    setDoorBit(0,1)
                    setDoorBit(1, 1)
                    setDoorBit(2, 1)
                    setDoorBit(3, 1)
                    setDoorBit(4, 1)
                    setDoorBit(5, 1)
                else
                    setDoorBit(0,0)
                    setDoorBit(1, 0)
                    setDoorBit(2, 0)
                    setDoorBit(3, 0)
                    setDoorBit(4, 0)
                    setDoorBit(5, 0)
                end
            end
            toggleVehicleState("headlights_on", "neon_lights_on", "open_door")
            sleep(0.06)
            toggleVehicleState("headlights_off", "neon_lights_off")
            sleep(0.06)
            counter = 0
            counter2 = 1 - counter2
        elseif flappyDoors then
            if counter2 == 0 then
                setDoorBit(0,1)
                setDoorBit(1, 1)
                setDoorBit(2, 1)
                setDoorBit(3, 1)
                setDoorBit(4, 1)
                setDoorBit(5, 1)
            else
                setDoorBit(0,0)
                setDoorBit(1, 0)
                setDoorBit(2, 0)
                setDoorBit(3, 0)
                setDoorBit(4, 0)
                setDoorBit(5, 0)
            end
            toggleVehicleState("open_door")
            sleep(0.06)
            counter = 0
            counter2 = 1 - counter2
        else
            counter = 0
        end
    end
    rcSpamRunning = false
    sleep(0.3)
    setDoorBit(0,0)
    setDoorBit(1, 0)
    setDoorBit(2, 0)
    setDoorBit(3, 0)
    setDoorBit(4, 0)
    setDoorBit(5, 0)
    toggleVehicleState("open_door")
end
menu.register_callback("startRCSpamThread", rcSpamThread)

------------------------------ Misc Options -----------------------------
greyText(vehicleOptionsSub, "------------ Misc -----------")
-----------------------------------
--Unlock all car doors
--------------------------------
---From: https://github.com/flotwig/GTAV-Motion/blob/master/GTAV-Motion/inc/enums.h
--enum eVehicleLockState {
--    VEHICLELOCK_NONE = 0, // No specific lock state, vehicle behaves according to the game's default settings.
--    VEHICLELOCK_UNLOCKED = 1, // Vehicle is fully unlocked, allowing free entry by players and NPCs.
--    VEHICLELOCK_LOCKED = 2, // Vehicle is locked, preventing entry by players and NPCs.
--    VEHICLELOCK_LOCKOUT_PLAYER_ONLY = 3, // Vehicle locks out only players, allowing NPCs to enter.
--    VEHICLELOCK_LOCKED_PLAYER_INSIDE = 4, // Vehicle is locked once a player enters, preventing others from entering.
--    VEHICLELOCK_LOCKED_INITIALLY = 5, // Vehicle starts in a locked state, but may be unlocked through game events.
--    VEHICLELOCK_FORCE_SHUT_DOORS = 6, // Forces the vehicle's doors to shut and lock.
--    VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED = 7, // Vehicle is locked but can still be damaged.
--    VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED = 8, // Vehicle is locked, but its trunk/boot remains unlocked.
--    VEHICLELOCK_LOCKED_NO_PASSENGERS = 9, // Vehicle is locked and does not allow passengers, except for the driver.
--    VEHICLELOCK_CANNOT_ENTER = 10 // Vehicle is completely locked, preventing entry entirely, even if previously inside.
--};
local openTypes = { [0]="Unlock All", "Lock All"}
local openType = 0
vehicleOptionsSub:add_array_item("Car Door Locks (Buggy):", openTypes, function() return openType end, function(value)
    openType = value
    for veh in replayinterface.get_vehicles() do
        if openTypes[openType] == "Unlock All" then
            veh:set_door_lock_state(1)
        else
            veh:set_door_lock_state(2)
        end
    end
end)

vehicleOptionsSub:add_action("TP into last spawned car", function()
    local vehicleNetID = getNetIDOfLastSpawnedVehicle()
    if vehicleNetID then setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position()) end
end)