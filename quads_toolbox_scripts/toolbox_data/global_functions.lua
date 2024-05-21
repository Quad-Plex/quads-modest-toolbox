baseGlobals = {}

------------------------------Localplayer ID getter----------------------------
baseGlobals.localPlayerGlobal = {}
baseGlobals.localPlayerGlobal.baseGlobal = 2672741
baseGlobals.localPlayerGlobal.bareStringCheck = function()
    return "LocalplayerID from Global: " .. tostring(globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal))
end

function getLocalplayerID()
    if (localplayer and localplayer:get_player_id() ~= -1) then
        return localplayer:get_player_id()
    else
        local globalID = globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal)
        return globalID or -1
    end
end

function getOrSetPlayerPedID(set)
    if set then
        globals.set_int(baseGlobals.localPlayerGlobal.baseGlobal + 4 + 15, set)
    else
        return globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal + 4 + 15)
    end
end

baseGlobals.playerPedGlobal = {}
baseGlobals.playerPedGlobal.baseGlobal = 1906517
baseGlobals.playerPedGlobal.freemode_local = 450 + 641
baseGlobals.playerPedGlobal.bareStringCheck = function()
    return "Own PlayerPed: " .. tostring(getPlayerPed(getLocalplayerID()))
end

function getPlayerPed(playerID)
    if not globals.get_bool(baseGlobals.playerPedGlobal.baseGlobal + 1 + (getLocalplayerID() * 299) + 29 + 18) then
        globals.set_bool(baseGlobals.playerPedGlobal.baseGlobal + 1 + (getLocalplayerID() * 299) + 29 + 18, true)
    end
    if script("freemode"):is_active() then
        return script("freemode"):get_int(baseGlobals.playerPedGlobal.freemode_local + 1 + (playerID * 3) + 2)
    end
end

------------------Message Display-----------------------
--TODO: only displayBoxType 39 showed a weird string on the bottom sometimes, which seemed to contain a playername
--after session switch that string disappeared - has to be configurable somehow
local timeoutDuration
baseGlobals.messageDisplay = {}
baseGlobals.messageDisplay.baseGlobal = 2672741 + 2518 + 1
baseGlobals.messageDisplay.testFunction = function()
    displayHudBanner("FGTXT_F_F3", "RESPAWN_W", "", 108)
end
--Credits to Kiddion for finding this stuff in an older version
--https://www.unknowncheats.me/forum/3523555-post2032.html
function displayHudBanner(headline, subHeadline, variable_text, box_type)
    if localplayer == nil then return end
    globals.set_string(baseGlobals.messageDisplay.baseGlobal + 21, headline, 16)
    globals.set_string(baseGlobals.messageDisplay.baseGlobal + 8, subHeadline, 32)
    if variable_text ~= "" then
        if type(variable_text) == "number" then
            if checkType(variable_text) == "Int" then
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 3, variable_text)
            else
                globals.set_float(baseGlobals.messageDisplay.baseGlobal + 3, variable_text)
            end
        elseif type(variable_text) == "string" then
            globals.set_string(baseGlobals.messageDisplay.baseGlobal + 3, variable_text, 32)
        end
    end
    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 1, box_type)
    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 2, 1)
    timeoutDuration = 2
end

function OnScriptsLoadedGlobal()
    while true do
        while timeoutDuration do
            if timeoutDuration > 0 then
                sleep(0.1)
                timeoutDuration = timeoutDuration - 0.1
            elseif timeoutDuration <= 0 then
                timeoutDuration = nil
                --Setting both globals to 1 removes the currently displayed message
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 1, 1)
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 2, 1)
            end
        end
        sleep(0.4)
    end
end

menu.register_callback('OnScriptsLoaded', OnScriptsLoadedGlobal)

-----------------------------------------------------------------------------
------------------------ Vehicle Spawners -----------------------------------
baseGlobals.vehicleSpawner = {}
baseGlobals.vehicleSpawner.baseGlobal = 2640095
baseGlobals.vehicleSpawner.testFunction = function()
    createVehicle(joaat("Youga4"), localplayer:get_position() + localplayer:get_heading() * 5)
end
baseGlobals.vehicleSpawner.testFunctionExplanation = "Spawn Youga4 with spawner#1"


baseGlobals.vehicleSpawner2 = {}
baseGlobals.vehicleSpawner2.baseGlobal2 = 2695991
baseGlobals.vehicleSpawner2.testFunction = function()
    createVehicle(joaat("PoliceOld2"), localplayer:get_position() + localplayer:get_heading() * 5, nil, nil, nil, true)
end
baseGlobals.vehicleSpawner2.testFunctionExplanation = "Spawn PoliceOld2 with spawner#2"

baseGlobals.vehicleSpawnerNetID = {}
baseGlobals.vehicleSpawnerNetID.vehNetIDGlobal = 2738587
baseGlobals.vehicleSpawnerNetID.bareStringCheck = function()
    return "VehNetID (last spawned): " .. tostring(getNetIDOfLastSpawnedVehicle())
end

function getNetIDOfLastSpawnedVehicle()
    return globals.get_int(baseGlobals.vehicleSpawnerNetID.vehNetIDGlobal + 6762)
end

