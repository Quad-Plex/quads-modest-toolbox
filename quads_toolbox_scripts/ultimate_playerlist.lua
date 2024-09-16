local savedInteriors = {}
local interiorsLoadingSuccess, jsonInteriors = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/SAVED_INTERIORS.json")
if interiorsLoadingSuccess then
    --Load the saved interiors from file
    for _, data in pairs(jsonInteriors) do
        savedInteriors[_] = vector3(data[1], data[2], data[3])
    end
end

local sortStyles = { [0]="Modders first", "Nearest first" }
formatStyles = { [0]="Metric (EU)", "Imperial (US)"}

settingsLoadingSuccess, playerlistSettings = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json")
if not settingsLoadingSuccess then
    playerlistSettings.disableSpectatorWarning = false
    playerlistSettings.disableModdersWarning = false
    playerlistSettings.defaultSortingMethod = 0
    playerlistSettings.stringFormat = 0
    playerlistSettings.defaultBoostStrength = 70
    playerlistSettings.speedDisplaySelection = 0
    playerlistSettings.pedChangerSleepTimeout = 0.08
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
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

local currentSpeed = 0.0
local function updateSpeed(ply)
    if not ply or ply == nil then
        return
    end
    local vel = ply:get_velocity()
    local x, y, z = math.abs(vel.x), math.abs(vel.y), math.abs(vel.z)

    if formatStyles[playerlistSettings.stringFormat] == "Imperial (US)" then
        currentSpeed = math.floor((math.sqrt(x * x + y * y + z * z) * 2.26) * 10) / 10
    else
        currentSpeed = math.floor((math.sqrt(x * x + y * y + z * z) * 3.6371084) * 10) / 10
    end
    return string.format("% 7.1f", currentSpeed)
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
    createVehicle(joaat("Dump"), (slamPly:get_position() + (vel * 1.26) + vector3(0, 0, 38)), nil, true, generateRandomMods(VEHICLE[joaat("Dump")][3]))
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
    createVehicle(joaat(model), ply:get_position() + (ply:get_velocity() * 2.22) + vector3(0, 0, 20), nil, true)
end

local manipulateRunning = false
local function manipulatePlayerWithTraffic(ply, action)
    if manipulateRunning then return end
    manipulateRunning = true
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
    manipulateRunning = false
end

local CageTypes = { "CableCar", "Spawned MOC", "TP invis MOC", "Remove Cages" }
local CageType = 1
local prepared = false
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
            --use tostring here to avoid floating point comparison bs while making sure to tp the right MOC
            if moc:get_model_hash() == joaat("TrailerLarge") and ((tostring(moc:get_position().z) == "-149.6112") or (moc:get_gravity() == 14.20)) then
                moc:set_godmode(false)
                moc:set_gravity(14.20)
                moc:set_health(1000)

                if not prepared then
                    local mocPosition = ply:get_position()
                    mocPosition.z = -200
                    moc:set_position(mocPosition)
                    sleep(0.2)
                    moc:set_health(1000)
                    teleportVehiclesToPlayer(mocPosition, 0, false, true)
                end
                moc:set_rotation(ply:get_rotation())
                moc:set_position(ply:get_position() + ply:get_heading() * 2.25 + vector3(0, 0, -0.88))
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
        createVehicle(joaat("CableCar"), ply:get_position(), angle, false, nil, true)
    end
end

