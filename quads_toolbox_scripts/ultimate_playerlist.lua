local savedInteriors = {}
local interiorsLoadingSuccess, jsonInteriors = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/SAVED_INTERIORS.json")
if interiorsLoadingSuccess then
    --Load the saved interiors from file
    for _, data in pairs(jsonInteriors) do
        savedInteriors[_] = vector3(data[1], data[2], data[3])
    end
end

local sortStyles = { [0]="Modders first", "Nearest first" }
formatStyles = { [0]="EU", "US"}

settingsLoadingSuccess, playerlistSettings = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json")
if not settingsLoadingSuccess then
    playerlistSettings.disableSpectatorWarning = false
    playerlistSettings.disableModdersWarning = false
    playerlistSettings.defaultSortingMethod = 0
    playerlistSettings.stringFormat = 0
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
end

--Define booleans used for interacting with the separate loop action threads
local auto_teleport = false
local auto_storm = false
local auto_explode = false
local auto_bike = false
local auto_peds = false
local auto_launch = false
local auto_fly = false
local auto_rain = false
local auto_cargo_spam = false
local auto_vehicle_spam = false
local auto_yeet = false
local auto_cable_spam = false
local auto_train_spam = false
local auto_action_player_id
local auto_action_player_name

local function emergencyStop()
    auto_teleport = false
    auto_explode = false
    auto_storm = false
    auto_bike = false
    auto_peds = false
    auto_cargo_spam = false
    auto_launch = false
    auto_fly = false
    auto_rain = false
    auto_vehicle_spam = false
    auto_yeet = false
    auto_cable_spam = false
    auto_train_spam = false
end

local bounty_numbers = { [0] = 1, 42, 69, 420, 4200, 6969, 9999 }
local current_bounty_number = 0

--------- Function Definitions -----------
local serializeInteriors = {}
local function saveNewInterior(pos)
    savedInteriors[#(savedInteriors) + 1] = pos
    for _, interior in pairs(savedInteriors) do
        serializeInteriors[_] = { interior.x, interior.y, interior.z }
    end
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/SAVED_INTERIORS.json", serializeInteriors)
end

--Used for loop-actions running on a player
--has a small oldPlayer backup to avoid some nil errors on player disconnect
local oldPlayer
local autoPly = function()
    local activePlayer = player.get_player_ped(auto_action_player_id)
    if activePlayer and player.get_player_name(auto_action_player_id) == auto_action_player_name then
        oldPlayer = activePlayer
    elseif oldPlayer ~= nil then
        activePlayer = oldPlayer
        oldPlayer = nil
    end
    return activePlayer
end

local currentSpeed = 0.0
local function updateSpeed(ply)
    if not ply or ply == nil then
        return
    end
    local vel = ply:get_velocity()
    local x, y, z = math.abs(vel.x), math.abs(vel.y), math.abs(vel.z)

    if formatStyles[playerlistSettings.stringFormat] == "US" then
        currentSpeed = math.floor((math.sqrt(x * x + y * y + z * z) * 2.26) * 10) / 10
    else
        currentSpeed = math.floor((math.sqrt(x * x + y * y + z * z) * 3.6371084) * 10) / 10
    end
    return string.format("% 7.1f", currentSpeed)
end

--teleport yourself to player
local current_me
local teleportHeight = 0
local function tpToPlayer(ply, height, auto_localplayer)
    if not ply or ply == nil then
        return
    end

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

    if not current_me:is_in_vehicle() then
        current_me:set_position(pos)
    else
        current_me:get_current_vehicle():set_position(pos)
    end
end

--teleports all peds to player
local teleportType = { [0] = "right on Player", "in Front of Player" }
local teleportTypeSelection = 0
local function tpPedToPlayer(ply, tpType)
    for ped in replayinterface.get_peds() do
        if ped and ped ~= nil and ped:get_pedtype() >= 4 and not ped:is_in_vehicle() and ped ~= localplayer then
            ped:set_freeze_momentum(true)
            local pos
            if tpType == "in Front of Player" then
                pos = ply:get_position() + ply:get_heading() * (math.random(40, 70) / 10)
            else
                pos = ply:get_position() + vector3((math.random(-10, 10) / 10), (math.random(-10, 10) / 10), (math.random(-10, 10) / 10))
            end
            for _ = 0, 100 do
                ped:set_position(pos)
            end
            ped:set_freeze_momentum(false)
        end
    end
end

--spawns a Dump carefully above and in front of a player taking into account their current heading/speed
--such that it will land on them even if they're moving (as long as it's in a straight line)
local slamPly
local function preciseSlam()
    if not slamPly then
        return
    end

    local currentVehicle = localplayer:is_in_vehicle() and localplayer:get_current_vehicle()

    local vel = slamPly:get_velocity()
    if vel.z < 0 then
        vel.z = 0
    end
    createVehicle(joaat("Dump"), (slamPly:get_position() + (vel * 1.28) + vector3(0, 0, 38)))
    local found = false
    local tries = 0
    while (not found and tries < 20) do
        for veh in replayinterface.get_vehicles() do
            if (veh:get_model_hash() == joaat("Dump")) and (not currentVehicle or (currentVehicle ~= veh)) and not ((veh:get_gravity() == 9.42) or (veh:get_gravity() == 110)) then
                found = true
                veh:set_godmode(true)
                veh:set_rotation(slamPly:get_rotation())
                while (veh:get_gravity() ~= 110) do
                    veh:set_gravity(110)
                    sleep(0.1)
                end
                sleep(2)
                veh:set_gravity(9.42)
                veh:set_godmode(false)
                sleep(0.05)
                veh:set_godmode(false)
            end
        end
        tries = tries + 1
        sleep(0.1)
    end
end

menu.register_callback('preciseSlam', preciseSlam)

--Slam player with a choice of different vehicles, or with traffic
--yes, FireTruk is written correctly. That's how it's referenced in-game
local dropVehicles = { [0] = "Panto", "Rhino", "Youga4", "Tourbus", "Benson", "Bulldozer", "Ambulance", "Riot", "TipTruck", "Stockade", "FireTruk", "Brickade", "Barracks", "Biff", "Mixer2", "Flatbed", "Bus", "PropTrailer", "TankerCar", "PBus", "Freight", "TrailerLarge", "Tug", "Cargoplane", "Kosatka" }
local selectedDropType = 0
local function dropVehicleOnPlayer(ply, model)
    createVehicle(joaat(model), ply:get_position() + (ply:get_velocity() * 2.22) + vector3(0, 0, 20))
end