function createVehicle(modelHash, pos, heading, skip_remove_current, mod, alternative_spawn_toggle)
    if not type(modelHash):match("number") then
        modelHash = joaat(modelHash)
    end
    --###SPAWNER #1 (With heading, spammable, without mods)
    if not alternative_spawn_toggle and not player.get_player_ped():is_in_vehicle() then
        local oldNetID = getNetIDOfLastSpawnedVehicle()
        globals.set_int(baseGlobals.vehicleSpawner.baseGlobal + 47, modelHash)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 43, pos.x)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 44, pos.y)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 45, pos.z)
        if heading then
            globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 46, heading)
        end
        globals.set_boolean(baseGlobals.vehicleSpawner.baseGlobal + 42, true)
        sleep(0.1)
        local newNetID = getNetIDOfLastSpawnedVehicle()
        if newNetID ~= oldNetID then
            return
        end
    end
    --###SPAWNER #2 (Without heading, with mods, more reliable)
    if not vehicle_is_creating then
        vehicle_is_creating = true
        if (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) then
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 5, -1) --primary color selection
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 6, -1) --secondary color selection
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 7, -1) --pearlescent color selection
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 8, -1) --wheel color selection
            if type(mod):match("table") then
                --Write each mod integer into the globals in an array
                for i = 1, globals.get_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9) do
                    --see eVehicleModType
                    globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9 + i, mod[i])
                end
            end
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 62, math.random(0, 255)) --VEHICLE::SET_VEHICLE_TYRE_SMOKE_COLOR Red
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 63, math.random(0, 255)) --Green
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 64, math.random(0, 255)) --Blue
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 66, modelHash) --veh hash
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 69, -1) --veh wheel type (category) see eVehicleWheelType
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 74, math.random(0, 255)) --Neon color Red
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 75, math.random(0, 255)) --Green
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 76, math.random(0, 255)) --Blue
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 71, math.random(0, 255)) --Custom Primary/Secondary Color Red
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 72, math.random(0, 255)) --Green
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 73, math.random(0, 255)) --Blue (has to be enabled via flag)
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 77, -264240640) --Bit-Storage for veh flags 0-8: veh-specific, reserved, 9:bulletproof tires, 10: bool vehicle_is_stolen,  12: custom secondary color, 13: custom primary color, 27: bool IgnoredByQuickSave decor 28: Neon Front, 29: Neon Back, 30: Neon Left, 31: Neon Right
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 94, 4) --0: nil, 1: set decor player_vehicle, 2: set decor veh_modded_by_player
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 95, 15) --Bit-Storage for previous global (1111)
            if not skip_remove_current then
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, pos.x) --Spawn location xyz
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, pos.y)
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, -255)
                globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) --Spawn trigger #1
                globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) --Spawn trigger #2
                repeat
                until (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) --Wait for under-map spawn to complete
            end
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, pos.x)
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, pos.y)
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, pos.z)
            globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) --Spawn trigger #1
            globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) --Spawn trigger #2
            repeat
            until (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) --Spawn again at correct coords, removing any vehicle in the way
        end
        vehicle_is_creating = nil
        return getNetIDOfLastSpawnedVehicle()
    end
end
--thanks to @Alice2333 on UKC for showing me the second spawner code

--{5, 3, -1, 6, 3, 1, -1, -1, -1, -1, -1, 4, 3, 3, 58, 4, 5, 1, 1, 1, 1, 1, math.random(0, 14), 217, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 15}
local eVehicleModType = {
    VMT_SPOILER = 0,
    VMT_BUMPER_F = 1,
    VMT_BUMPER_R = 2,
    VMT_SKIRT = 3,
    VMT_EXHAUST = 4,
    VMT_CHASSIS = 5,
    VMT_GRILL = 6,
    VMT_BONNET = 7,
    VMT_WING_L = 8,
    VMT_WING_R = 9,
    VMT_ROOF = 10,
    VMT_ENGINE = 11,
    VMT_BRAKES = 12,
    VMT_GEARBOX = 13,
    VMT_HORN = 14,
    VMT_SUSPENSION = 15,
    VMT_ARMOUR = 16,
    VMT_NITROUS = 17,
    VMT_TURBO = 18,
    VMT_SUBWOOFER = 19,
    VMT_TYRE_SMOKE = 20,
    VMT_HYDRAULICS = 21,
    VMT_XENON_LIGHTS = 22,
    VMT_WHEELS = 23,
    VMT_WHEELS_REAR_OR_HYDRAULICS = 24,
    VMT_PLTHOLDER = 25,
    VMT_PLTVANITY = 26,
    VMT_INTERIOR1 = 27,
    VMT_INTERIOR2 = 28,
    VMT_INTERIOR3 = 29,
    VMT_INTERIOR4 = 30,
    VMT_INTERIOR5 = 31,
    VMT_SEATS = 32,
    VMT_STEERING = 33,
    VMT_KNOB = 34,
    VMT_PLAQUE = 35,
    VMT_ICE = 36,
    VMT_TRUNK = 37,
    VMT_HYDRO = 38,
    VMT_ENGINEBAY1 = 39,
    VMT_ENGINEBAY2 = 40,
    VMT_ENGINEBAY3 = 41,
    VMT_CHASSIS2 = 42,
    VMT_CHASSIS3 = 43,
    VMT_CHASSIS4 = 44,
    VMT_CHASSIS5 = 45,
    VMT_DOOR_L = 46,
    VMT_DOOR_R = 47,
    VMT_LIVERY_MOD = 48,
    VMT_LIGHTBAR = 49,
}