--spawn a ramp buggy in front of the player, turned such that he will ramp over it if he's driving
local rampType = {[0]="Front", "Behind"}
local rampSelection = 0
local function giveRamp(rampPly, type)
    local currentVehicle
    local plyVehicle
    local distanceMul

    if localplayer:is_in_vehicle() then
        currentVehicle = localplayer:get_current_vehicle()
    end

    if rampPly:is_in_vehicle() then
        plyVehicle = rampPly:get_current_vehicle()
    end

    local plyVelocity = rampPly:get_velocity()
    local plyVelocityMagnitude = math.sqrt(plyVelocity.x^2 + plyVelocity.y^2 + plyVelocity.z^2)
    if plyVelocityMagnitude < 2 then plyVelocity = rampPly:get_heading() * 12 end
    local plyHeading = rampPly:get_heading()
    local angle
    if type == "Front" then
        angle = math.deg(math.atan(plyHeading.y, plyHeading.x)) + 90
    else
        angle = math.deg(math.atan(plyHeading.y, plyHeading.x)) - 90
    end
    angle = (angle + 360) % 360

    if type == "Front" then
        if localplayer:is_in_vehicle() then
            distanceMul = 1.5
        else
            distanceMul = 1.0
        end
    else
        if localplayer:is_in_vehicle() then
            distanceMul = 1.3
        else
            distanceMul = 0.8
        end
    end
    if type == "Front" then
        createVehicle(joaat("dune5"), rampPly:get_position() + (plyVelocity * distanceMul) + vector3(0, 0, 0.89), angle)
    else
        createVehicle(joaat("dune5"), rampPly:get_position() + ((plyVelocity * distanceMul) * -1) + vector3(0, 0, 0.89), angle)
    end
    sleep(0.05)
    local forced
    for veh in replayinterface.get_vehicles() do
        if (veh:get_model_hash() == joaat("dune5")) and (veh:get_gravity() ~= 20) and (not currentVehicle or currentVehicle ~= veh) and (not plyVehicle or plyVehicle ~= veh) then
            local oldBrakeForce = veh:get_brake_force()
            local oldHandbrakeForce = veh:get_handbrake_force()
            found = true
            veh:set_gravity(20)
            veh:set_brake_force(-100000)
            veh:set_handbrake_force(-100000)
            --createVehicle will use the alternative spawning method if we're in a vehicle,
            --which doesn't support setting the heading, so the following only needs to be done in that case
            if localplayer:is_in_vehicle() then
                local rot = rampPly:get_rotation()
                --to rotate the buggy by 180°, add 1 PI to its x rotation as it's in radians
                --and in order to tilt it properly if the player is e.g. driving upwards, take the inverse of the player's z rotation
                if type == "Front" then
                    rot = vector3(rot.x + math.pi, rot.y, rot.z * -1)
                end
                for _ = 0, 200 do
                    veh:set_rotation(rot)
                    veh:set_brake_force(-100000)
                    veh:set_handbrake_force(-100000)
                    sleep(0.02)
                end
                forced = true
            end
            if not forced then
                sleep(2)
            end
            veh:set_brake_force(oldBrakeForce)
            veh:set_handbrake_force(oldHandbrakeForce)
            local removePos = rampPly:get_position() + vector3(0, 0, -300)
            for _ = 0, 20 do
                veh:set_position(removePos)
                sleep(0.05)
            end
            return
        end
    end
end

local function getPlayerStateText(ply, plyId)
    if not ply or not plyId then
        return ""
    end

    if ply:get_model_hash() ~= joaat("mp_m_freemode_01") and ply:get_model_hash() ~= joaat("mp_f_freemode_01") then
        return "!PED! "
    end

    if ply:get_max_health() <= 0 then
        return "!GHST! "
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

    if hasDevDLC(plyId) then
        return "!DEV!"
    end

    return math.floor(healthPercent + 0.5) .. "♥"
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

    --exclude config flag 65, which is 'is_swimming', as you can't swim inside and swimming as such usually means they're in the ocean or in a deep pool
    if ply:get_config_flag(65) == true then
        return false
    end

    --unloaded players are stored at the -51.3 z coordinate, so exclude them from the interior check
    local plyPos = ply:get_position()
    if ply:is_in_cutscene() or (plyPos.z < -30 and tostring(plyPos.z) ~= "-51.3") then
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

local function modCheck(ply, plyName, plyId, skipVehCheck)
    if not ply then return false end
    if (plyName and marked_modders[plyName] == "detected") or hasDevDLC(plyId) or ply:get_max_health() < 100 then
        return true
    end
    if getPlayerRespawnState(plyId) ~= 99 or ply:is_in_cutscene() or (getPlayerBlipType(plyId) == "LOADING") then --avoid false positives
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
    if not skipVehCheck then
        if ply:is_in_vehicle() and (ply:get_current_vehicle():get_godmode()) and not interior_bool then
            return true
        end
    end
    if not skipVehCheck then
        if ply:is_in_vehicle() and ply:get_seatbelt() and not interior_bool then
            return true
        end
    end
    if ply:get_model_hash() ~= joaat("mp_m_freemode_01") and ply:get_model_hash() ~= joaat("mp_f_freemode_01") then
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
    if ply:get_config_flag(420) then return "🚨" end
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
    elseif (blipType == "PLANE_GHOST") or (blipType == "ULTRALIGHT_GHOST") then
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
    if formatStyles[playerlistSettings.stringFormat] == "Metric (EU)" then
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
        if formatStyles[playerlistSettings.stringFormat] == "Metric (EU)" then
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
            nameAddons = "💀" .. nameAddons
        end
        if player == localplayer then
            displayName = "--You--"
        elseif amISpectating(playerId) then
            nameAddons = "ⓢ" .. nameAddons
        elseif isSpectatingMe(playerId) then
            nameAddons = "🅂" .. nameAddons
        end
        if getScriptHostPlayerID() == playerId then
            nameAddons = "🄷" .. nameAddons
        end
        if nameAddons ~= "" then
            displayName = nameAddons .. " " .. displayName
        end

        local playerStateText = getPlayerStateText(player, playerId)
        local modderSymbol = getModderSymbol(player, playerName, playerId)
        local playerStateSymbol = getPlayerStateSymbol(player, playerId)
        local modelIconStr = modelIcon(player, playerId)
        local distance = distanceBetween(playerDistance, player, false, largeDistanceDisplay)
        if formatStyles[playerlistSettings.stringFormat] == "Imperial (US)" then
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
            performRidUpdate(sub)
        end)
    else
        greyText(sub, "Names have their first 4 letters cut")
        greyText(sub, "off, ask R* Devs why")
        greyText(sub, "Using Offset: " .. tostring(baseGlobals.ridLookup.freemode_base_local))
        for name, rid in pairs(ridLookupTable) do
            sub:add_bare_item("", function() return "Name: " .. name .. "| Rid: " .. rid end, null, null, null)
        end
    end