local vehicleDistance = 3
local function TeleportVehiclesToPlayer(ply, distance, explode, veh_switch)
    if not ply then
        return
    end

    local nonPlayerVehicles = getNonPlayerVehicles()

    ply = veh_switch or ply
    vehicleDistance = distance

    local pos = ply:get_position()

    for _, veh in pairs(nonPlayerVehicles) do
        local random_distance = vector3(math.random(-distance, distance), math.random(-distance, distance), math.random(-distance, distance))
        veh:set_godmode(true)
        veh:set_acceleration(0)
        local tpPos = pos + ply:get_heading() + random_distance
        for _ = 0, 100 do
            veh:set_position(tpPos)
        end
        if explode and distanceBetween(ply, veh) < 50 then
            veh:set_rotation(vector3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            veh:set_godmode(false)
            veh:set_health(-1)
        end
    end
end

local function manipulatePlayerWithTraffic(ply, action)
    local nonPlayerVehicles = getNonPlayerVehicles()
    local pos = ply:get_position() + (ply:get_velocity() * 0.44)

    local rotation, gravity, zPos, godmode

    if action == "slam" then
        rotation, gravity, zPos, godmode = vector3(0, 0, 0), 1000, pos.z + 30, false
    elseif action == "launch" then
        rotation, gravity, zPos, godmode = vector3(0, 0, math.pi), -80, pos.z - 30, true
    end

    for _, veh in pairs(nonPlayerVehicles) do
        local vehPos = vector3((pos.x + (math.random(-1, 1))), (pos.y + (math.random(-1, 1))), zPos)
        for _ = 0, 500 do
            veh:set_position(vehPos)
        end
        veh:set_rotation(rotation)
        veh:set_gravity(gravity)
        veh:set_godmode(godmode)
    end

    sleep(2)
    for _, veh in pairs(nonPlayerVehicles) do
        veh:set_godmode(false)
        veh:set_gravity(9.8)
    end
end

local LaunchTypes = { "Dump", "ArmyTrailer", "dune5" }
local LaunchType = 1
local launchPly
local function launchOnce()
    if not launchPly or launchPly == nil then
        return
    end

    local model = LaunchTypes[LaunchType]

    local currentVehicle

    if localplayer:is_in_vehicle() then
        currentVehicle = localplayer:get_current_vehicle()
    end

    if model == "ArmyTrailer" or model == "Dump" then
        local vel = launchPly:get_velocity()
        vel.z = 0;
        local plyHeading = launchPly:get_heading()
        local angle = math.deg(math.atan(plyHeading.y, plyHeading.x)) + 90
        angle = (angle + 360) % 360
        createVehicle(joaat(model), (launchPly:get_position() + (vel * 0.48) + vector3(0, 0, -12)))

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

menu.register_callback('launchOnce', launchOnce)

local CageTypes = { "CableCar", "Spawned MOC", "TP invis MOC", "Remove Cages" }
local CageType = 1
local prepared = true
local function cagePlayer(ply, type)
    if not ply or ply == nil then
        return
    end

    local currentVehicle

    if localplayer:is_in_vehicle() then
        currentVehicle = localplayer:get_current_vehicle()
    end

    if type == "Spawned MOC" then
        local plyHeading = ply:get_heading()
        local angle = math.deg(math.atan(plyHeading.y, plyHeading.x)) + 90
        angle = (angle + 360) % 360
        if not ply:is_in_vehicle() then
            --create a dunebuggy under the player to elevate them, so he will be inside the MOC Trailer rather than stuck under it
            createVehicle(joaat("dune5"), ply:get_position(), angle)
            sleep(0.520)
        end
        createVehicle(joaat("TrailerLarge"), (ply:get_position() + plyHeading + vector3(0, 0, -1)), angle)
    elseif type == "TP invis MOC" then
        --try to teleport the unloaded MOC to cage the player
        --this thing is so f*cking buggy it just doesn't seem to have collision unless it's exploded with other vehicles once
        for moc in replayinterface.get_vehicles() do
            --we use tostring here to avoid floating point comparison bs while making sure we tp the right MOC
            if moc:get_model_hash() == joaat("TrailerLarge") and ((tostring(moc:get_position().z) == "-149.6112") or (moc:get_gravity() == 14.20)) then
                moc:set_godmode(false)
                moc:set_gravity(14.20)
                moc:set_health(1000)

                if not prepared then
                    moc:set_position(ply:get_position() + vector3(0, 0, -69))
                    sleep(0.2)
                    moc:set_health(-100)
                    TeleportVehiclesToPlayer(ply, 0, true, moc)
                end

                moc:set_rotation(ply:get_rotation())
                moc:set_position(ply:get_position() + ply:get_heading() * 2.25 + vector3(0, 0, -0.88))
                moc:set_rotation(ply:get_rotation())

            end
        end
    elseif type == "Remove Cages" then
        for moc in replayinterface.get_vehicles() do
            if moc:get_model_hash() == joaat("TrailerLarge") and (tostring(moc:get_position().z) == "-149.6112" or (moc:get_gravity() == 14.20)) then
                moc:set_position(vector3(2000, 2000, 2000))
                break
            end
        end
        for cableCar in replayinterface.get_vehicles() do
            if cableCar:get_model_hash() == joaat("CableCar") then
                local removePos = vector3(2000 + math.random(-100, 100), 2000 + math.random(-100, 100), -200)
                for _ = 0, 100 do
                    cableCar:set_position(removePos)
                end
            end
        end
    elseif type == "CableCar" then
        local rot = ply:get_rotation()
        local angle = math.deg(math.atan(rot.y, rot.x + (math.pi / 4)))
        createVehicle(joaat("CableCar"), ply:get_position(), angle)
    end
end

local random_direction
function prepareFlying(ply)
    random_direction = vector3(math.random(-2, 2), math.random(-2, 2), 0)
    for yeet in replayinterface.get_vehicles() do
        if yeet:get_model_hash() == joaat("TrailerLarge") and (distanceBetween(yeet, ply) <= 150) then
            auto_yeet = yeet
        end
    end
end

--spawn a ramp buggy in front of the player, turned such that he will ramp over it if he's driving
local rampPly
local function giveRamp()
    if not rampPly or rampPly == nil then
        return
    end

    local currentVehicle
    local plyVehicle
    local tries = 0
    local distanceMul

    if localplayer:is_in_vehicle() then
        currentVehicle = localplayer:get_current_vehicle()
    end

    if rampPly:is_in_vehicle() then
        plyVehicle = rampPly:get_current_vehicle()
    end

    local plyVelocity = rampPly:get_velocity()
    local plyHeading = rampPly:get_heading()
    local angle = math.deg(math.atan(plyHeading.y, plyHeading.x)) + 90
    angle = (angle + 360) % 360

    if localplayer:is_in_vehicle() or alternative_spawn_toggle then
        distanceMul = 1
    else
        distanceMul = 0.45
    end
    createVehicle(joaat("dune5"), rampPly:get_position() + (plyVelocity * distanceMul) + vector3(0, 0, 0.89), angle)
    local found = false
    while (not found and tries < 20) do
        for veh in replayinterface.get_vehicles() do
            if (veh:get_model_hash() == joaat("dune5")) and (veh:get_gravity() ~= 10) and (not currentVehicle or currentVehicle ~= veh) and (not plyVehicle or plyVehicle ~= veh) and distanceBetween(veh, rampPly) <= 180 then
                found = true
                veh:set_gravity(10)
                --createVehicle will use the alternative spawning method if we're in a vehicle,
                --which doesn't support setting the heading, so we only need to do the following in that case
                if localplayer:is_in_vehicle() then
                    local rot = rampPly:get_rotation()
                    --to rotate the buggy by 180°, we add 1 PI to its x rotation as it's in radians
                    --and in order to tilt it properly if the player is e.g. driving upwards, we take the inverse of the player's z rotation
                    rot = vector3(rot.x + math.pi, rot.y, rot.z * -1)
                    for _ = 0, 200000 do
                        veh:set_rotation(rot)
                    end
                end
                sleep(1.2)
                veh:set_health(-1)
                local removePos = rampPly:get_position() + vector3(0, 0, -300)
                for _ = 0, 100 do
                    veh:set_position(removePos)
                end
                return
            end
        end
        tries = tries + 1
        sleep(0.1)
    end
end

menu.register_callback('giveRamp', giveRamp)

local BikeTypes = { "Bmx", "Inductor", "Inductor2", "Cruiser", "Fixter", "Scorcher", "TriBike", "TriBike2", "TriBike3" }
local function giveRandomBike(ply)
    if not ply or ply == nil then
        return
    end
    createVehicle(joaat(BikeTypes[math.random(#BikeTypes)]), ply:get_position() + ply:get_heading() * 7)
end

local function giveRandomVehicle(ply, pos)
    if not ply or ply == nil then
        return
    end

    if not pos then
        pos = ply:get_position() + ply:get_heading() * 7
    end

    local vector = ply:get_heading()
    local angle = math.deg(math.atan(vector.y, vector.x))

    --             [1]    [2][1]  [2][2]
    -- vehicle = { hash, { name, class} }
    local selection = math.random(#sorted_vehicles)
    print("Giving vehicle: " .. sorted_vehicles[selection][2][1])
    createVehicle(sorted_vehicles[selection][1], pos, angle)
    return sorted_vehicles[selection][1]
end

local function randomVehicleRain(ply)
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

    local spawned_vehicle_hash = giveRandomVehicle(ply, rainDropPosition)
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

local function getPlayerStateText(ply, plyId)
    if not ply or not plyId then
        return ""
    end

    if ply:get_max_health() <= 0 then
        return "MOD "
    end

    local healthPercent = (ply:get_health() / ply:get_max_health()) * 100
    local respawnState = getPlayerRespawnState(plyId)
    local playerBlipType = getPlayerBlipType(plyId)

    if healthPercent == 0 or respawnState == -1 then
        return "DED"
    end

    if (respawnState ~= 99 and respawnState ~= 0) or shortformBlips[playerBlipType] then
        return shortformBlips[playerBlipType]
    end

    if hasDevDLC(plyId) ~= 0 then
        return "!DEV!"
    end

    if healthPercent < 0 then
        return "MOD "
    end

    return math.floor(healthPercent + 0.5) .. "\u{2665}"
end

local function isInInterior(ply, plyId)
    local playerBlip = getPlayerBlipType(plyId)

    if interiorBlips[playerBlip] then
        return true
    end

    local getPlayerRespawnState = getPlayerRespawnState(plyId)
    if getPlayerRespawnState ~= 99 and getPlayerRespawnState ~= 0 then
        return true
    end

    --unloaded players are stored at the -51.3 z coordinate, so we exclude them from the interior check
    --also exclude config flag 65, which is 'is_swimming', as you can't swim inside and swimming as such usually means they're in the ocean or in a deep pool
    local plyPos = ply:get_position()
    if ply:is_in_cutscene()
            or (plyPos.z < -30 and tostring(plyPos.z) ~= "-51.3")
            or (plyPos.z < -30 and tostring(plyPos.z) ~= "-51.3")
            and not ply:get_config_flag(65) then
        return true
    end

    for _, interior in pairs(savedInteriors) do
        if distanceBetween(ply, interior, true) < 15 then
            return true
        end
    end

    return false
end

local function getPlayerStateSymbol(ply, plyId)
    if not ply or not plyId then
        return ""
    end

    local blipType = getPlayerBlipType(plyId)

    if blipType == "BEAST" then
        return "\u{1F479}"
    elseif blipType == "LOADING" then
        return "🔄"
    elseif string.find(blipType, "Blip:") or string.find(blipType, "UNSURE:") then
        return "? "
    end

    if isInInterior(ply, plyId) then
        return "\u{1F3E0}"
    end

    if ply:get_godmode() then
        return "G\u{3000}"
    elseif ply:is_in_vehicle() and ply:get_current_vehicle():get_godmode() then
        return "VG"
    end

    return "\u{3000} "
end

local marked_modders = {}
--Exclude Cars with RC capabilities in order not to falsely detect them as modders
local excluded_vehicle_hashes = {
    joaat("Minitank"),
    joaat("RCBandito"),
    joaat("Buffalo4"),
    joaat("Jubilee"),
    joaat("Champion")
}

local function isExcludedVehicle(vehicle_model)
    for _, v in pairs(excluded_vehicle_hashes) do
        if v == vehicle_model then
            return true
        end
    end
    return false
end

local function modCheck(ply, plyName, plyId)
    if not ply then return false end
    if (plyName and marked_modders[plyName] == "detected") or hasDevDLC(plyId) ~= 0 or ply:get_max_health() < 100 then
        return true
    end
    if getPlayerRespawnState(plyId) ~= 99 or ply:is_in_cutscene() then
        return false
    end
    local interior_bool = isInInterior(ply, plyId)
    local vehicle = ply:is_in_vehicle() and ply:get_current_vehicle()
    local vehicle_model = vehicle and vehicle:get_model_hash()
    if ply ~= localplayer then
        if ply:get_godmode() and not interior_bool and ply:get_health() ~= 0 and not (vehicle and isExcludedVehicle(vehicle_model)) then
            return true
        end
    end
    if ply:is_in_vehicle() and (ply:get_current_vehicle():get_godmode() or ply:get_seatbelt()) and not interior_bool then
        return true
    end
    return false
end

local function toggleMarkedModder(plyName)
    if marked_modders[plyName] then
        marked_modders[plyName] = nil
    else
        marked_modders[plyName] = "detected"
    end
end

--marked_modders[plyName] = ((marked_modders[plyName] == "detected") and nil) or "detected"

local function getModderSymbol(ply, plyName, plyId)
    if not modCheck(ply, plyName, plyId) then
        return " "
    end

    return marked_modders[plyName] == "detected" and "🄼" or "m"
end

--Get Name Of Players Weapon
local function getWpn(ply)
    if not ply then
        return
    end

    if ply:get_current_weapon() == nil or ply:get_current_weapon():get_name_hash() == nil then
        return "Unarmed"
    end

    local weaponHash = ply:get_current_weapon():get_name_hash()
    return WEAPON[weaponHash] or "hash: " .. weaponHash
end

local function modelIcon(ply, plyId)
    if ply == nil then
        return
    end
    local blipType = getPlayerBlipType(plyId)

    if ply:is_in_vehicle() then
        local hash = ply:get_current_vehicle():get_model_hash()
        if hash then
            if VEHICLE[hash] then
                local class = VEHICLE[hash][2]
                return vehicleClassIcons[class] or "\u{1F697}"
            end
        end
        return "err"
    elseif (blipType == "VEHICLE") then
        return "\u{1F697}"
    elseif (blipType == "PLANE GHOST") or (blipType == "ULTRALIGHT GHOST") then
        return "\u{2708}"
    else
        --On foot, default
        return "\u{3000}" .. " "
    end
end

local function addPlayerOption(playerData, optionSub, distancePly)
    local subMenus = {}
    local playerId = playerData[1]
    local playerName = playerData[2]
    local playerDistance = localplayer
    local largeDistanceDisplay = true
    local distanceUnit
    if formatStyles[playerlistSettings.stringFormat] == "EU" then
        distanceUnit = "㎞"
    else
        distanceUnit = "㏕"
    end
    local distanceStr
    local distanceFormat = "%1.1f"
    local player = player.get_player_ped(playerId)

    -- If distancePly is provided, use it instead of localplayer and adjust display settings
    if distancePly then
        playerDistance = distancePly
        largeDistanceDisplay = false
        if formatStyles[playerlistSettings.stringFormat] == "EU" then
            distanceUnit = "m"
        else
            distanceUnit = "ft"
        end
        distanceFormat = "%4d"
    end

    -- If player exists, add it to the submenu
    if player then
        local displayName = playerName
        local nameAddons = ""
        if hasBounty(playerId) then
            nameAddons = "\u{1F480}" .. nameAddons
        end
        if player == localplayer then
            displayName = "--You--"
        elseif amISpectating(playerId) then
            nameAddons = "\u{24E2}" .. nameAddons
        elseif isSpectatingMe(playerId) then
            nameAddons = "\u{1F142}" .. nameAddons
        end
        if getScriptHostPlayerID() == playerId then
            nameAddons = "\u{1F137}" .. nameAddons
        end
        if nameAddons ~= "" then
            displayName = nameAddons .. " " .. displayName
        end

        local playerStateText = getPlayerStateText(player, playerId)
        local modderSymbol = getModderSymbol(player, playerName, playerId)
        local playerStateSymbol = getPlayerStateSymbol(player, playerId)
        local modelIconStr = modelIcon(player, playerId)
        local distance = distanceBetween(playerDistance, player, false, largeDistanceDisplay)
        if formatStyles[playerlistSettings.stringFormat] == "US" then
            if distanceUnit == "㏕" then
                --km to miles
                distance = distance * 0.621371
            else
                --meter to feet
                distance = distance * 3.28084
            end
        end
        if largeDistanceDisplay and distance >= 9.95 then
            distanceStr = '10+' .. distanceUnit
        else
            distanceStr = string.format(distanceFormat, distance) .. distanceUnit
        end
        local menuLabel = table.concat({ displayName, tostring(playerStateText), modderSymbol, playerStateSymbol, modelIconStr, distanceStr }, "|")

        subMenus[playerId] = optionSub:add_submenu(menuLabel, function()
            addSubActions(subMenus[playerId], playerName, playerId)
        end)
    end
end

local function getPlayersByDistance(origPly)
    local ply_array = {}
    for i = 0, 31 do
        local ply = player.get_player_ped(i)
        if ply then
            table.insert(ply_array, { i, player.get_player_name(i), distanceBetween(origPly, ply) })
        end
    end
    table.sort(ply_array, function(a, b)
        return a[3] < b[3]
    end)
    return ply_array
end

function nearbyPlayersMenu(ply, nearbySub, plyId)
    nearbySub:clear()
    nearbySub:add_bare_item("............Updating..........", function()
        return "===========Update==========="
    end, function()
        nearbyPlayersMenu(ply, nearbySub, plyId)
    end, null, null)
    --Sort players by distance to player
    local nearby_players = getPlayersByDistance(ply)
    --Add players to playerList sorted by distance
    local count = 0
    for _, v in pairs(nearby_players) do
        if v[2] ~= player.get_player_name(plyId) then
            addPlayerOption(v, nearbySub, ply)
            count = count + 1
            if count == 8 then
                return
            end
        end
    end
end

local function ridList(sub)
    sub:clear()
    if baseGlobals.ridLookup.freemode_base_local == -1 then
        addText(sub, "ERROR Couldn't find RIDs in memory")
        addText(sub, "This can happen sometimes, because")
        addText(sub, "their location changes with every")
        addText(sub, "restart of the game.")
        addText(sub, "Make sure you are fully loaded or")
        addText(sub, "Check after a restart if RIDs are found")
        sub:add_action("⚠️ BRUTE FORCE SEARCH (LONG) ⚠️", function()
            greyText(sub, " 0% searched...")
            local min_value = math.min(table.unpack(possible_offsets))
            local max_value = math.max(table.unpack(possible_offsets))
            local playerName = player.get_player_name(getLocalplayerID())
            local current_count = math.ceil((max_value - min_value) / 2)
            local counter = 0
            local counter2 = 1
            local step = current_count / 10
            local freemode_script = script("freemode")
            if not freemode_script then return end
            --Only check every second value because the offset is always uneven
            for i = min_value, max_value, 2 do
                counter = counter + 1
                if counter == math.floor(step) then
                    greyText(sub, counter2 * 10 .. "% searched... (" .. formatNumberWithDots(counter2 * math.ceil(step)) .. " Variables)")
                    counter = 0
                    counter2 = counter2 + 1
                end
                local shortenedPlyName = freemode_script:get_string(i + (0 * 526) + 3, 30)
                if shortenedPlyName == string.sub(playerName, 5) then
                    addText(sub, "FOUND! Correct Offset: " .. i)
                    baseGlobals.ridLookup.freemode_base_local = i
                    table.insert(possible_offsets, i)
                    table.sort(possible_offsets)
                    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/RID_DATA_OFFSETS.json", possible_offsets)
                    triggerRidLookupTableRefresh(player.get_player_name(getLocalplayerID()) or nil)
                    return
                end
            end
            addText(sub, "NOT FOUND! Restart the game and try again")
        end)
    else
        greyText(sub, "Names have their first 4 letters cut")
        greyText(sub, "off, ask R* Devs why")
        for name, rid in pairs(ridLookupTable) do
            sub:add_bare_item("", function() return "Name: " .. name .. "| Rid: " .. rid end, null, null, null)
        end
    end
end

--Generates specific info about the player
local function playerInfo(plyId, sub, plyName)
    local ply = player.get_player_ped(plyId)
    if not ply then
        return
    end
    greyText(sub, "======== ⇩ 🛈 PLAYER INFO 🛈 ⇩ ========")

    --Display player state
    local function playerState()
        local txt = ""
        local blipType = getPlayerBlipType(plyId)

        if ply ~= localplayer and amISpectating(plyId) then
            txt = txt .. "SPEC "
        end
        if ply ~= localplayer and isSpectatingMe(plyId) then
            txt = txt .. "!WATCHING YOU! "
        end
        if getScriptHostPlayerID() == plyId then
            txt = txt .. "HOST "
        end
        if ply:get_godmode() then
            if isInInterior(ply, plyId) and blipType ~= "INTERIOR" then
                txt = txt .. "INTERIOR "
            else
                txt = txt .. "GOD "
            end
        end
        if hasDevDLC(plyId) ~= 0 then
            txt = txt .. "!DEV! "
        end
        if modCheck(ply, plyName, plyId) then
            txt = txt .. "HAX "
        end
        if ply:is_in_cutscene() then
            txt = txt .. "CUTSCENE "
        end

        --Add the blip type to the info
        return centeredText(txt .. blipType)
    end
    sub:add_bare_item("", playerState, null, null, null)

    --health/armor/wanted level
    local function health_and_armor()
        local healthPercent = (ply:get_health() / ply:get_max_health()) * 100
        local respawnState = getPlayerRespawnState(plyId)

        if healthPercent == 0 or respawnState == -1 then
            healthPercent = "DED"
        elseif healthPercent >= 0 then
            healthPercent = math.floor(healthPercent + 0.5) .. "\u{2665}"
        else
            healthPercent = "MOD GHOST"
        end

        local armor = (math.floor(ply:get_armour()) * 2) .. "%"
        local wanted = ply:get_wanted_level() > 0 and string.rep(" \u{2605}", ply:get_wanted_level(), "") or "0\u{2605}  "
        local vehicle_health = ply:is_in_vehicle() and math.floor(ply:get_current_vehicle():get_health()) or 0

        return " " .. healthPercent .. "    " .. armor .. "\u{1F6E1}    " .. wanted .. "|" .. "\u{1F697}" .. vehicle_health .. "\u{2665}"
    end

    greyText(sub, centeredText("------ Health/Armor/Wanted Level ------"))
    sub:add_bare_item("", health_and_armor, null, null, null)

    --Weapon/Vehicle
    local function wpn_veh()
        local wpn_text = getWpn(ply)
        local vehicle_name, vehicle_class = "On Foot", ""

        if ply:is_in_vehicle() then
            local veh = ply:get_current_vehicle()
            local details = VEHICLE[veh:get_model_hash()]
            if details then
                vehicle_name, vehicle_class = details[1], details[2]
            else
                vehicle_name = "Not Found, Hash:" .. veh:get_model_hash()
            end
        else
            local blipType = getPlayerBlipType(plyId)
            if blipType == "VEHICLE" or blipType == "PLANE GHOST" or blipType == "ULTRALIGHT GHOST" then
                return centeredText(wpn_text .. " - " .. "Vehicle")
            end
        end
        return wpn_text .. "|" .. vehicle_name .. " - " .. vehicle_class
    end

    greyText(sub, centeredText("------ 🔫 Weapon / Vehicle 🚗------"))
    sub:add_bare_item("", wpn_veh, null, null, null)

    --Player Stats
    greyText(sub, centeredText("------ Player Stats ------"))
    sub:add_bare_item("", function()
        local playerWallet = getPlayerWallet(plyId)
        local bankAmount = math.max(0, getPlayerMoney(plyId) - playerWallet)
        local formattedWallet = formatNumberWithDots(playerWallet) .. "$"
        local formattedBank = formatNumberWithDots(bankAmount) .. "$"
        return "Wallet: " .. formattedWallet .. "|Bank: " .. formattedBank
    end, null, null, null)

    local playerKdAndBounty = function()
        local bountyAmount = getPlayerBountyAmount(plyId)
        bountyAmount = (bountyAmount == 0) and "None" or bountyAmount
        return "K/D: " .. string.format("%1.2f", getPlayerKd(plyId)) .. " (" .. getPlayerKills(plyId) .. ":" .. getPlayerDeaths(plyId) .. ")" .. "|\u{1F480} Bounty: " .. bountyAmount
    end
    sub:add_bare_item("", playerKdAndBounty, null, null, null)


    --Player Org
    greyText(sub, centeredText("------ Player Organisation------"))

    local playerOrg = function()
        local plyOrgID = getPlayerOrgID(plyId)
        if plyOrgID == -1 then
            return "No Organisation"
        end
        local playerOrgType = getPlayerOrgType(plyId) or "Employee in"
        local playerOrgName = getPlayerOrgName(plyId)
        return playerOrgType .. (playerOrgType == "Employee in" and " " or " of ") .. "\'" .. playerOrgName .. "\'"
    end
    sub:add_bare_item("", playerOrg, null, null, null)

    local plyOrgID = getPlayerOrgID(plyId)
    if plyOrgID ~= -1 then
        sub:add_action("\u{26A0} Force Join " .. getPlayerOrgName(plyId) .. " \u{26A0}", function()
            joinPlayerOrg(plyId)
        end)
    end

    --distance/speed
    greyText(sub, centeredText("--- Distance / Speed / Direction ---"))
    sub:add_bare_item("", function()
        local distanceStr = formatStyles[playerlistSettings.stringFormat] == "EU" and " km/h" or " mph"
        return "    " .. distanceBetween(localplayer, ply) .. " m    " .. updateSpeed(ply) .. distanceStr .. "   " .. getDirectionalArrow(getDirectionToThing(ply)) .. "    "
    end, null, null, null)
    sub:add_bare_item("", function()
        return "Pos: " .. printPlayerPos(ply)
    end, function()
        print(printPlayerPos(ply))
    end, null, null)

    greyText(sub, centeredText("------ Modder Info ------"))
    --general
    sub:add_bare_item("Confirmed as Modder", function()
        if marked_modders[plyName] == "detected" then
            return "Confirmed as Modder"
        end
    end, null, null, null)

    sub:add_bare_item("Godmode", function()
        if ply:get_godmode() then
            return "Godmode"
        end
    end, null, null, null)

    sub:add_bare_item("Godmode Outside Interior", function()
        if ply ~= localplayer and ply:get_godmode() and not isInInterior(ply, plyId) and tostring(ply:get_position().z) ~= "-51.3" then
            return "Godmode Outside Interior"
        end
    end, null, null, null)

    sub:add_bare_item("Less than 0 Max Health (Ghost)", function()
        if ply:get_max_health() <= 0 then
            return "Max Health 0 (Ghost)"
        end
    end, null, null, null)

    --vehicle
    if ply:is_in_vehicle() then
        local veh = ply:get_current_vehicle()
        sub:add_bare_item("Vehicle Godmode", function()
            if ply:is_in_vehicle() and veh:get_godmode() then
                return "Vehicle Is in Godmode"
            end
        end, null, null, null)

        sub:add_bare_item("Seatbelt", function()
            if ply:is_in_vehicle() and ply:get_seatbelt() then
                return "Seatbelt"
            end
        end, null, null, null)
    end

    --Debug Stuff
    greyText(sub, centeredText("------ DEBUGGING INFOS ------"))
    local respawnState = function()
        return "RespawnState: " .. getPlayerRespawnState(plyId)
    end
    sub:add_bare_item("", respawnState, null, null, null)
    local debugBlipType = function()
        local playerBlip = getPlayerBlip(plyId)
        local playerBlipType = getPlayerBlipType(plyId)
        if string.find(playerBlipType, "Blip:") or string.find(playerBlipType, "UNSURE:") then
            playerBlipType = "Unknown"
        end
        return "Blip ID: " .. playerBlip .. " (" .. playerBlipType .. ")"
    end
    sub:add_bare_item("", debugBlipType, null, null, null)
    sub:add_bare_item("", function()
        return "PlyId: " .. plyId
    end, null, null, null)
    sub:add_bare_item("", function()
        return "R* ID: " .. tostring(getRidForPlayer(plyName))
    end, null, null, null)
end

local showDisabledFlags = false
local showUnknownFlags = true
local function pedFlags(ply, sub)
    sub:clear()
    sub:add_toggle("Show ALL Flags \u{26A0} Large List! \u{26A0}", function() return showDisabledFlags end, function(n) showDisabledFlags = n if showDisabledFlags then showUnknownFlags = false end pedFlags(ply, sub) end)
    sub:add_toggle("Show Unknown Flags", function() return showUnknownFlags end, function(n) showUnknownFlags = n if showUnknownFlags then showDisabledFlags = false end pedFlags(ply, sub) end)
    greyText(sub, "============================")

    local min_index = math.huge
    local max_index = 0
    for i in pairs(PED_FLAG_TABLE) do
        min_index = math.min(min_index, i)
        max_index = math.max(max_index, i)
    end

    -- Create a list of all flags
    local allFlags = {}
    for i = min_index, max_index do
        local pedFlagString = PED_FLAG_TABLE[i]
        if pedFlagString then
            table.insert(allFlags, {index = i, name = pedFlagString})
        elseif showUnknownFlags then
            table.insert(allFlags, {index = i, name = "unknown #" .. i})
        end
    end

    -- Sort the flags
    table.sort(allFlags, function(a, b)
        if a.name:find("unknown") and b.name:find("unknown") then
            return a.index < b.index
        elseif a.name:find("unknown") then
            return false
        elseif b.name:find("unknown") then
            return true
        else
            return a.name < b.name
        end
    end)

    -- Add the flags to the sub
    for _, flag in ipairs(allFlags) do
        local i = flag.index
        local pedFlagString = flag.name
        if showDisabledFlags or ply:get_config_flag(i) == true then
            sub:add_toggle(pedFlagString, function()
                return ply:get_config_flag(i)
            end, function()
                ply:set_config_flag(i, not ply:get_config_flag(i))
            end)
        end
    end
end
-- auto-close submenu in case a player leaves while their info is open
local function refreshPlayer(plyName, plyId)
    if player.get_player_name(plyId) ~= plyName then
        menu.send_key_press(96)
    end
end

--Instantiates Player List that has SubMenus with Player names and general info about the player.
local savePositionType = { "Adjusted", "Actual" }
local savePositionSelection = 1
function addSubActions(sub, plyName, plyId)
    sub:clear()
    local ply = player.get_player_ped(plyId)
    if not ply then
        return
    end
    auto_action_player_id = plyId
    auto_action_player_name = plyName

    if ply == localplayer then
        greyText(sub, "--You--" .. "|Lvl " .. "(" .. getPlayerLevel(plyId) .. ")")
    else
        sub:add_bare_item(plyName .. "|Lvl " .. "(" .. getPlayerLevel(plyId) .. ")", function()
            refreshPlayer(plyName, plyId)
        end, null, null, null)
    end
    sub:add_toggle("    ++++++ Confirm Modder ++++++", function()
        return marked_modders[plyName] == "detected"
    end, function(_)
        toggleMarkedModder(plyName)
    end)
    local nearbyPlayersSub
    nearbyPlayersSub = sub:add_submenu("|Nearby Players", function()
        nearbyPlayersMenu(ply, nearbyPlayersSub, plyId)
    end)
    if ply ~= localplayer then
        greyText(sub, centeredText("--------Teleport--------"))
        sub:add_int_range("Teleport to " .. plyName .. "|Height:", 5, 0, 500, function()
            return teleportHeight
        end, function(n)
            tpToPlayer(ply, n, nil)
        end)
        sub:add_toggle("TP Spectate", function()
            return auto_teleport
        end, function(value)
            auto_teleport = value
            menu.emit_event('startAutoTeleport')
        end)
    end
    greyText(sub, centeredText("--------Vehicle Spawn--------"))
    local vehSpawnSub
    vehSpawnSub = sub:add_submenu("Spawn Vehicle for " .. plyName, function()
        addVehicleSpawnMenu(ply, vehSpawnSub)
    end)
    sub:add_action("Give Random Vehicle to " .. plyName, function()
        giveRandomVehicle(ply, nil)
    end)
    greyText(sub, centeredText("--------Trolling--------"))
    local trollSub = sub:add_submenu("\u{1F480} Trolling Options:")
    if ply == localplayer then
        addText(trollSub, centeredText("Troll yourself"))
    else
        trollSub:add_bare_item("Trolling " .. plyName .. "...", function()
            refreshPlayer(plyName, plyId)
        end, null, null, null)
    end
    local trollNearbyPlayersSub
    trollNearbyPlayersSub = trollSub:add_submenu("|Nearby Players", function()
        nearbyPlayersMenu(ply, trollNearbyPlayersSub, plyId)
    end)
    local numStars = 5
    trollSub:add_int_range("Give " .. plyName .. " Cops |\u{2605}", 1, 0, 5, function()
        return numStars
    end, function(n)
        numStars = n
        giveWantedLevel(plyId, numStars)
    end)
    trollSub:add_array_item("Set Bounty on " .. plyName .. ":", bounty_numbers, function()
        return current_bounty_number
    end, function(n)
        current_bounty_number = n
        sendBounty(plyId, bounty_numbers[current_bounty_number], false)
    end)
    if getScriptHostPlayerID() == getLocalplayerID() then
        trollSub:add_action("\u{26A0} Host Kick " .. plyName .. " \u{26A0}", function()
            hostKick(plyId)
        end)
    end
    greyText(trollSub, centeredText("--------Blocking Options---------"))
    trollSub:add_array_item("PED bomb |where?", teleportType, function()
        return teleportTypeSelection
    end, function(value)
        teleportTypeSelection = value
        tpPedToPlayer(ply, teleportType[value])
    end)
    trollSub:add_array_item("CAGE " .. plyName .. "", CageTypes, function()
        return CageType
    end, function(value)
        CageType = value
        cagePlayer(ply, CageTypes[value])
    end)
    trollSub:add_toggle("Invis Cage has collision?", function()
        return prepared
    end, function(value)
        prepared = value
    end)
    trollSub:add_toggle("Send Cage flying", function()
        return auto_fly
    end, function(value)
        auto_fly = value
        prepareFlying(ply)
        menu.emit_event('startFlyThread')
    end)
    greyText(trollSub, centeredText("--------Vehicle Trolling---------"))
    trollSub:add_action("RAMP player with ramp buggy", function()
        rampPly = ply
        menu.emit_event('giveRamp')
    end)
    trollSub:add_array_item("LAUNCH " .. plyName .. ":", LaunchTypes, function()
        return LaunchType
    end, function(value)
        LaunchType = value
        launchPly = ply
        menu.emit_event('launchOnce')
    end)
    trollSub:add_action("Give Random Vehicle to " .. plyName, function()
        giveRandomVehicle(ply, nil)
    end)
    trollSub:add_action("DROP Random Vehicle on " .. plyName, function()
        randomVehicleRain(ply)
    end)
    trollSub:add_array_item("SPAWN Above " .. plyName .. ":", dropVehicles, function()
        return selectedDropType
    end, function(value)
        selectedDropType = value
        dropVehicleOnPlayer(ply, dropVehicles[value])
    end)
    trollSub:add_bare_item("GEEET DUMPED OONN!!", function()
        return centeredText("GEEET DUMPED OONN!!")
    end, function()
        slamPly = ply
        menu.emit_event('preciseSlam')
    end, null, null)
    trollSub:add_action("Traffic Launcher", function()
        manipulatePlayerWithTraffic(ply, "launch")
    end)
    trollSub:add_action("SLAM " .. plyName .. " with traffic", function()
        manipulatePlayerWithTraffic(ply, "slam")
    end)
    trollSub:add_int_range("TP Vehicles to " .. plyName .. " |Range:", 1, 0, 10, function()
        return vehicleDistance
    end, function(n)
        TeleportVehiclesToPlayer(ply, n, false, nil)
    end)
    trollSub:add_int_range("EXPLODE " .. plyName .. " |Range:", 1, 0, 10, function()
        return vehicleDistance
    end, function(n)
        TeleportVehiclesToPlayer(ply, n, true, nil)
    end)
    trollSub:add_action("\u{26A0} EMERGENCY STOP ALL LOOPS \u{26A0}", emergencyStop)
    greyText(trollSub, centeredText("--------Loop Actions--------"))
    trollSub:add_toggle("|CONSTANT PEDS", function()
        return auto_peds
    end, function(value)
        auto_peds = value
        menu.emit_event('autoPedSpam')
    end)
    trollSub:add_toggle("|🚫 BIKE BLOCK 🚫", function()
        return auto_bike
    end, function(value)
        auto_bike = value
        menu.emit_event('autoBikeSpam')
    end)
    trollSub:add_toggle("|⬆️ KEEP LAUNCHING ⬆️", function()
        return auto_launch
    end, function(value)
        auto_launch = value
        menu.emit_event('autoLaunch')
    end)
    trollSub:add_toggle("|🚗 RANDOM VEHICLE SPAM 🚗", function()
        return auto_vehicle_spam
    end, function(value)
        auto_vehicle_spam = value
        menu.emit_event('autoVehicleSpam')
    end)
    trollSub:add_toggle("|🚠 CABLECAR SPAM 🚠", function()
        return auto_cable_spam
    end, function(value)
        auto_cable_spam = value
        menu.emit_event('autoCableCarSpam')
    end)
    trollSub:add_toggle("|🚂 TRAIN SPAM (NO DESPAWN)", function()
        return auto_train_spam
    end, function(value)
        auto_train_spam = value
        menu.emit_event('trainSpam')
    end)
    trollSub:add_toggle("|🌧️ RANDOM VEHICLE RAIN 🌧️", function()
        return auto_rain
    end, function(value)
        auto_rain = value
        menu.emit_event('startRainThread')
    end)
    trollSub:add_toggle("|🌪️ VEHICLE STORM 🌪️", function()
        return auto_storm
    end, function(value)
        auto_storm = value
        menu.emit_event('autoVehicleStorm')
    end)
    trollSub:add_toggle("|💥💥 CONSTANT EXPLOSION 💥💥", function()
        return auto_explode
    end, function(value)
        auto_explode = value
        menu.emit_event('startAutoExplode')
    end)
    trollSub:add_toggle("   ✈️\u{26A0} ITS RAINING PLANES \u{26A0}✈️", function()
        return auto_cargo_spam
    end, function(value)
        auto_cargo_spam = value
        menu.emit_event('autoCargoSpam')
    end)

    playerInfo(plyId, trollSub, plyName)
    playerInfo(plyId, sub, plyName)

    local pedFlagSub
    pedFlagSub = sub:add_submenu("(DEBUG) Show Active Ped Flags", function()
        pedFlags(ply, pedFlagSub)
    end)
    sub:add_array_item("+++ Save Pos as Interior : +++", savePositionType, function()
        return savePositionSelection
    end, function(value)
        savePositionSelection = value
        if savePositionSelection == 1 then
            local pos = ply:get_position()
            local adjustedPos = vector3(pos.x, pos.y, pos.z - 14.9)
            saveNewInterior(adjustedPos)
        else
            saveNewInterior(ply:get_position())
        end
    end)
end

local function addSessionOptions(sub)
    sub:clear()
    sub:add_bare_item("", function()
        return "Players in Session: " .. #sortedPlayers
    end, null, null, null)
    sub:add_bare_item("", function()
        return "Highest Level: " .. getTopPlayer(getPlayerLevel, "name")
    end, null, null, null)
    sub:add_bare_item("               " .. "(" .. getTopPlayer(getPlayerLevel, "value") .. ")", null, null, null, null)
    sub:add_bare_item("", function()
        return "Most Money:    " .. getTopPlayer(getPlayerMoney, "name")
    end, null, null, null)
    sub:add_bare_item("               " .. formatNumberWithDots(getTopPlayer(getPlayerMoney, "value")) .. "$", null, null, null, null)
    sub:add_bare_item("", function()
        return "Highest K/D:   " .. getTopPlayer(getPlayerKd, "name")
    end, null, null, null)
    sub:add_bare_item("               " .. string.format("%1.2f", getTopPlayer(getPlayerKd, "value")) .. " K/D", null, null, null, null)
    sub:add_bare_item("", function()
        return "Most Kills:    " .. getTopPlayer(getPlayerKills, "name")
    end, null, null, null)
    sub:add_bare_item("               " .. getTopPlayer(getPlayerKills, "value") .. " Kills", null, null, null, null)
    sub:add_bare_item("", function()
        return "Most Deaths:   " .. getTopPlayer(getPlayerDeaths, "name")
    end, null, null, null)
    sub:add_bare_item("               " .. getTopPlayer(getPlayerDeaths, "value") .. " Deaths", null, null, null, null)

    greyText(sub, "---------------------------")

    local ridSub
    ridSub = sub:add_submenu("Show all Found RIDs", function() ridList(ridSub) end)

    greyText(sub, "---------------------------")
    local numStars = 5
    sub:add_int_range("\u{26A0} GIVE ALL PLAYERS COPS \u{26A0} |\u{2605}", 1, 0, 6, function()
        return numStars
    end, function(n)
        numStars = n
        for _ = 0, 3 do
            for j = 0, 31 do
                local ply = player.get_player_ped(j)
                if ply and not (localplayer == ply) then
                    giveWantedLevel(j, numStars)
                    sleep(0.5)
                end
            end
        end
    end)
    sub:add_array_item("\u{26A0} SET BOUNTY ON EVERYONE \u{26A0} |\u{1F480}", bounty_numbers, function()
        return current_bounty_number
    end, function(n)
        current_bounty_number = n
        overrideBounty(bounty_numbers[current_bounty_number])
        for i = 0, 31 do
            local ply = player.get_player_ped(i)
            if ply then
                sendBounty(i, bounty_numbers[current_bounty_number], true)
            end
        end
        resetOverrideBounty()
    end)
end

local function addSettingsMenu(sub)
    sub:clear()
    greyText(sub, "-- ⚙️ Configure Playerlist: ⚙️ --")
    greyText(sub, "Changes are saved automatically!!")
    sub:add_toggle("|Disable Spectator Warning ", function() return playerlistSettings.disableSpectatorWarning end, function(value)
        playerlistSettings.disableSpectatorWarning =  value
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end)
    sub:add_toggle("|Disable Modder Warning ", function() return playerlistSettings.disableModdersWarning end, function(value)
        playerlistSettings.disableModdersWarning =  value
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end)
    sub:add_array_item("Default Sorting Method: ", sortStyles, function()
        return playerlistSettings.defaultSortingMethod
    end, function(value)
        playerlistSettings.defaultSortingMethod = value
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end)
    sub:add_array_item("Number/Distance Format: ", formatStyles, function()
        return playerlistSettings.stringFormat
    end, function(value)
        playerlistSettings.stringFormat = value
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end)

end

local function getSortedPlayers()
    local playerTypes = { modder = 1, god = 2, mortal = 3, interior = 4 }
    local sortedPlayers = {}

    for i = 0, 31 do
        local ply = player.get_player_ped(i)
        if ply then
            local name = player.get_player_name(i)
            local plyId = ply.get_player_id(ply)
            if plyId == -1 then
                print("Warn; Player-ID for player #" .. i .. " is -1, substituting with i instead")
                plyId = i
                if ply == localplayer then
                    getLocalplayerID(i)
                end
            end
            local isModder = modCheck(ply, name, plyId)
            local isGod = ply:get_godmode()
            local isInterior = isInInterior(ply, plyId)
            local playerType = isModder and "modder" or (isGod and not isInterior) and "god" or (not isInterior) and "mortal" or "interior"

            table.insert(sortedPlayers, { plyId, name, playerTypes[playerType] })
        end
    end
    table.sort(sortedPlayers, function(a, b)
        if a[3] == b[3] then
            return a[2]:upper() < b[2]:upper()
        else
            return a[3] < b[3]
        end
    end)
    return sortedPlayers
end

local updateable = true
local function SubMenus(playerList)
    updateable = false
    playerList:clear()
    triggerRidLookupTableRefresh(player.get_player_name(getLocalplayerID()) or nil)

    playerList:add_array_item("==========  UPDATE: ", sortStyles, function()
        return playerlistSettings.defaultSortingMethod
    end, function(value)
        if updateable then
            playerlistSettings.defaultSortingMethod = value
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
            SubMenus(playerList)
            return
        end
    end)

    sortedPlayers = sortStyles[playerlistSettings.defaultSortingMethod] == "Nearest first" and getPlayersByDistance(localplayer) or getSortedPlayers()

    for _, v in pairs(sortedPlayers) do
        addPlayerOption(v, playerList, nil)
    end

    greyText(playerList, "------------ Players: " .. #sortedPlayers .. " ------------")

    local sessionOptionsSub
    sessionOptionsSub = playerList:add_submenu("   🛈🛈🛈 Session Options/Info 🛈🛈🛈", function() addSessionOptions(sessionOptionsSub) end)

    updateable = true

    local settingsMenuSub
    settingsMenuSub = playerList:add_submenu("     ⚙️ Playerlist Settings ⚙️", function() addSettingsMenu(settingsMenuSub) end)
end


--F11 Random Vehicle
local randomVehicleHotkey
menu.register_callback('ToggleRandomVehicleHotkey', function()
    if not randomVehicleHotkey then
        randomVehicleHotkey = menu.register_hotkey(find_keycode("ToggleRandomVehicleHotkey"), function()
            giveRandomVehicle(localplayer, nil)
            displayHudBanner("HUD_RANDOM", "FMSTP_PRCL3", "", 109)
        end)
    else
        menu.remove_hotkey(randomVehicleHotkey)
        randomVehicleHotkey = nil
    end
end)


------------------------------------------------------
------------------------------------------------------
-------------- AUTO ACTIONS START HERE ---------------
------------------------------------------------------
------------------------------------------------------

--emergency stop all auto actions button, numpad comma (decimal) key
local emergencyStopHotkey
menu.register_callback('ToggleLoopStopHotkey', function()
    if not emergencyStopHotkey then
        emergencyStopHotkey = menu.register_hotkey(find_keycode("ToggleLoopStopHotkey"), emergencyStop)
    else
        menu.remove_hotkey(emergencyStopHotkey)
        emergencyStopHotkey = nil
    end
end)

local function vehicleRainThread()
    while auto_action_player_id and auto_rain do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_rain = false
            return
        end
        randomVehicleRain(autoPly())
        sleep(0.06)
    end
end

menu.register_callback('startRainThread', vehicleRainThread)

local function flyThread()
    sleep(0.15)
    while auto_fly and auto_yeet do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_fly = false
            return
        end
        auto_yeet:set_position(autoPly():get_position() + random_direction + vector3(0, 0, 5))
        sleep(0.12)
    end
end

menu.register_callback('startFlyThread', flyThread)

local original_pos
local teleported = false
local function autoTeleportThread()
    local myPlayer = player.get_player_ped()

    if not myPlayer or not auto_teleport then
        return
    end

    original_pos = myPlayer:get_position()
    myPlayer:set_godmode(true)
    myPlayer:set_max_health(0.0)
    myPlayer:set_freeze_momentum(true)
    myPlayer:set_no_ragdoll(true)
    local oldTeleportHeight = teleportHeight
    teleportHeight = 40

    while auto_action_player_id and auto_teleport do
        tpToPlayer(autoPly(), teleportHeight, myPlayer)
        teleported = true
        sleep(0.1)
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_teleport = false
        end
    end

    if teleported then
        teleportHeight = oldTeleportHeight
        myPlayer:set_godmode(false)
        myPlayer:set_max_health(328.0)
        myPlayer:set_freeze_momentum(false)
        myPlayer:set_no_ragdoll(false)
        myPlayer:set_position(original_pos)
        teleported = false
    end
end
menu.register_callback('startAutoTeleport', autoTeleportThread)

local function autoExplodeThread()
    while auto_action_player_id and auto_explode do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_explode = false
            return
        end
        TeleportVehiclesToPlayer(autoPly(), vehicleDistance, true, nil)
        sleep(0.35)
    end
end
menu.register_callback('startAutoExplode', autoExplodeThread)

local function autoVehicleStormThread()
    while auto_action_player_id and auto_storm do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_storm = false
            return
        end
        TeleportVehiclesToPlayer(autoPly(), vehicleDistance, false, nil)
        sleep(0.25)
    end
end
menu.register_callback('autoVehicleStorm', autoVehicleStormThread)

local function autoBikeSpamThread()
    while auto_action_player_id and auto_bike do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_bike = false
            return
        end
        giveRandomBike(autoPly())
        sleep(0.12)
    end
end
menu.register_callback('autoBikeSpam', autoBikeSpamThread)

local function autoRandomCarSpamThread()
    while auto_action_player_id and auto_vehicle_spam do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_vehicle_spam = false
            return
        end
        local pos = autoPly():get_position() + autoPly():get_heading() * 2 + autoPly():get_velocity() * 2
        local random_distance = vector3(math.random(-2, 2), math.random(2, 2), math.random(2, 2))
        giveRandomVehicle(autoPly(), pos + random_distance)
        sleep(0.2)
    end
end
menu.register_callback('autoVehicleSpam', autoRandomCarSpamThread)

local function autoCableCarSpamThread()
    while auto_action_player_id and auto_cable_spam do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_cable_spam = false
            return
        end
        local rot = autoPly():get_rotation()
        local angle = math.deg(math.atan(rot.y, rot.x + math.pi / 2))
        createVehicle(joaat("CableCar"), autoPly():get_position(), angle)
        sleep(0.2)
    end
end
menu.register_callback('autoCableCarSpam', autoCableCarSpamThread)

local function trainSpam()
    local i = 1
    while auto_action_player_id and auto_train_spam do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_train_spam = false
            return
        end
        createVehicle(joaat("Freight"), autoPly():get_position() + vector3(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)), math.random(0, 360))
        sleep(0.1)
        i = i + 1
    end
end
menu.register_callback('trainSpam', trainSpam)

local function autoPedSpamThread()
    while auto_action_player_id and auto_peds do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_peds = false
            return
        end
        tpPedToPlayer(autoPly(), teleportType[teleportTypeSelection])
        sleep(0.09)
    end
end
menu.register_callback('autoPedSpam', autoPedSpamThread)

local function cargoSpamThread()
    local vehicles = { "Cargoplane", "Jet", "Kosatka", "CableCar" } -- add your vehicle types here

    while auto_action_player_id and auto_cargo_spam do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_cargo_spam = false
            return
        end

        local vehicle = vehicles[math.random(#vehicles)] -- select random vehicle
        local random_distance = vector3((math.random(-900, 900) / 10), (math.random(-900, 900) / 10), (math.random(10, 1200) / 10))
        createVehicle(joaat(vehicle), autoPly():get_position() + random_distance, math.random(0, 360))

        for veh in replayinterface.get_vehicles() do
            if veh:get_model_hash() == joaat(vehicle) then
                veh:set_godmode(true)
            end
        end
        sleep(0.18)
    end
end
menu.register_callback('autoCargoSpam', cargoSpamThread)

local function autoLaunchThread()
    while auto_action_player_id and auto_launch do
        if player.get_player_name(auto_action_player_id) ~= auto_action_player_name then
            auto_launch = false
            return
        end
        LaunchType = 2
        launchPly = autoPly()
        menu.emit_event('launchOnce')
        sleep(0.16)
    end
end
menu.register_callback('autoLaunch', autoLaunchThread)

local function checkObviousModder(ply, plyName, i)
    if ply and ply:get_max_health() <= 0 or hasDevDLC(i) ~= 0 then
        marked_modders[plyName] = "detected"
        displayHudBanner(ply:get_max_health() <= 0 and "VVHUD_GHOST" or "PIM_GS_13", "GBC_STPASS_CHE", "", 90)
        return true
    end
    return false
end

local modders_cache = {}
local spectators_cache = {}
local function modWatcher()
    print("Starting ModWatcher...")
    while true do
        for i = 0, 31 do
            local ply = player.get_player_ped(i)
            if not ply then goto continue end
            local plyName = player.get_player_name(i)
            --Warn about spectating players with a "Warning! Spectator" label
            --Save their names to a table, so we don't warn again for the same player
            --Then delete their name if its been in there 12 (*5sec=60sec) times
            if isSpectatingMe(i) and not spectators_cache[plyName] then
                if not playerlistSettings.disableSpectatorWarning then
                    spectators_cache[plyName] = 0
                    displayHudBanner("HEIST_WARN_4", "SPEC_HEADER", 69, 78)
                end
            elseif spectators_cache[plyName] then
                spectators_cache[plyName] = spectators_cache[plyName] + 1
                if spectators_cache[plyName] == 12 then
                    spectators_cache[plyName] = nil
                end
            end
            if not (localplayer == ply) and not (marked_modders[plyName] == "detected") then
                if checkObviousModder(ply, plyName, i) then
                    goto continue
                end
                modders_cache[plyName] = modders_cache[plyName] or 0
                if modCheck(ply, plyName, i) and not ((getPlayerRespawnState(i) ~= 99) or (getPlayerBlipType(i) == "LOADING")) then
                    modders_cache[plyName] = modders_cache[plyName] + 1
                    if modders_cache[plyName] >= 10 then
                        modders_cache[plyName] = nil
                        marked_modders[plyName] = "detected"
                        if not playerlistSettings.disableModdersWarning then
                            displayHudBanner("FM_PLY_CHEAT", "GBC_STPASS_CHE", "", 90)
                        end
                    end
                else
                    modders_cache[plyName] = 0
                end
            end
        end
        :: continue ::
        sleep(5)
    end
end
menu.register_callback('startModWatcher', modWatcher)

local function playerListInitializer(sub)
    if updateable then
        SubMenus(sub)
        return
    end
end

local playerMenu
playerMenu = menu.add_player_submenu(centeredText("====== ULTIMATE Player List ======"), function()
    playerListInitializer(playerMenu)
end)

local playerMenu2
playerMenu2 = toolboxSub:add_submenu(centeredText("====== ULTIMATE Player List ======"), function()
    if finishedLoading then
        playerListInitializer(playerMenu2)
    end
end)