local eVehicleWheelType = {
    VWT_SPORT = 0,
    VWT_MUSCLE = 1,
    VWT_LOWRIDER = 2,
    VWT_SUV = 3,
    VWT_OFFROAD = 4,
    VWT_TUNER = 5,
    VWT_BIKE = 6,
    VWT_HIEND = 7,
    VWT_SUPERMOD1 = 8, --Benny's Original
    VWT_SUPERMOD2 = 9, --Benny's Bespoke
    VWT_SUPERMOD3 = 10, --Open Wheel
    VWT_SUPERMOD4 = 11, --Street
    VWT_SUPERMOD5 = 12, --Track
}

------------------------------------------------------------------------------------------------
----------------------------------- set ped into vehicle ---------------------------------------
baseGlobals.setIntoVehicle = {}
baseGlobals.setIntoVehicle.baseGlobal = 2738587
baseGlobals.setIntoVehicle.forceControl = 2635562
baseGlobals.setIntoVehicle.bareStringCheck = function()
    return "Using Veh with ID:: " .. tostring(getVehicleForPlayerID() or "")
end

local function getForcedVehicleHandle(playerID)
    local oldVehicleNetIDValue = globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7022)
    local playerPed = getPlayerPed(playerID)
    local count = 0
    while true and (count < 100000) do
        --Force a different playerPed into the function that gets the veh net ID
        getOrSetPlayerPedID(playerPed)
        local newVehicleNetIDValue = globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7022)
        --Hope that the game used that Ped to get a different car net ID
        if (newVehicleNetIDValue ~= oldVehicleNetIDValue) then
            return newVehicleNetIDValue
        end
        count = count + 1
    end
end

function getVehicleForPlayerID(playerID)
    if not playerID or playerID == getLocalplayerID() then
        if (globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7022) ~= 0) then
            return globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7022) --ped:get_vehicle_ped_is_in(Global_2672741.f_4.f_15
        end
    else
        local player = player.get_player_ped(playerID)
        if player then
            if localplayer:is_in_vehicle() then
                if (localplayer:get_current_vehicle() == player:get_current_vehicle()) then
                    return globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7022)
                end
            end
            return getForcedVehicleHandle(playerID)
        end
    end
end

function setPedIntoVehicle(vehicleNetID, oldPos)
    if (vehicleNetID and (vehicleNetID ~= 0)) then
        local i = 0
        repeat
            localplayer:set_freeze_momentum(true)
            localplayer:set_no_ragdoll(true)
            localplayer:set_config_flag(292, true)
            i = i + 1
            globals.set_int(baseGlobals.setIntoVehicle.forceControl + 3184, vehicleNetID) --Network request control of entity
            setPlayerRespawnState(getLocalplayerID(), 5)
            globals.set_int(baseGlobals.setIntoVehicle.forceControl + 614, 5) --ped:set_ped_into_vehicle set in #1
            if (i == 5) then
                break
            end
            sleep(0.11)
        until (getVehicleForPlayerID() == vehicleNetID)
        sleep(0.3)
        if getVehicleForPlayerID() ~= vehicleNetID or not localplayer:is_in_vehicle() then
            print("Couldn't enter vehicle")
            --Assume entering the vehicle failed
            local tries = 0
            while (tries < 4) do
                nativeTeleport(oldPos)
                tries = tries + 1
                sleep(0.1)
            end
            setPlayerRespawnState(getLocalplayerID(), 7) --setting respawn to 7 gives back player control after getting stuck, unable to enter a car
        end
    end
    localplayer:set_freeze_momentum(false)
    localplayer:set_no_ragdoll(false)
    localplayer:set_config_flag(292, false)
end

----------------------Pickup Spawner--------------------------
baseGlobals.ambientSpawner = {}
baseGlobals.ambientSpawner.spawn_trigger = 2707022
baseGlobals.ambientSpawner.networked_trigger = 262145 + 31218
baseGlobals.ambientSpawner.pickup_data = 2707016
baseGlobals.ambientSpawner.check = 4535851
baseGlobals.ambientSpawner.testFunction = function()
    createPickup(localplayer:get_position(), 420)
end
function createPickup(pos, value)
    local freemode_script = script("freemode")
    if freemode_script:is_active() then
        globals.set_int(baseGlobals.ambientSpawner.networked_trigger, 0)
        globals.set_uint(baseGlobals.ambientSpawner.spawn_trigger, 1)
        globals.set_int(baseGlobals.ambientSpawner.pickup_data + 1, value) --cash value
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 3, pos.x)
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 4, pos.y)
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 5, pos.z)
        globals.set_uint(baseGlobals.ambientSpawner.check + 1 + (globals.get_int(baseGlobals.ambientSpawner.pickup_data) * 85) + 66 + 2, 2)
    end
end