end


--Generates specific info about the player
local ridSearched = false
local function playerInfo(plyId, sub, plyName)
    local oldPly
    local function ply()
        local newPly = player.get_player_ped(plyId)
        if newPly then
            oldPly = newPly
            return newPly
        else
            return oldPly
        end
    end
    if not ply() then
        return
    end
    greyText(sub, "======== ⇩ 🛈 PLAYER INFO 🛈 ⇩ ========")

    --Display player state
    sub:add_bare_item("", function()
        local txt = ""
        local blipType = getPlayerBlipType(plyId)

        if ply() ~= localplayer and amISpectating(plyId) then
            txt = txt .. "SPEC "
        end
        if ply():get_model_hash() ~= joaat("mp_m_freemode_01") and ply():get_model_hash() ~= joaat("mp_f_freemode_01") then
            txt = txt .. "MODDED_PED "
        end
        if ply() ~= localplayer and isSpectatingMe(plyId) then
            txt = txt .. "!WATCHING YOU! "
        end
        if getScriptHostPlayerID() == plyId then
            txt = txt .. "HOST "
        end
        if isInInterior(ply(), plyId) and blipType ~= "INTERIOR" then
            txt = txt .. "INTERIOR "
        end
        if ply():get_godmode() and not isInInterior(ply(), plyId) then --Don't show godmode for players in an interior
            txt = txt .. "GOD "
        end
        if hasDevDLC(plyId) then
            txt = txt .. "!DEV! "
        end
        if modCheck(ply(), plyName, plyId) then
            txt = txt .. "HAX "
        end
        if ply():is_in_cutscene() then
            txt = txt .. "CUTSCENE "
        end

        --Add the blip type to the info
        return centeredText(txt .. blipType)
    end, null, null, null)

    --health/armor/wanted level
    greyText(sub, centeredText("------ Health/Armor/Wanted Level ------"))
    sub:add_bare_item("", function()
        local healthPercent = (ply():get_health() / ply():get_max_health()) * 100
        local respawnState = getPlayerRespawnState(plyId)

        if healthPercent == 0 or respawnState == -1 then
            healthPercent = "DED"
        elseif healthPercent >= 0 then
            healthPercent = math.floor(healthPercent + 0.5) .. "\u{2665}"
        else
            healthPercent = "MOD GHOST"
        end

        local armor = (math.floor(ply():get_armour()) * 2) .. "%"
        local wanted = ply():get_wanted_level() > 0 and string.rep(" \u{2605}", ply():get_wanted_level(), "") or "0\u{2605}  "
        local vehicle_health = ply():is_in_vehicle() and math.floor(ply():get_current_vehicle():get_health()) or 0

        return " " .. healthPercent .. "    " .. armor .. "\u{1F6E1}    " .. wanted .. "|" .. "\u{1F697}" .. vehicle_health .. "\u{2665}"
    end, null, null, null)

    --Weapon/Vehicle
    greyText(sub, centeredText("------ 🔫 Weapon / Vehicle 🚗------"))
    sub:add_bare_item("", function()
        local wpn_text = getWpn(ply())
        local vehicle_name, vehicle_class = "On Foot", ""

        if ply():is_in_vehicle() then
            local veh = ply():get_current_vehicle()
            local details = VEHICLE[veh:get_model_hash()]
            if details then
                vehicle_name, vehicle_class = details[1], details[2]
            else
                vehicle_name = "Not Found, Hash:" .. veh:get_model_hash()
            end
        else
            local blipType = getPlayerBlipType(plyId)
            if vehicleBlips[blipType] then
                vehicle_name = "Vehicle"
            end
        end
        return wpn_text .. "|" .. vehicle_name .. " - " .. vehicle_class
    end, null, null, null)

    sub:add_action("Force enter " .. plyName .. "'s Vehicle", function()
        if ply():is_in_vehicle() or vehicleBlips[getPlayerBlipType(plyId)] then
            local oldPos = localplayer:get_position()
            local offRadarToggled = false
            if localplayer:get_max_health() > 100 then --Do the TP into vehicle while in offradar so other people don't see us jumping around on the minimap if it fails
                offRadar()
                offRadarToggled = true
            end
            if not ply():is_in_vehicle() then --Assume the player is in a vehicle (determined before this through blip type) so we teleport closer first to make sure the vehicle is loaded correctly
                localplayer:set_freeze_momentum(true)
                localplayer:set_no_ragdoll(true)
                localplayer:set_config_flag(292, true)
                tpToPlayer(ply(), -5, nil)
                local counter = 0
                repeat
                    counter = counter + 1
                until ply():is_in_vehicle() or counter == 40000
                sleep(0.05)
            end
            setPedIntoVehicle(getVehicleForPlayerID(plyId), oldPos)
            if offRadarToggled then
                offRadar()
            end
        end
    end, function()
        return ply():is_in_vehicle() or getPlayerBlipType(plyId) == "VEHICLE" or getPlayerBlipType(plyId) == "PLANE_GHOST"
    end)
    --Player Stats
    greyText(sub, centeredText("------ Player Stats ------"))
    sub:add_bare_item("", function()
        local playerWallet = getPlayerWalletAmount(plyId)
        local bankAmount = math.max(0, getPlayerBankAmount(plyId) - playerWallet)
        local formattedWallet = formatNumberWithDots(playerWallet) .. "$"
        local formattedBank = formatNumberWithDots(bankAmount) .. "$"
        return "Wallet " .. formattedWallet .. "|Bank " .. formattedBank
    end, null, null, null)

    sub:add_bare_item("", function()
        local bountyAmount = getPlayerBountyAmount(plyId)
        bountyAmount = (bountyAmount == 0) and "None" or bountyAmount
        return "K/D: " .. string.format("%1.2f", getPlayerKd(plyId)) .. " (" .. getPlayerKills(plyId) .. ":" .. getPlayerDeaths(plyId) .. ")" .. "|\u{1F480} Bounty: " .. bountyAmount
    end, null, null, null)

    --Player Org
    greyText(sub, centeredText("------ Player Organisation------"))

    sub:add_bare_item("", function()
        local plyOrgID = getPlayerOrgID(plyId)
        if plyOrgID == -1 then
            return "No Organisation"
        end
        local playerOrgType = getPlayerOrgType(plyId) or "Employee in"
        local playerOrgName = getPlayerOrgName(plyId)
        return playerOrgType .. (playerOrgType == "Employee in" and " " or " of ") .. "\'" .. playerOrgName .. "\'"
    end, null, null, null)

    sub:add_action("\u{26A0} Force Join " .. getPlayerOrgName(plyId) .. " \u{26A0}", function()
        joinPlayerOrg(plyId)
    end, function() return getPlayerOrgID(plyId) ~= -1 end)

    --distance/speed
    greyText(sub, centeredText("--- Distance / Speed / Direction ---"))
    sub:add_bare_item("", function()
        local distanceStr = formatStyles[playerlistSettings.stringFormat] == "Metric (EU)" and " km/h" or " mph"
        return "    " .. distanceBetween(localplayer, ply()) .. " m    " .. updateSpeed(ply()) .. distanceStr .. "   " .. getDirectionalArrow(getAngleToThing(ply())) .. "    "
    end, null, null, null)
    sub:add_bare_item("", function()
        return "Pos: " .. printPlayerPos(ply())
    end, function()
        print(printPlayerPos(ply()))
    end, null, null)

    greyText(sub, centeredText("------ Modder Info ------"))
    --general
    sub:add_bare_item("❌ Not confirmed as modder", function()
        if marked_modders[plyName] == "detected" then
            return "✔️ Confirmed as Modder"
        end
    end, null, null, null)

    sub:add_bare_item("❌ Not using my script", function()
        if ply():get_config_flag(420) then
            return "✔️ Using my script"
        end
    end, null, null, null)

    sub:add_bare_item("❌ No godmode outside interior", function()
        local vehicle = ply():is_in_vehicle() and ply():get_current_vehicle()
        local vehicle_model = vehicle and vehicle:get_model_hash()
        if ply() ~= localplayer and ply():get_godmode() and not isInInterior(ply(), plyId) and ply():get_health() ~= 0 and not (vehicle and isExcludedVehicle(vehicle_model)) then
            return "✔️ Godmode Outside Interior"
        end
    end, null, null, null)

    sub:add_bare_item("❌ Normal Max Health", function()
        if ply():get_max_health() <= 0 then
            return "✔️ Max Health 0 (Ghost)"
        end
    end, null, null, null)

    --vehicle
    sub:add_bare_item("❌ No vehicle godmode", function()
        if ply():is_in_vehicle() and ply():get_current_vehicle():get_godmode() then
            return "✔️ Vehicle Is in Godmode"
        end
    end, null, null, null)

    sub:add_bare_item("❌ No seatbelt", function()
        if ply():is_in_vehicle() and ply():get_seatbelt() then
            return "✔️ Seatbelt"
        end
    end, null, null, null)

    sub:add_bare_item("❌ Dev DLC not active", function()
        if hasDevDLC(plyId) then
            return "✔️ Dev DLC active"
        end
    end, null, null, null)

    sub:add_bare_item("❌ Default Ped", function()
        if ply():get_model_hash() ~= joaat("mp_m_freemode_01") and ply():get_model_hash() ~= joaat("mp_f_freemode_01") then
            return "✔️ Modded Ped Model"
        end
    end, null, null, null)

    --Debug Stuff
    greyText(sub, centeredText("------ ADVANCED INFOS ------"))
    sub:add_bare_item("", function() return "Ped Model: " .. findPedDataFromHash(ply():get_model_hash())[3] end, null, null, null)
    sub:add_bare_item("", function() return "RespawnState: " .. getPlayerRespawnState(plyId) end, null, null, null)
    sub:add_bare_item("", function()
        local playerBlip = getPlayerBlip(plyId)
        local playerBlipType = getPlayerBlipType(plyId)
        if string.find(playerBlipType, "Blip:") or string.find(playerBlipType, "UNSURE:") then
            playerBlipType = "Unknown"
        end
        return "Blip ID: " .. playerBlip .. " (" .. playerBlipType .. ")"
    end, null, null, null)
    sub:add_bare_item("", function()
        return "PlyId: " .. plyId
    end, null, null, null)
    sub:add_bare_item("", function()
        if getRidForPlayer(plyName) then
            return "R* ID: " .. getRidForPlayer(plyName)
        else
            return ridSearched and "R* ID: not found :(..." or "R* ID: start search (~2min)"
        end
        end, function()
        if getRidForPlayer(plyName) or ridSearched then return end
        performRidUpdate(sub, plyName)
        ridSearched = true
        local rid = getRidForPlayer(plyName) or "not found :(..."
        return "R* ID: " .. rid
    end, null, null)
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
        menu.send_key_press(returnHotkey)
    end
