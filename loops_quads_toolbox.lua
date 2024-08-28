local folderTest, unused = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json")
if not folderTest then
    --We already throw an error for this in the launcher lua so we just silently exit this script
    return
end
unused = nil

require("scripts/quads_toolbox_scripts/toolbox_data/playerlist_loop_functions")

local function checkAndPerformEmergencyStop()
    if player.get_player_name(loopData.currentPlayerId) ~= loopData.currentPlayerName then
        emergencyStopLoops()
        return true
    end
    return false
end

--Used for loop-actions running on a player
--has a small oldPlayer backup to avoid some nil errors on player disconnect
local oldPlayer
local autoPly = function()
    local activePlayer = player.get_player_ped(loopData.currentPlayerId)
    if activePlayer and player.get_player_name(loopData.currentPlayerId) == loopData.currentPlayerName then
        oldPlayer = activePlayer
    elseif oldPlayer ~= nil then
        activePlayer = oldPlayer
        oldPlayer = nil
    end
    return activePlayer
end

------------------------------------------------------
-------------- AUTO ACTIONS START HERE ---------------
------------------------------------------------------
local function vehicleRainThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_rain and not checkAndPerformEmergencyStop() do
        randomVehicleRain(autoPly())
        sleep(0.07)
        updateLoopData()
    end
end
menu.register_callback('startRainThread', function()
    if loopData.auto_rain == true then
        loopData.auto_rain = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_rain = true
        saveLoopData()
        vehicleRainThread()
    end end)

local original_pos
local teleported = false
local function autoTeleportThread()
    updateLoopData()
    local myPlayer = player.get_player_ped()

    if not myPlayer or not loopData.auto_teleport then return end

    original_pos = myPlayer:get_position()
    myPlayer:set_godmode(true)
    myPlayer:set_max_health(0.0)
    myPlayer:set_freeze_momentum(true)
    myPlayer:set_no_ragdoll(true)
    local oldTeleportHeight = teleportHeight
    teleportHeight = 40

    while loopData.currentPlayerId and loopData.auto_teleport and not checkAndPerformEmergencyStop() do
        tpToPlayer(autoPly(), teleportHeight, myPlayer)
        teleported = true
        sleep(0.07)
        updateLoopData()
    end

    if teleported then
        teleportHeight = oldTeleportHeight
        myPlayer:set_godmode(false)
        myPlayer:set_max_health(328.0)
        myPlayer:set_freeze_momentum(false)
        myPlayer:set_no_ragdoll(false)
        nativeTeleport(original_pos)
        teleported = false
    end
end
menu.register_callback('startAutoTeleport', function()
    if loopData.auto_teleport == true then
        loopData.auto_teleport = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_teleport = true
        saveLoopData()
        autoTeleportThread()
    end end)

local function autoVehicleStormThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_storm and not checkAndPerformEmergencyStop() do
        teleportVehiclesToPlayer(autoPly(), 2, false)
        sleep(0.26)
        updateLoopData()
    end
end
menu.register_callback('autoVehicleStorm', function()
    if loopData.auto_storm == true then
        loopData.auto_storm = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_storm = true
        saveLoopData()
        autoVehicleStormThread()
    end end)

local function autoExplodeThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_explode and not checkAndPerformEmergencyStop() do
        teleportVehiclesToPlayer(autoPly():get_position(), 2, true, true)
        sleep(0.35)
        updateLoopData()
    end
end
menu.register_callback('startAutoExplode', function()
    if loopData.auto_explode == true then
        loopData.auto_explode = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_explode = true
        saveLoopData()
        autoExplodeThread()
    end end)

local function autoBikeSpamThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_bike and not checkAndPerformEmergencyStop() do
        giveRandomBike(autoPly())
        sleep(0.12)
        updateLoopData()
    end
end
menu.register_callback('autoBikeSpam', function()
    if loopData.auto_bike == true then
        loopData.auto_bike = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_bike = true
        saveLoopData()
        autoBikeSpamThread()
    end end)

local function autoPedSpamThread()
     updateLoopData()
    while loopData.currentPlayerId and loopData.auto_peds and not checkAndPerformEmergencyStop() do
        tpPedToPlayer(autoPly(), teleportType[teleportTypeSelection])
        sleep(0.09)
        updateLoopData()
    end
end
menu.register_callback('autoPedSpam', function()
    if loopData.auto_peds then
        loopData.auto_peds = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_peds = true
        saveLoopData()
        autoPedSpamThread()
    end end)

local function autoLaunchThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_launch and not checkAndPerformEmergencyStop() do
        LaunchType = 2
        launchOnce(autoPly())
        sleep(0.17)
        updateLoopData()
    end
end
menu.register_callback('autoLaunch', function()
    if loopData.auto_launch == true then
        loopData.auto_launch = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_launch = true
        saveLoopData()
        autoLaunchThread()
    end end)

local function flyThread()
    updateLoopData()
    local auto_yeet
    local random_direction = vector3(math.random(-2, 2), math.random(-2, 2), 0)
    for mocToYeet in replayinterface.get_vehicles() do
        if mocToYeet:get_model_hash() == joaat("TrailerLarge") and (distanceBetween(mocToYeet, ply) <= 150) then
            auto_yeet = mocToYeet
        end
    end
    sleep(0.1)
    while loopData.auto_fly and auto_yeet and loopData.currentPlayerId and not checkAndPerformEmergencyStop() do
        auto_yeet:set_position(autoPly():get_position() + random_direction + vector3(0, 0, 5))
        sleep(0.12)
        updateLoopData()
    end