------------------------------------------------------------------
---------------------Get Player Stats-----------------------------
--Global_1845263[PLAYER::PLAYER_ID() /*877*/].f_205.f_6 Level
--.f_3 Wallet, .f_56 cumulative money, .f_28 kills, .f_29 deaths
baseGlobals.playerLevel = {}
baseGlobals.playerLevel.baseGlobal = 1845263
baseGlobals.playerLevel.testIntRange = function()
    return getPlayerLevel(getLocalplayerID())
end
baseGlobals.playerLevel.intRangeExplanation = "Shows your own LVL:"
getPlayerLevel = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 6)
end

getPlayerWallet = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 3)
end

getPlayerMoney = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 56)
end

getPlayerKd = function(plyId)
    local kills = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 28)
    local deaths = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 29)
    if kills == 0 or deaths == 0 then
        return 0
    end
    return kills / deaths
end

getPlayerKills = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 28)
end

getPlayerDeaths = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 29)
end

function getTopPlayer(getPlayerAttribute, nameOrId)
    local maxAttribute = 0
    local topPlayer

    for i = 0, 31 do
        local ply = player.get_player_ped(i)
        if ply then
            local attribute = getPlayerAttribute(i)
            if attribute and attribute > maxAttribute then
                maxAttribute = attribute
                topPlayer = i
            end
        end
    end
    if not topPlayer then 
		if nameOrId == "name" then
			return "/"
		else
			return "-1"
		end
	end
    if nameOrId == "name" then
        return player.get_player_name(topPlayer) or ""
    elseif nameOrId == "id" then
        return topPlayer
    else
        return maxAttribute
    end
end

-------------------------------------------------------------------
---------------------Check Dev DLC --------------------------------
--Global_2657921[bParam1 /*463*/].f_269
baseGlobals.devCheck = {}
baseGlobals.devCheck.baseGlobal = 2657921
hasDevDLC = function(plyId)
    return globals.get_int(baseGlobals.devCheck.baseGlobal + 1 + (plyId * 463) + 269)
end

-------------------------------------------------------------------
----------------------Respawn State (Interior Check)----------------
--Global_2657921[iVar0 /*463*/].f_232
baseGlobals.respawnState = {}
baseGlobals.respawnState.baseGlobal = 2657921
baseGlobals.respawnState.testIntRange = function()
    return getPlayerRespawnState(getLocalplayerID())
end
baseGlobals.respawnState.intRangeExplanation = "Should be 99 while idling outside"
-- Order of States when Dying: -1 0 2 9 99
-- 99 is fully loaded

getPlayerRespawnState = function(plyId)
    return globals.get_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 463) + 232)
end

-- -1/1 repair vehicle, 11 flip vehicle, 2-6 are respawn triggers
--Only seem to work on oneself
setPlayerRespawnState = function(plyId, value)
    globals.set_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 463) + 232, value)
end

---------------------Player Org---------------------------------
--HUUUUUUUUUGE thanks to book4 on UKC for sharing a bunch of useful globals
--Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10
--OrgColor is at .f104
baseGlobals.playerOrg = {}
baseGlobals.playerOrg.baseGlobal = 1886967
baseGlobals.playerOrg.bareStringCheck = function()
    return getPlayerOrgID(getLocalplayerID()) ~= -1 and "Own Org Name: " .. tostring(getPlayerOrgName(getLocalplayerID())) or "No Organisation found"
end
local org_types = { [0] = "CEO", "MC" }
getPlayerOrgType = function(plyId)
    return org_types[globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10 + 429)]
end

getPlayerOrgName = function(plyId)
    local orgName = globals.get_string(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10 + 105, 30)
    if orgName == "" then
        orgName = "Organisation"
    end
    return orgName
end

getPlayerOrgID = function(plyId)
    return globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10)
end

joinPlayerOrg = function(plyId)
    local plyOrgId = getPlayerOrgID(plyId)
    globals.set_int(baseGlobals.playerOrg.baseGlobal + 1 + (getLocalplayerID() * 609) + 10, plyOrgId)
end

------------------------Set Wanted Level Remote----------------------
--Global_2657921[bVar0 /*463*/].f_214 playerId
--Global_2657704[bVar0 /*463*/].f_215 num of stars (0-5)
baseGlobals.wantedLevel = {}
baseGlobals.wantedLevel.baseGlobal = 2657921
baseGlobals.wantedLevel.testFunction = function()
    giveWantedLevel(getLocalplayerID(), 5)
    sleep(0.5)
    giveWantedLevel(getLocalplayerID(), 0)
end
baseGlobals.wantedLevel.testFunctionExplanation = "Give yourself 5 Stars"
giveWantedLevel = function(plyId, numStars)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (getLocalplayerID() * 463) + 214, plyId)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (getLocalplayerID() * 463) + 215, numStars)
end