end

--Instantiates Player List that has SubMenus with Player names and general info about the player.
function addSubActions(sub, plyName, plyId)
    sub:clear()
    local oldPly
    local function ply()
        local newPly = player.get_player_ped(plyId)
        if newPly then
            oldPly = newPly
            return newPly
        else
            return oldPly
        end
    end
    emergencyStopLoops()

    if ply() == localplayer then
        greyText(sub, "--You--" .. "|Lvl " .. "(" .. getPlayerLevel(plyId) .. ")")
    else
        sub:add_bare_item(plyName .. "|Lvl " .. "(" .. getPlayerLevel(plyId) .. ")", function()
            --This function will be called every time the cursor moves in the playerlist
            updateLoopData()
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
        nearbyPlayersMenu(ply(), nearbyPlayersSub, plyId)
    end)
    if ply() ~= localplayer then
        greyText(sub, centeredText("--------Teleport/Track--------"))
        sub:add_int_range("Teleport to " .. plyName .. "|Height:", 5, 0, 500, function()
            return teleportHeight
        end, function(n)
            tpToPlayer(ply(), n, nil)
        end)
        sub:add_toggle("TP Spectate", function()
            return loopData.auto_teleport
        end, function(value)
            if value then
                loopData.auto_teleport = true
                setLoopPlayer(plyId, plyName)
                menu.emit_event('startAutoTeleport')
            else
                loopData.auto_teleport = false
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
            end
        end)
        sub:add_toggle("📍 GPS Tracker 📍", function()
            return loopData.auto_gps
        end, function(value)
            if value then
                loopData.auto_gps = true
                setLoopPlayer(plyId, plyName)
                menu.emit_event('trackGPS')
            else
                loopData.auto_gps = false
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
            end
        end)
    end
    greyText(sub, centeredText("--------Vehicle Spawn--------"))
    local vehSpawnSub
    vehSpawnSub = sub:add_submenu("Spawn Vehicle for " .. plyName, function()
        addVehicleSpawnMenu(ply(), vehSpawnSub)
    end)
    sub:add_action("Give Random Vehicle to " .. plyName, function()
        giveRandomVehicle(ply())
    end)
    greyText(sub, centeredText("--------Trolling--------"))
    local trollSub = sub:add_submenu("\u{1F480} Trolling Options:")
    if ply() == localplayer then
        trollSub:add_bare_item("Troll yourself", function()
            --This function will be called every time the cursor moves in the playerlist
            updateLoopData()
        end, null, null, null)
    else
        trollSub:add_bare_item("Trolling " .. plyName .. "...", function()
            --This function will be called every time the cursor moves in the playerlist
            updateLoopData()
            refreshPlayer(plyName, plyId)
        end, null, null, null)
    end
    local trollNearbyPlayersSub
    trollNearbyPlayersSub = trollSub:add_submenu("|Nearby Players", function()
        nearbyPlayersMenu(ply(), trollNearbyPlayersSub, plyId)
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
    trollSub:add_array_item("Hire Mugger/Mercenaries", mugger_selection, function()
        return current_mugger_choice
    end, function(n)
        current_mugger_choice = n
        hireMuggerOrMercenary(plyId, current_mugger_choice)
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
        tpPedToPlayer(ply(), teleportType[value])
    end)
    trollSub:add_array_item("𐂺 CAGE " .. plyName .. " 𐂺", CageTypes, function()
        return CageType
    end, function(value)
        CageType = value
        cagePlayer(ply(), CageTypes[value])
    end)
    trollSub:add_toggle("Invis Cage has collision?", function()
        return prepared
    end, function(value)
        prepared = value
    end)
    trollSub:add_toggle("↑ Send invis Cage flying ↑", function()
        return loopData.auto_fly
    end, function(value)
        if value then
            loopData.auto_fly = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('startFlyThread')
        else
            loopData.auto_fly = false
            saveLoopData()
        end
    end)
    greyText(trollSub, centeredText("--------Vehicle Trolling---------"))
    trollSub:add_array_item("◢ RAMP player ◢", rampType, function() return rampSelection end, function(type)
        rampSelection = type
        giveRamp(ply(), rampType[type])
    end)
    trollSub:add_array_item("  🚀✋   ROCKET SLAP    🚀✋ ", rocketType, function() return rocketSelection end, function(n)
        rocketSelection = n
        rocketSlap(ply(), false,  rocketType[rocketSelection])
    end)
    trollSub:add_array_item("⬆️ LAUNCH " .. plyName .. " ⬆️ with:", LaunchTypes, function()
        return LaunchType
    end, function(value)
        LaunchType = value
        launchOnce(ply())
    end)
    trollSub:add_action("|Give Random Vehicle", function()
        giveRandomVehicle(ply())
    end)
    trollSub:add_action("|DROP Random Vehicle", function()
        randomVehicleRain(ply())
    end)
    trollSub:add_array_item("|Drop Vehicle:", dropVehicles, function()
        return selectedDropType
    end, function(value)
        selectedDropType = value
        dropVehicleOnPlayer(ply(), dropVehicles[value])
    end)
    trollSub:add_bare_item("GEEET DUMPED OONN!!", function()
        return centeredText("💀 GEEET DUMPED OONN!! 💀")
    end, function()
        slamPly = ply()
        menu.emit_event('preciseSlam')
    end, null, null)
    trollSub:add_action("⬆️ Traffic Launcher ⬆️", function()
        manipulatePlayerWithTraffic(ply(), "launch")
    end)
    trollSub:add_action("⬇️ Traffic SLAM ⬇️", function()
        manipulatePlayerWithTraffic(ply(), "slam")
    end)
    trollSub:add_int_range("✨ TP Vehicles ✨ |Radius:", 1, 0, 10, function()
        return vehicleDistance
    end, function(n)
        vehicleDistance = n
        teleportVehiclesToPlayer(ply(), n, false)
    end)
    trollSub:add_int_range("💥 EXPLODE 💥 |Radius:", 1, 0, 10, function()
        return vehicleDistance
    end, function(n)
        vehicleDistance = n
        teleportVehiclesToPlayer(ply():get_position(), n, true, true)
    end)
    greyText(trollSub, centeredText("--------Loop Actions--------"))
    trollSub:add_action("\u{26A0} EMERGENCY STOP ALL LOOPS \u{26A0}", function() emergencyStopLoops() end)
    trollSub:add_toggle("|🚶🚶 CONSTANT PEDS 🚶🚶", function()
        return loopData.auto_peds
    end, function(value)
        if value then
            loopData.auto_peds = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoPedSpam')
        else
            loopData.auto_peds = falsen
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🚫 BIKE BLOCK 🚫", function()
        return loopData.auto_bike
    end, function(value)
        if value then
            loopData.auto_bike = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoBikeSpam')
        else
            loopData.auto_bike = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🤚🏻 CONSTANT ROCKET SLAP 🤚🏻", function()
        return loopData.auto_slap
    end, function(value)
        if value then
            loopData.auto_slap = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoSlapSpam')
        else
            loopData.auto_slap = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|⬆️ KEEP LAUNCHING ⬆️", function()
        return loopData.auto_launch
    end, function(value)
        if value then
            loopData.auto_launch = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoLaunch')
        else
            loopData.auto_launch = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🚗 RANDOM VEHICLE SPAM 🚗", function()
        return loopData.auto_vehicle_spam
    end, function(value)
        if value then
            loopData.auto_vehicle_spam = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoVehicleSpam')
        else
            loopData.auto_vehicle_spam = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🚠 CABLECAR SPAM 🚠", function()
        return loopData.auto_cable_spam
    end, function(value)
        if value then
            loopData.auto_cable_spam = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoCableCarSpam')
        else
            loopData.auto_cable_spam = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🚂 TRAIN SPAM (NO DESPAWN)", function()
        return loopData.auto_train_spam
    end, function(value)
        if value then
            loopData.auto_train_spam = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('trainSpam')
        else
            loopData.auto_train_spam = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🌧️ RANDOM VEHICLE RAIN 🌧️", function()
        return loopData.auto_rain
    end, function(value)
        if value then
            loopData.auto_rain = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('startRainThread')
        else
            loopData.auto_rain = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|🌪️ VEHICLE STORM 🌪️", function()
        return loopData.auto_storm
    end, function(value)
        if value then
            loopData.auto_storm = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoVehicleStorm')
        else
            loopData.auto_storm = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("|💥💥 CONSTANT EXPLOSION 💥💥", function()
        return loopData.auto_explode
    end, function(value)
        if value then
            loopData.auto_explode = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('startAutoExplode')
        else
            loopData.auto_explode = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)
    trollSub:add_toggle("   ✈️\u{26A0} CARGO SPAM (FPS Killer) \u{26A0}✈️", function()
        return loopData.auto_cargo_spam
    end, function(value)
        if value then
            loopData.auto_cargo_spam = true
            setLoopPlayer(plyId, plyName)
            menu.emit_event('autoCargoSpam')
        else
            loopData.auto_cargo_spam = false
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        end
    end)

    playerInfo(plyId, trollSub, plyName)
    playerInfo(plyId, sub, plyName)

    local pedFlagSub
    pedFlagSub = sub:add_submenu("(DEBUG) Show Active Ped Flags", function()
        pedFlags(ply(), pedFlagSub)
    end)
    sub:add_action("+++ Save current Pos as Interior +++", function()
        saveNewInterior(ply():get_position())
    end)
end

local function maxOrMin(value) return value == 1 and "Max" or "Min" end
local statSelection = 1
local function addSessionOptions(sub)
    sub:clear()
    sub:add_bare_item("", function()
        return "Players in Session: " .. #sortedPlayers
    end, null, null, null)
    sub:add_array_item("Type of Stats: ", {"Highest", "Lowest"}, function() return statSelection end, function(value) statSelection = value end)
    greyText(sub, "----------------------------")
    sub:add_bare_item("", function() return maxOrMin(statSelection) .. " Level:   " .. getTopPlayer(getPlayerLevel, "name", statSelection == 2) end, null, null, null)
    sub:add_bare_item("", function() return "              " .. "(" .. getTopPlayer(getPlayerLevel, "value", statSelection == 2) .. ")" end, null, null, null)
    sub:add_bare_item("", function() return maxOrMin(statSelection) .. " Money:   " .. getTopPlayer(getPlayerBankAmount, "name", statSelection == 2) end, null, null, null)
    sub:add_bare_item("", function() return "              " .. formatNumberWithDots(getTopPlayer(getPlayerBankAmount, "value", statSelection == 2)) .. "$" end, null, null, null)
    sub:add_bare_item("", function() return maxOrMin(statSelection) .. " K/D:     " .. getTopPlayer(getPlayerKd, "name", statSelection == 2) end, null, null, null)
    sub:add_bare_item("", function() return "              " .. string.format("%1.2f", getTopPlayer(getPlayerKd, "value", statSelection == 2)) .. " K/D" end, null, null, null)
    sub:add_bare_item("", function() return maxOrMin(statSelection) .. " Kills:   " .. getTopPlayer(getPlayerKills, "name", statSelection == 2) end, null, null, null)
    sub:add_bare_item("", function() return "              " .. getTopPlayer(getPlayerKills, "value", statSelection == 2) .. " Kills" end, null, null, null)
    sub:add_bare_item("", function() return maxOrMin(statSelection) .. " Deaths:  " .. getTopPlayer(getPlayerDeaths, "name", statSelection == 2) end, null, null, null)
    sub:add_bare_item("", function() return "              " .. getTopPlayer(getPlayerDeaths, "value", statSelection == 2) .. " Deaths" end, null, null, null)

    greyText(sub, "---------------------------")

    local ridSub
    ridSub = sub:add_submenu("Show all found RIDs", function() ridList(ridSub) end)

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
                sleep(0.2)
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
    sub:add_toggle("|Disable Modder Warnings ", function() return playerlistSettings.disableModdersWarning end, function(value)
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

local function addHelpMenu(sub)
    sub:clear()
    addText(sub, "        ❓️  FAQ/HELP  ❓️")
    greyText(sub, "-------- Symbol explanation: --------")
    addText(sub, " 🄷 : Player is host of this session")
    addText(sub, " 🅂 : Player is spectating YOU")
    addText(sub, " ⓢ : YOU are spectating this player")
    addText(sub, "💀 : Player has a bounty")
    greyText(sub, "-------- Label explanation: --------")
    addText(sub, "!PED!: Modded ped model")
    addText(sub, "!GHST!: Modded Ghost (0 Health)")
    addText(sub, "!DEV!: Dev DLC active (modder/admin)")
    greyText(sub, "----------- FAQs -----------")
    addText(sub, "Playerlist elements look weird:")
    addText(sub, "  For best appearance, use the")
    addText(sub, "  'Quad_Tools_Theme'. Go to")
    addText(sub, "  Menu Settings -> Reload Themes")
    addText(sub, "  and then select it")
    addText(sub, "Invis Cage:")
    addText(sub, "  Doesn't always work.")
    addText(sub, "  Teleports an unloaded MOC trailer")
    addText(sub, "  to cage the player. Teleports traffic")
    addText(sub, "  traffic aswell to get collision ")
    addText(sub, "  working. \"invis cage has collision\"")
    addText(sub, "  prevents the traffic teleport")
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
local function initializePlayerlist(playerList)
    updateable = false
    playerList:clear()
    triggerRidLookupTableRefresh(player.get_player_name(getLocalplayerID()) or -1)

    playerList:add_array_item("==========  UPDATE: ", sortStyles, function()
        return playerlistSettings.defaultSortingMethod
    end, function(value)
        if updateable then
            playerlistSettings.defaultSortingMethod = value
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
            initializePlayerlist(playerList)
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
    settingsMenuSub = playerList:add_submenu("      ⚙️ Playerlist Settings ⚙️", function() addSettingsMenu(settingsMenuSub) end)

    local helpSub
    helpSub = playerList:add_submenu("        ❓️  FAQ/HELP  ❓️", function() addHelpMenu(helpSub) end)
end

--F11 Random Vehicle
local randomVehicleHotkey
menu.register_callback('ToggleRandomVehicleHotkey', function()
    if not randomVehicleHotkey then
        randomVehicleHotkey = menu.register_hotkey(find_keycode("ToggleRandomVehicleHotkey"), function()
            displayHudBanner("HUD_RANDOM", "FMSTP_PRCL3", "", 108)
            giveRandomVehicle(localplayer)
        end)
    else
        menu.remove_hotkey(randomVehicleHotkey)
        randomVehicleHotkey = nil
    end
end)

local function checkObviousModder(ply, plyName, i)
    if not ply then return end
    if ply:get_config_flag(420) then displayHudBanner("IAA_USER", "TR_HUD_TAIL", 0, 90, true) marked_modders[plyName] = "detected" return true end
    if ply:get_max_health() <= 0 or hasDevDLC(i) then
        marked_modders[plyName] = "detected"
        if not playerlistSettings.disableModdersWarning then
            displayHudBanner(ply:get_max_health() <= 0 and "VVHUD_GHOST" or "PIM_GS_13", "GBC_STPASS_CHE", "", 90)
        end
        return true
    end
    if ply:get_model_hash() ~= joaat("mp_m_freemode_01") and ply:get_model_hash() ~= joaat("mp_f_freemode_01") then
        marked_modders[plyName] = "detected"
        if not playerlistSettings.disableModdersWarning then
            displayHudBanner("OVHEAD_PED", "GBC_STPASS_CHE", "", 90)
        end
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
            if not ply or (ply == localplayer) then goto continue end
            local plyName = player.get_player_name(i)
            --Warn about spectating players with a "Warning! Spectator" label
            --Save their names to a table, as not to warn again for the same player
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
            if not (marked_modders[plyName] == "detected") then
                if checkObviousModder(ply, plyName, i) then
                    goto continue
                end
                modders_cache[plyName] = modders_cache[plyName] or 0
                if modCheck(ply, plyName, i, true) and not ((getPlayerRespawnState(i) ~= 99) or (getPlayerBlipType(i) == "LOADING")) then
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
            :: continue ::
        end
        localplayer:set_config_flag(420, true)
        sleep(5)
    end
end
menu.register_callback('startModWatcher', modWatcher)

local function playerListInitializer(sub)
    if updateable then
        initializePlayerlist(sub)
        return
    end
end

local playerMenu
playerMenu = menu.add_player_submenu(centeredText("====== Player List ======"), function()
    playerListInitializer(playerMenu)
end)

local playerMenu2
playerMenu2 = toolboxSub:add_submenu(centeredText("====== Player List ======"), function()
    if finishedLoading then
        playerListInitializer(playerMenu2)
    end
end)