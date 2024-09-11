--Kinda cursed, but I need to require these two from this file, so that the loop executor lua will have access to all necessary functions
require("scripts/quads_toolbox_scripts/toolbox_data/enums/VEHICLES")
require("scripts/quads_toolbox_scripts/toolbox_data/global_functions")
require("scripts/quads_toolbox_scripts/toolbox_data/util_functions")

function emergencyStopLoops()
    print("LOOP TOGGLES RESET")
    loopData.currentPlayerId = -1
    loopData.currentPlayerName = ""
    loopData.auto_teleport = false
    loopData.auto_storm = false
    loopData.auto_explode = false
    loopData.auto_bike = false
    loopData.auto_peds = false
    loopData.auto_launch = false
    loopData.auto_fly = false
    loopData.auto_rain = false
    loopData.auto_cargo_spam = false
    loopData.auto_vehicle_spam = false
    loopData.auto_cable_spam = false
    loopData.auto_train_spam = false
    loopData.auto_gps = false
    loopData.trafficNoclipToggle = false
    loopData.removeTrafficToggle = false
    loopData.removeNpcToggle = false
    loopData.auto_slap = false
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
end

loopData = {}
emergencyStopLoops() --also works as a reset

function updateLoopData()
    ignored, loopData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json")
end

function saveLoopData()
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
end

function setLoopPlayer(plyId, plyName)
    loopData.currentPlayerId = plyId
    loopData.currentPlayerName = plyName
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
end

function rocketSlap(ply)
    local currentVehicle
    local plyVehicle
    if localplayer:is_in_vehicle() then currentVehicle = localplayer:get_current_vehicle() end
    if ply:is_in_vehicle() then plyVehicle = ply:get_current_vehicle() end

    local angle = math.random() * (2 * math.pi) -- Random angle in radians
    local x = math.cos(angle) * 30
    local y = math.sin(angle) * 30
    local plyPos = ply:get_position()
    local newPos = vector3(plyPos.x + x, plyPos.y + y, plyPos.z + 6)

    local spawnDirection = vector3(plyPos.x - newPos.x, plyPos.y - newPos.y, 0)
    local spawnAngle = math.deg(math.atan(spawnDirection.y, spawnDirection.x)) - 90
    spawnAngle = (spawnAngle + 360) % 360

    createVehicle(joaat("voltic2"), newPos, spawnAngle, true, nil, nil, true)
    for veh in replayinterface.get_vehicles() do
        if (veh:get_model_hash() == joaat("voltic2")) and (not currentVehicle or currentVehicle ~= veh) and (not plyVehicle or plyVehicle ~= veh) and distanceBetween(veh, newPos, true) <= 7 then
            veh:set_boost(1000)
            veh:set_gravity(20)
            veh:set_brake_force(-1)
            veh:set_traction_curve_min(0)
            veh:set_traction_curve_max(0)

            for i=0, 200 do
                local turn_amount = getAngleToThing(ply, veh)
                local turn_amount_adjusted = (turn_amount / 360) * (2 * math.pi)
                local rot = veh:get_rotation()
                rot.x = rot.x + turn_amount_adjusted
                veh:set_rotation(rot)
                if i > 5 then
                    veh:set_boost_enabled(true)
                    veh:set_boost_active(true)
                end
                if distanceBetween(ply, veh) < 5 then return end
                sleep(0.01)
            end
            veh:set_gravity(19.4)
            veh:set_brake_force(2)
            return
        end
    end
end