----------------------------------------------------------------
---------------------Get PlayerVehicleBlipType------------------
-- Helper Method for working with a set
function utils_Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end
--see https://www.unknowncheats.me/forum/3955633-post14596.html
--Global_2657921[player /*463*/].f_73.f_3
interiorBlips = {
    ["INTERIOR"] = true,
    ["LS CUSTOMS"] = true,
    ["CAR_MEET_MODSHOP"] = true,
    ["KOSATKA"] = true,
    ["AMMO NATION"] = true,
    ["LOADING"] = true,
    ["CAR MEET"] = true,
    ["AUTO SHOP"] = true,
    ["CLOTHES"] = true
}
-- Create a lookup table for playerBlipTypes
shortformBlips = {
    ["LOADING"] = "LOAD",
    ["LS CUSTOMS"] = "LSC",
    ["PLANE GHOST"] = "FLY_GHO",
    ["ULTRALIGHT GHOST"] = "UL_GHO",
    ["AMMO NATION"] = "AMMO",
    ["KOSATKA"] = "SUBM",
    ["HEIST BOARD"] = "HEIST",
    ["DELIVERY_MISSION"] = "DELIV",
    ["BEAST"] = "BEAST",
    ["CASHIER"] = "STORE",
    ["CAR MEET"] = "LSCM",
    ["AUTO SHOP"] = "AUTO",
    ["JUNK PARACHUTE"] = "PRCH",
    ["SHOP"] = "SHOP",
    ["BALLISTIC ARMOR"] = "ARMR",
    ["PREP_MISSION"] = "PREP"
}
baseGlobals.blipType = {}
baseGlobals.blipType.baseGlobal = 2657921
baseGlobals.blipType.testIntRange = function()
    return getPlayerBlip(getLocalplayerID())
end
baseGlobals.blipType.intRangeExplanation = "Should be 4 while idling outside"
local vehicle_blips = utils_Set({ 262144, 262145, 262148, 262149, 262156, 262164, 262165, 262208, 262212, 262248, 262276, 262277, 262660, 262661, 262724, 262784, 262789, 262788, 786564, 2627888, 2359300 })
local plane_ghost_blips = utils_Set({ 8388612, 8650884, 8651332, 8651396, 8651397, 8650756, 8650757, 8650820, 8651268, 8651269 })
local ultralight_ghost_blips = utils_Set({ 262676, 262740 })
local ls_customs_blip = utils_Set({ 2097280, 2359330, 2359458, 262178 })
local interior_blips = utils_Set({ 262274, 262656, 262272, 192, 64, 128, 196, 576, 512, 517, 640, 708, 1 })
local normal_blips = utils_Set({ 4, 5, 68, 132, 140, 516, 580, 644 })
local ls_car_meet = utils_Set({ 2359334, 2359426, 2359296, 262146 })
local cashier_blip = utils_Set({ 2097152 })
local auto_shop = utils_Set({ 2359298, 2359302 })
local beast_blips = utils_Set({ 1048580, 1049092, 1310724, 1310788, 1311236, 1572868, 1835012, 1835524 })
local kosatka_blip = utils_Set({ 262213, 262341, 262336, 262337, 262340, 262720 })
local ammo_nation_blip = utils_Set({ 2 })
local junk_parachute_blip = utils_Set({ 2097156, 2097220 })
local unsure_blips = utils_Set({ 2622788, 262656, 2359299, 524416, 524420 })
local delivery_mission_blips = utils_Set({ 786432, 786436, 786437, 786500, 786560, 786948, 787076, 524256, 524292, 524288, 524293 })
local ballistic_armor_blip = utils_Set({ 16777220, 16777216, 16777348, 17039364, 17039876 })
local shop_blips = utils_Set({ 2097282, 2097154 })
local heist_planning_board = utils_Set({ 704 })
local loading_blips = utils_Set({ 0, 6 })
local prep_mission_blips = utils_Set({524804})

getPlayerBlipType = function(plyId)
    local plyBlip = globals.get_int(baseGlobals.blipType.baseGlobal + (plyId * 463) + 73 + 3)

    if vehicle_blips[plyBlip] then
        return "VEHICLE"
    elseif interior_blips[plyBlip] then
        return "INTERIOR"
    elseif plane_ghost_blips[plyBlip] then
        return "PLANE GHOST"
    elseif ultralight_ghost_blips[plyBlip] then
        return "ULTRALIGHT GHOST"
    elseif beast_blips[plyBlip] then
        return "BEAST"
    elseif ls_customs_blip[plyBlip] then
        return "LS CUSTOMS"
    elseif shop_blips[plyBlip] then
        return "SHOP"
    elseif normal_blips[plyBlip] then
        return ""
    elseif cashier_blip[plyBlip] then
        return "CASHIER"
    elseif loading_blips[plyBlip] then
        return "LOADING"
    elseif ls_car_meet[plyBlip] then
        return "CAR MEET"
    elseif junk_parachute_blip[plyBlip] then
        return "JUNK PARACHUTE"
    elseif auto_shop[plyBlip] then
        return "AUTO SHOP"
    elseif delivery_mission_blips[plyBlip] then
        return "DELIVERY_MISSION"
    elseif kosatka_blip[plyBlip] then
        return "KOSATKA"
    elseif ammo_nation_blip[plyBlip] then
        return "AMMO NATION"
    elseif ballistic_armor_blip[plyBlip] then
        return "BALLISTIC ARMOR"
    elseif heist_planning_board[plyBlip] then
        return "HEIST BOARD"
    elseif unsure_blips[plyBlip] then
        return "UNSURE: " .. plyBlip
    elseif prep_mission_blips[plyBlip] then
        return "PREP_MISSION: " .. plyBlip
    else
        return "Blip:" .. plyBlip
    end
end