end
menu.register_callback('startFlyThread', function()
    if loopData.auto_fly == true then
        loopData.auto_fly = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_fly = true
        saveLoopData()
        flyThread()
    end end)

local function cargoSpamThread()
    updateLoopData()
    local vehicles = { "Cargoplane", "Jet" } -- add your vehicle types here

    while loopData.currentPlayerId and loopData.auto_cargo_spam and not checkAndPerformEmergencyStop() do
        local vehicle = vehicles[math.random(#vehicles)] -- select random vehicle
        local random_distance = vector3((math.random(-900, 900) / 10), (math.random(-900, 900) / 10), (math.random(10, 1200) / 10))
        createVehicle(joaat(vehicle), autoPly():get_position() + random_distance, math.random(0, 360), true)

        for veh in replayinterface.get_vehicles() do
            if veh:get_model_hash() == joaat(vehicle) then
                veh:set_godmode(true)
            end
        end
        sleep(0.18)
        updateLoopData()
    end
end
menu.register_callback('autoCargoSpam', function()
    if loopData.auto_cargo_spam == true then
        loopData.auto_cargo_spam = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_cargo_spam = true
        saveLoopData()
        cargoSpamThread()
    end end)

local function autoRandomCarSpamThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_vehicle_spam and not checkAndPerformEmergencyStop() do
        local pos = autoPly():get_position() + autoPly():get_heading() * 2 + autoPly():get_velocity() * 2
        local random_distance = vector3(math.random(-2, 2), math.random(2, 2), math.random(2, 2))
        giveRandomVehicle(autoPly(), pos + random_distance, true, true)
        sleep(0.2)
        updateLoopData()
    end
end
menu.register_callback('autoVehicleSpam', function()
    if loopData.auto_vehicle_spam == true then
        loopData.auto_vehicle_spam = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_vehicle_spam = true
        saveLoopData()
        autoRandomCarSpamThread()
    end end)

local function autoCableCarSpamThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_cable_spam and not checkAndPerformEmergencyStop() do
        local rot = autoPly():get_rotation()
        local angle = math.deg(math.atan(rot.y, rot.x + math.pi / 2))
        createVehicle(joaat("CableCar"), autoPly():get_position(), angle, true)
        sleep(0.2)
        updateLoopData()
    end
end
menu.register_callback('autoCableCarSpam', function()
    if loopData.auto_cable_spam == true then
        loopData.auto_cable_spam = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_cable_spam = true
        saveLoopData()
        autoCableCarSpamThread()
    end end)

local function trainSpam()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_train_spam and not checkAndPerformEmergencyStop() do
        createVehicle(joaat("Freight"), autoPly():get_position() + vector3(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)), math.random(0, 360), true)
        sleep(0.1)
        updateLoopData()
    end
end
menu.register_callback('trainSpam', function()
    if loopData.auto_train_spam == true then
        loopData.auto_train_spam = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_train_spam = true
        saveLoopData()
        trainSpam()
    end end)

local function gpsTrackerThread()
    updateLoopData()
    while loopData.currentPlayerId and loopData.auto_gps and not checkAndPerformEmergencyStop() do
        local playerPos = autoPly():get_position()
        setWayPoint(playerPos.x, playerPos.y)
        sleep(0.6)
        updateLoopData()
    end
    --Remove waypoint in the end by placing it at our localplayer
    for _=1, 3 do
        setWayPoint(localplayer:get_position().x, localplayer:get_position().y)
    end
end
menu.register_callback('trackGPS', function()
    if loopData.auto_gps == true then
        loopData.auto_gps = false
        saveLoopData()
    else
        updateLoopData()
        loopData.auto_gps = true
        saveLoopData()
        gpsTrackerThread()
    end end)

function vehicleNoclipThread()
    updateLoopData()
    if not localplayer:is_in_vehicle() then loopData.trafficNoclipToggle = false end
    while loopData.trafficNoclipToggle do
        if not localplayer:is_in_vehicle() or localplayer:get_health() == 0 then
            loopData.trafficNoclipToggle = false
            saveLoopData()
            return
        end
        setPlayerRespawnState(getLocalplayerID(), 9)
        sleep(3.1) --The effect sticks around a bit so we don't need to spam it that hard
        updateLoopData()
    end
end
menu.register_callback('vehicleNoclip', function()
    if loopData.trafficNoclipToggle == true then
        loopData.trafficNoclipToggle = false
        saveLoopData()
    else
        updateLoopData()
        loopData.trafficNoclipToggle = true
        saveLoopData()
        vehicleNoclipThread()
    end end)

trafficRemoverRunning = false
local stopOnLeaving = false
function removeTrafficThread()
    updateLoopData()
    if localplayer:is_in_vehicle() then stopOnLeaving = true end
    while loopData.removeTrafficToggle do
        trafficRemoverRunning = true
        if stopOnLeaving and not localplayer:is_in_vehicle() then
            stopOnLeaving, loopData.removeTrafficToggle, trafficRemoverRunning = false, false, false
            return
        end
        local nonPlayerVehicles = getNonPlayerVehicles()
        for _, veh in pairs(nonPlayerVehicles) do
            if distanceBetween(localplayer, veh) < 90 then
                local pos = veh:get_position() + vector3(0, 0, 1620)
                for _ = 0, 2000 do
                    veh:set_position(pos)
                end
            end
        end
        sleep(0.04)
        updateLoopData()
    end
    trafficRemoverRunning = false
end
menu.register_callback('removeTraffic', function()
    if loopData.removeTrafficToggle == true then
        loopData.removeTrafficToggle = false
        saveLoopData()
    else
        updateLoopData()
        loopData.removeTrafficToggle = true
        saveLoopData()
        removeTrafficThread()
    end end)