function giveRandomVehicle(ply, pos, skip_remove, firstSpawner)
    if not ply or ply == nil then return end

    if not pos then
        pos = ply:get_position() + ply:get_heading() * 7
    end

    --             [1]    [2][1]  [2][2]
    -- vehicle = { hash, { name, class} }
    local selection = math.random(#sorted_vehicles)
    createVehicle(sorted_vehicles[selection][1], pos, nil, skip_remove, generateRandomMods(VEHICLE[sorted_vehicles[selection][1]][3]), not firstSpawner, true, false)
    return sorted_vehicles[selection][1]
end

function randomVehicleRain(ply)
    if not ply or ply == nil then
        return
    end

    local currentVehicle = localplayer:is_in_vehicle() and localplayer:get_current_vehicle() or nil
    local rainTries = 0
    local plyVelocity = ply:get_velocity() * 1.28
    local plyHeading = ply:get_heading() * 0.5
    local plyPosition = ply:get_position()
    local random_dist = vector3(math.random(-4, 4), math.random(-4, 4), math.random(-2, 2))
    local rainDropPosition = plyPosition + plyHeading + plyVelocity + vector3(0, 0, 37) + random_dist

    local spawned_vehicle_hash = giveRandomVehicle(ply, rainDropPosition, true, true)
    local found = false
    while not found and rainTries < 9 do
        for veh in replayinterface.get_vehicles() do
            local veh_gravity = veh:get_gravity()
            if veh:get_model_hash() == spawned_vehicle_hash and (not currentVehicle or currentVehicle ~= veh) and veh_gravity ~= 9.42 and veh_gravity ~= 169 then
                found = true
                while (veh:get_gravity() ~= 169) do
                    veh:set_gravity(169)
                    sleep(0.07)
                end
                sleep(0.8)
                veh:set_gravity(9.42)
                return
            end
        end
        rainTries = rainTries + 1
        sleep(0.07)
    end
end

--teleport yourself to player
teleportHeight = 0
function tpToPlayer(ply, height, auto_localplayer)
    if not ply or ply == nil then return end

    local current_me
    if auto_localplayer then
        current_me = auto_localplayer
    else
        current_me = localplayer
    end
    local heading = ply:get_heading()
    heading.z = 0
    local pos = ply:get_position() + (heading * -(height / 2.6))
    pos.z = pos.z + height
    teleportHeight = height

    nativeTeleport(pos)
end

vehicleDistance = 3
function teleportVehiclesToPlayer(ply, distance, explode, vector_switch)
    if not ply then return end

    local nonPlayerVehicles = getNonPlayerVehicles()

    local pos = vector_switch and ply or ply:get_position()

    for _, veh in pairs(nonPlayerVehicles) do
        local random_distance = vector3(math.random(-distance, distance), math.random(-distance, distance), math.random(-distance, distance))
        veh:set_godmode(true)
        veh:set_acceleration(0)
        local tpPos = pos + random_distance
        for _ = 0, 69 do
            veh:set_position(tpPos)
            veh:set_rotation(vector3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
        end
        if explode and distanceBetween(veh, tpPos, vector_switch) < 5 then
            veh:set_godmode(false)
            veh:set_health(-1)
        end
    end
end

local BikeTypes = { "Bmx", "Inductor", "Inductor2", "Cruiser", "Fixter", "Scorcher", "TriBike", "TriBike2", "TriBike3" }
function giveRandomBike(ply)
    if not ply or ply == nil then
        return
    end
    createVehicle(joaat(BikeTypes[math.random(#BikeTypes)]), ply:get_position() + ply:get_heading() * 7, nil, true)
end

--teleports all peds to player
teleportType = { [0] = "right on Player", "in Front of Player" }
teleportTypeSelection = 0
function tpPedToPlayer(ply, tpType)
    for ped in replayinterface.get_peds() do
        if ped and ped ~= nil and ped:get_pedtype() >= 4 and not ped:is_in_vehicle() then
            ped:set_freeze_momentum(true)
            local pos
            if tpType == "in Front of Player" then
                pos = ply and ply:get_position() + ply:get_heading() * (math.random(40, 70) / 10) or nil
            else
                pos = ply and ply:get_position() + vector3((math.random(-10, 10) / 10), (math.random(-10, 10) / 10), (math.random(-10, 10) / 10)) or nil
            end
            if not pos then return end
            for _ = 0, 100 do
                ped:set_position(pos)
            end
            ped:set_freeze_momentum(false)
        end
    end
end

LaunchTypes = { "Dump", "ArmyTrailer", "dune5" }
LaunchType = 1
function launchOnce(launchPly)
    if not launchPly or launchPly == nil then return end

    local model = LaunchTypes[LaunchType]

    local currentVehicle

    if localplayer:is_in_vehicle() then
        currentVehicle = localplayer:get_current_vehicle()
    end

    if model == "ArmyTrailer" or model == "Dump" then
        local vel = launchPly:get_velocity()
        vel.z = 0;
        local angle = math.deg(math.atan(launchPly:get_heading().y, launchPly:get_heading().x)) + 90
        createVehicle(joaat(model), (launchPly:get_position() + (vel * 0.48) + vector3(0, 0, -12)), angle, true)

        local found = false
        local tries = 0
        while (not found and tries < 20) do
            for veh in replayinterface.get_vehicles() do
                if veh:get_model_hash() == joaat(model) and (not currentVehicle or (currentVehicle ~= veh)) and not ((veh:get_gravity() == 9.42) or (veh:get_gravity() == -340)) then
                    found = true
                    veh:set_rotation(launchPly:get_rotation())
                    while (veh:get_gravity() ~= -340) do
                        veh:set_rotation(launchPly:get_rotation())
                        veh:set_gravity(-340)
                    end
                    sleep(0.5)
                    veh:set_gravity(9.42)
                    return
                end
            end
            if not found then
                tries = tries + 1
                sleep(0.08)
            end
        end
    elseif model == "dune5" then
        createVehicle(joaat(model), (launchPly:get_position() + vector3(0, 0.2, -0.2)))
        local found = false
        local tries = 0
        while (not found and tries < 20) do
            for veh in replayinterface.get_vehicles() do
                if veh:get_model_hash() == joaat(model) and (not currentVehicle or (currentVehicle ~= veh)) and not ((veh:get_gravity() == 9.42) or (veh:get_gravity() == -5) or (veh:get_gravity() == -10) or (veh:get_gravity() == -69) or (veh:get_gravity() == -300)) then
                    found = true
                    veh:set_rotation(launchPly:get_rotation())
                    while veh:get_gravity() ~= -300 do
                        veh:set_gravity(-5)
                        sleep(0.4)
                        veh:set_gravity(-10)
                        sleep(0.4)
                        veh:set_gravity(-69)
                        sleep(0.4)
                        veh:set_gravity(-300)
                    end
                    sleep(2.5)
                    veh:set_gravity(9.42)
                    return
                end
            end
            tries = tries + 1
            sleep(0.08)
        end
    end
end