getPlayerBlip = function(plyId)
    return globals.get_int(baseGlobals.blipType.baseGlobal + (plyId * 463) + 73 + 3)
end

----------------------------------------------------------------
---------------------Podium Vehicle Changer---------------------
baseGlobals.podiumVehicle = {}
baseGlobals.podiumVehicle.baseGlobal = 289178
baseGlobals.podiumVehicle.testFunction = function()
    setPodiumVehicle(joaat("Tug"))
end
baseGlobals.podiumVehicle.testFunctionExplanation = "Change Podium Veh. to Tugboat"
function setPodiumVehicle(vehicleHash)
    globals.set_int(baseGlobals.podiumVehicle.baseGlobal, vehicleHash)
end

function getPodiumVehicle()
    return globals.get_int(baseGlobals.podiumVehicle.baseGlobal)
end



------------------------------------------------------------------
------------------Bounty Functions--------------------------------
---CREDITS GO ENTIRELY TO APPLEVEGASS!!!!
-- 1.67 globals. Found by: (AppleVegas), updated for 1.69 by Quad_Plex
--easily updated by looking for TXT_BNTY_NPC1 in freemode.c
--Global_2359296[func_900() /*5569*/].f_5151.f_14
baseGlobals.bountyGlobals = {}
baseGlobals.bountyGlobals.bounty_base = 2738587
baseGlobals.bountyGlobals.bounty_overrideBounty = 262145
baseGlobals.bountyGlobals.bounty_selfValue = 2359296 + 1 + (0 * 5569) + 5151 + 14
baseGlobals.bountyGlobals.testFunction = function()
    sendBountyToYourself(420)
end
baseGlobals.bountyGlobals.testFunctionExplanation = "Set 420 Bounty on yourself"
local minPay = 1000
local function calculateFee(amount)
    return amount > minPay and (amount - minPay) * -1 or minPay - amount
end

function overrideBounty(amount)
    local fee = calculateFee(amount)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2348, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2349, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2350, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2351, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2352, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7178, fee)
end

function resetOverrideBounty()
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2348, 2000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2349, 4000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2350, 6000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2351, 8000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2352, 10000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7178, 1000)
end

function sendBountyToYourself(money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_selfValue, money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 1893 + 57, 0)
end

function sendBounty(id, amount, skipOverride)
    if player.get_player_ped(id) == localplayer then
        sendBountyToYourself(amount)
        return
    end

    if not skipOverride then
        overrideBounty(amount)
    end
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4571, id)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4571 + 1, 1)
    globals.set_bool(baseGlobals.bountyGlobals.bounty_base + 4571 + 2 + 1, true)
    sleep(0.5)
    if not skipOverride then
        resetOverrideBounty()
    end
end

--------------------------------------------------------------
--------------------------Host Check--------------------------
--Global_2650416.f_1
baseGlobals.hostCheck = {}
baseGlobals.hostCheck.baseGlobal = 2650416 + 1
baseGlobals.hostCheck.testCheck = function()
    return getScriptHostPlayerID() == getLocalplayerID()
end
baseGlobals.hostCheck.checkExplanation = "(Solo Session) Am I Host?:"
function getScriptHostPlayerID()
    return globals.get_int(baseGlobals.hostCheck.baseGlobal)
end

---------------------------Host Kick--------------------------
--Global_1877042[PLAYER::PLAYER_ID()]
baseGlobals.hostKick = {}
baseGlobals.hostKick.baseGlobal = 1877042
baseGlobals.hostKick.testFunction = function()
    hostKick(getLocalplayerID())
end
baseGlobals.hostKick.testFunctionExplanation = "(Solo session) Kick yourself"
function hostKick(plyId)
    globals.set_int(baseGlobals.hostKick.baseGlobal + 1 + (plyId), 1)
end

--------------------Spectator Detection--------------------------------
--isTrackedPedVisible
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_33
--isVisibleToScript
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_34
--Scanned:
--SpecdPlayerId: 2672741

baseGlobals.spectatorCheck = {}
baseGlobals.spectatorCheck.specPlayerBaseGlobal = 2657921
baseGlobals.spectatorCheck.testCheck = function()
    return amISpectating(getLocalplayerID())
end
baseGlobals.spectatorCheck.checkExplanation = "Am I spectating myself?"

baseGlobals.spectatorCheck2 = {}
baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal = 2672741
baseGlobals.spectatorCheck2.testIntRange = function()
    return globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal)
end
baseGlobals.spectatorCheck2.intRangeExplanation = "Currently watched player on TV:"
function getIsTrackedPedVisibleState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 463) + 33)
end

--Unused, but still keeping it for documentation's sake
function getIsVisibleToScriptState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 463) + 34)
end

function isSpectatingMe(plyId)
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local visibleState = getIsTrackedPedVisibleState(plyId)
    local isWatchingMe = checkBit(visibleState, getLocalplayerID())
    return isWatchingMe and distanceBetween(player.get_player_ped(), ply) > 232
end

function amISpectating(plyId)
    --Check the scanned Global first, only works in TV spectator mode, not modest's Quick Spectate
    if globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal) == plyId then return true end
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local ownVisibleState = getIsTrackedPedVisibleState(getLocalplayerID())
    local amIWatching = checkBit(ownVisibleState, plyId)
    return amIWatching and distanceBetween(player.get_player_ped(), ply) > 230
end

---------------------------------------------------------------------------
----------------------------Player Bounty Info-----------------------------
---playerBountyAmount: Global_1835505.f_4[PLAYER::PLAYER_ID() /*3*/].f_1
baseGlobals.bountyInfo = {}
baseGlobals.bountyInfo.playerBountyInfoGlobal = 1835505
baseGlobals.bountyInfo.testIntRange = function()
    return getPlayerBountyAmount(getLocalplayerID())
end
baseGlobals.bountyInfo.intRangeExplanation = "Own Bounty Value:"

hasBounty = function(plyId)
    return getPlayerBountyAmount(plyId) > 0
end

getPlayerBountyAmount = function(plyId)
    return globals.get_int(baseGlobals.bountyInfo.playerBountyInfoGlobal + 4 + 1 + (plyId * 3) + 1)
end

-----------------------------------------------------------------------------
-------------------------- Special Export Vehicles --------------------------
baseGlobals.specialExport = {}
baseGlobals.specialExport.baseGlobal = 1942456
baseGlobals.specialExport.bareStringCheck = function()
    local vehicle = getSpecialExportVehiclesList()[1]
    local vehicle_data = vehicle and VEHICLE[vehicle]
    if vehicle_data then
        return "1st Vehicle in List: " .. tostring(vehicle_data[1])
    else
        return "No Vehicle Found..."
    end
end

getSpecialExportVehiclesList = function()
    local exportVehiclesList = {}
    for i = baseGlobals.specialExport.baseGlobal, baseGlobals.specialExport.baseGlobal + 9 do
        table.insert(exportVehiclesList, globals.get_int(i))
    end
    return exportVehiclesList -- Return the list of export vehicle values
end

-------------------------------------------------------------------------------
------------------------- Sessanta Shit ---------------------------------------
baseGlobals.sessantaShit = {}
baseGlobals.sessantaShit.base_local = 307
function newSessantaVehicle()
    local shop_controller = script("shop_controller")
    if shop_controller and shop_controller:is_active() then
        stats.set_int("MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_TUNER_CLIENT_VEHICLE_POSSIX", 1)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 1, 0)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 2, 0)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 3, 1)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local, 3)
    end
end
baseGlobals.sessantaShit.testFunction = function()
    newSessantaVehicle()
end
baseGlobals.sessantaShit.testFunctionExplanation = "Trigger new Sessanta Vehicle"

---------------------------------------------------------------------------------
--------------------------------- Disable Phone ---------------------------------
--Global_20796
phoneDisabledState = false
local phoneLoopRunning = false
baseGlobals.phoneDisabler = {}
baseGlobals.phoneDisabler.base_global = 20796
baseGlobals.phoneDisabler.testFunction = function()
    setPhoneDisabled(not phoneDisabledState)
end

local function disablePhoneLoop()
    phoneLoopRunning = true
    while phoneDisabledState do
        globals.set_bool(baseGlobals.phoneDisabler.base_global, true)
        sleep(0.06)
    end
    globals.set_bool(baseGlobals.phoneDisabler.base_global, false)
    phoneLoopRunning = false
end
menu.register_callback('disablePhoneLoop', disablePhoneLoop)

function setPhoneDisabled(disable, disableNotification)
    if disable then
        phoneDisabledState = disable
        if not disableNotification then
            displayHudBanner("S23_SOAD_BLP1", "PIM_NCL_PRIV0", "", 108)
        end
        if not phoneLoopRunning then
            menu.emit_event('disablePhoneLoop')
        end
    else
        phoneDisabledState = disable
        if not disableNotification then
            displayHudBanner("S23_SOAD_BLP1", "PIM_NCL_PRIV1", "", 108)
        end
    end
end

---------------------------------------------------------------------------------
---------------------------- RID Lookup -----------------------------------------
baseGlobals.ridLookup = {}
success, possible_offsets = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/RID_DATA_OFFSETS.json")

baseGlobals.ridLookup.freemode_base_local = -1
ridLookupTable = {}
function triggerRidLookupTableRefresh(plyname)
    local freemode_script = script("freemode")
    if not freemode_script or not plyname then return end
    --Only update the used offset if it hasn't been determined before
    if baseGlobals.ridLookup.freemode_base_local == -1 then
        for _, offset in pairs(possible_offsets) do
            local shortenedPlyName = freemode_script:get_string(offset + (0 * 526) + 3, 30)
            if shortenedPlyName == string.sub(plyname, 5) then
                baseGlobals.ridLookup.freemode_base_local = offset
                break
            end
        end
    end
    --Couldn't find the correct offset, exit
    if baseGlobals.ridLookup.freemode_base_local == -1 then return end
    for i = 0, 100 do
        local shortenedPlyName = freemode_script:get_string(baseGlobals.ridLookup.freemode_base_local + (i * 526) + 3, 30)
        local rid = freemode_script:get_int(baseGlobals.ridLookup.freemode_base_local + (i * 526))
        if rid ~= nil and rid > 1 and shortenedPlyName ~= nil then
            ridLookupTable[shortenedPlyName] = rid
        end
    end
end

function getRidForPlayer(plyName)
    return ridLookupTable[string.sub(plyName, 5)]
end
baseGlobals.ridLookup.bareStringCheck = function()
    local freemode_script = script("freemode")
    if not freemode_script then return "Freemode Script not found" end
    return "Plyname - 4: " .. tostring(freemode_script:get_string(baseGlobals.ridLookup.freemode_base_local + 3, 30))
end

----------------------------------------------------------------------------
--------------------------- Vehicle Options --------------------------------
baseGlobals.vehicleOptions = {}
baseGlobals.vehicleOptions.base_global = 1572015
baseGlobals.vehicleOptions.testFunctionExplanation = "Toggle Flappy Doors"
baseGlobals.vehicleOptions.testFunction = function()
    flappyDoors = not flappyDoors
    if flappyDoors then
        if not rcSpamRunning then
            menu.emit_event("startRCSpamThread")
        end
    end
end

vehicleStates = {
    ["open_door"] = 0,
    ["close_door"] = 1,
    ["engine_on"] = 2,
    ["engine_off"] = 3,
    ["headlights_on"] = 4,
    ["headlights_off"] = 5,
    ["radio_on"] = 6,
    ["radio_off"] = 7,
    ["neon_lights_on"] = 8,
    ["neon_lights_off"] = 9,
    ["stance_default"] = 13,
    ["stance_lowered"] = 14,
    ["roof_up"] = 15,
    ["roof_down"] = 16,
    ["hydraulics_all"] = 17,
    ["hydraulics_off"] = 18,
    ["hydraulics_front"] = 19,
    ["hydraulics_rear"] = 20,
}

--0=driver, 1=passenger, 2=left back, 3=right back
doorTypes = {
}

function getCurrentVehicleState(stateName)
    return checkBit(globals.get_int(baseGlobals.vehicleOptions.base_global), vehicleStates[stateName])
end

function toggleVehicleState(stateName, stateName2, stateName3)
    local stateIndex = vehicleStates[stateName]
    local stateIndex2 = stateName2 and vehicleStates[stateName2]
    local stateIndex3 = stateName3 and vehicleStates[stateName3]
    local vehRemoteOptionsState = globals.get_int(baseGlobals.vehicleOptions.base_global)
    vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex)
    if stateIndex2 then
        vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex2)
    end
    if stateIndex3 then
        vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex3)
    end
    globals.set_int(baseGlobals.vehicleOptions.base_global, vehRemoteOptionsState)
end

function setDoorBit(door, bit)
    local doorState = globals.get_int(baseGlobals.vehicleOptions.base_global + 8)
    if bit == 1 then
        doorState = setBit(doorState, door)
    else
        doorState = clearBit(doorState, door)
    end
    globals.set_int(baseGlobals.vehicleOptions.base_global + 8, doorState)
end

---------------------------- Native Teleport (Entity:Set_entity_coords) ---------------------------------
local coords_is_setting = false
baseGlobals.teleport = {}
baseGlobals.teleport.baseGlobalPed = 4521801
baseGlobals.teleport.baseGlobalVeh = 2635562
baseGlobals.teleport.baseGlobalVehTrigger = 2657921
baseGlobals.teleport.testFunctionExplanation = "Teleport forward"
baseGlobals.teleport.testFunction = function()
    nativeTeleport(localplayer:get_position() + localplayer:get_heading() * 2)
end
function nativeTeleport(vector, headingVec)
    if ((localplayer:get_pedtype() == 2) and not localplayer:is_in_vehicle() and not coords_is_setting) then -- localplayer is netplayer and not in vehicle
        coords_is_setting = true
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 946 + 0, vector.x)
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 946 + 1, vector.y)
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 946 + 2, vector.z)
        if headingVec then
            globals.set_float(baseGlobals.teleport.baseGlobalPed + 949, math.deg(math.atan(headingVec.y, headingVec.x)) - 90)
        else
            globals.set_float(baseGlobals.teleport.baseGlobalPed + 949, math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x)) - 90)
        end
        globals.set_int(baseGlobals.teleport.baseGlobalPed + 943, 20) --Trigger Entity:set_entity_coords
        sleep(0.05)
        globals.set_int(baseGlobals.teleport.baseGlobalPed + 943, -1)
    elseif localplayer:is_in_vehicle() then
        coords_is_setting = true
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 0, vector.x)
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 1, vector.y)
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 2, vector.z)
        if headingVec then
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 3207, headingVec.z) --pitch (NEEDS to be set to something other than 0 or yaw won't be applied either)
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 508, headingVec.x) --yaw
        else
            local yawAngle = math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x)) - 90
            local pitchAngle = math.deg(math.atan(localplayer:get_heading().z, math.sqrt(localplayer:get_heading().x^2 + localplayer:get_heading().y^2)))
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 3207, pitchAngle)
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 508, yawAngle)
        end
        globals.set_int(baseGlobals.teleport.baseGlobalVehTrigger + 1 + (getLocalplayerID() * 463) + 232, 7)
        globals.set_int(baseGlobals.teleport.baseGlobalVeh + 45 + 65, 1)
        sleep(0.05)
        globals.set_int(baseGlobals.teleport.baseGlobalVehTrigger + 1 + (getLocalplayerID() * 463) + 232, -1)
    end
    coords_is_setting = false
end

